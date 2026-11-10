#!/usr/bin/env python3
# SPDX-FileCopyrightText: NONE
# SPDX-License-Identifier: CC0-1.0
"""Measure GCompris startup timings logged by the gcompris.startup category.

Each run uses a fresh isolated profile (HOME and XDG_* in a temporary
directory) with automatic downloads disabled and the external words, voices
and background music RCC folders linked into $XDG_DATA_HOME/gcompris-qt/data3.
With --reuse-cache only XDG_CACHE_HOME is shared across the warm-up and measured
processes, to measure persistent checksum reuse. Cold runs evict the RCC files,
the binary and the core/activity RCC files from
the page cache with posix_fadvise(DONTNEED) and verify the eviction with
mincore(2). The application is terminated once all expected timing lines are
logged.

Usage:
  measure-startup.py --binary build/pt-pt/bin/gcompris-qt \
      --resources /path/to/share/gcompris-qt/rcc/data3 [--warm 5] [--cold 3]
"""

import argparse
import ctypes
import ctypes.util
import hashlib
import json
import mmap
import os
import re
import statistics
import subprocess
import sys
import tempfile
import time
from pathlib import Path

RESOURCE_DIRS = ("words", "voices-ogg", "backgroundMusic")
INIT_RE = re.compile(r"gcompris\.startup: ActivityInfoTree::initialize: ([\d.]+) ms")
UPDATE_RE = re.compile(
    r"gcompris\.startup: updateResource (\w+) (\S+) (\S+) total ([\d.]+) ms, checksum ([\d.]+) ms")
# Calls issued by main.qml on a non-first run with local resources present:
# voices once, words and music twice each (checkWordset/checkBackgroundMusic
# plus the explicit call).
EXPECTED_UPDATES = 5

libc = ctypes.CDLL(ctypes.util.find_library("c"), use_errno=True)
libc.mmap.restype = ctypes.c_void_p
libc.mmap.argtypes = (ctypes.c_void_p, ctypes.c_size_t, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_long)
libc.munmap.argtypes = (ctypes.c_void_p, ctypes.c_size_t)
libc.mincore.argtypes = (ctypes.c_void_p, ctypes.c_size_t, ctypes.POINTER(ctypes.c_ubyte))
PAGE = mmap.PAGESIZE
MAP_FAILED = ctypes.c_void_p(-1).value


def resident_fraction(path):
    """Fraction of the file's pages currently in the page cache, via mincore(2)."""
    size = path.stat().st_size
    if size == 0:
        return 0.0
    pages = (size + PAGE - 1) // PAGE
    fd = os.open(path, os.O_RDONLY)
    try:
        address = libc.mmap(None, size, mmap.PROT_READ, mmap.MAP_SHARED, fd, 0)
        if address in (None, MAP_FAILED):
            raise OSError(ctypes.get_errno(), "mmap failed for %s" % path)
        try:
            vector = (ctypes.c_ubyte * pages)()
            if libc.mincore(address, size, vector) != 0:
                raise OSError(ctypes.get_errno(), "mincore failed for %s" % path)
            return sum(v & 1 for v in vector) / pages
        finally:
            libc.munmap(address, size)
    finally:
        os.close(fd)


def evict(paths):
    """Drop the files' clean pages from the page cache (no root needed)."""
    for path in paths:
        fd = os.open(path, os.O_RDONLY)
        try:
            os.posix_fadvise(fd, 0, 0, os.POSIX_FADV_DONTNEED)
        finally:
            os.close(fd)


def sha256(path):
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1 << 20), b""):
            digest.update(block)
    return digest.hexdigest()


def make_profile(root, resources):
    env = dict(os.environ)
    for key, name in (("HOME", "home"), ("XDG_CONFIG_HOME", "config"),
                      ("XDG_DATA_HOME", "data"), ("XDG_CACHE_HOME", "cache"),
                      ("XDG_RUNTIME_DIR", "runtime")):
        path = root / name
        path.mkdir(mode=0o700, parents=True)
        env[key] = str(path)
    data3 = root / "data" / "gcompris-qt" / "data3"
    data3.mkdir(parents=True)
    for name in RESOURCE_DIRS:
        (data3 / name).symlink_to(resources / name, target_is_directory=True)
    conf = root / "config" / "gcompris" / "gcompris-qt.conf"
    conf.parent.mkdir(parents=True)
    # QSettings stores its "General" group as [%General] in INI files.
    # exeCount > 1 selects the regular (not first-run) startup path in main.qml;
    # a high lastGCVersionRan avoids the changelog dialog.
    conf.write_text("[%General]\nenableAutomaticDownloads=false\nlocale=pt_PT.UTF-8\n"
                    "fullscreen=false\n\n[Internal]\nexeCount=10\nlastGCVersionRan=999999\n",
                    encoding="utf-8")
    env.update(QT_QPA_PLATFORM="offscreen", LC_ALL="C.UTF-8",
               QT_LOGGING_RULES="gcompris.startup.info=true")
    env.pop("QT_MESSAGE_PATTERN", None)
    return env


def run_once(binary, resources, cold, evict_paths, timeout, keep_log, shared_cache=None):
    with tempfile.TemporaryDirectory(prefix="gcompris-startup-") as tmp:
        root = Path(tmp)
        env = make_profile(root, resources)
        if shared_cache is not None:
            env["XDG_CACHE_HOME"] = str(shared_cache)
        residency = None
        if cold:
            evict(evict_paths)
            residency = {str(p): resident_fraction(p) for p in evict_paths}
        command = [str(binary), "--window", "--locale", "pt_PT", "--renderer", "software", "--mute"]
        log_path = root / "app.log"
        with log_path.open("w", encoding="utf-8") as log:
            process = subprocess.Popen(command, env=env, stdout=log, stderr=subprocess.STDOUT,
                                       stdin=subprocess.DEVNULL)
            deadline = time.monotonic() + timeout
            text = ""
            try:
                while process.poll() is None and time.monotonic() < deadline:
                    time.sleep(0.2)
                    text = log_path.read_text(encoding="utf-8", errors="replace")
                    if INIT_RE.search(text) and len(UPDATE_RE.findall(text)) >= EXPECTED_UPDATES:
                        time.sleep(0.5)
                        break
            finally:
                early_exit = process.poll()
                if early_exit is None:
                    process.terminate()
                    try:
                        process.wait(timeout=5)
                    except subprocess.TimeoutExpired:
                        process.kill()
                        process.wait()
        text = log_path.read_text(encoding="utf-8", errors="replace")
        if keep_log:
            keep_log.write_text(text, encoding="utf-8")
        init = [float(m) for m in INIT_RE.findall(text)]
        updates = [{"type": t, "path": p, "file": Path(f).name, "total_ms": float(total),
                    "checksum_ms": float(checksum)}
                   for t, p, f, total, checksum in UPDATE_RE.findall(text)]
        return {"cold": cold, "early_exit": early_exit, "initialize_ms": init[0] if init else None,
                "updates": updates, "residency_before_start": residency,
                "complete": bool(init) and len(updates) >= EXPECTED_UPDATES}


def summary(values):
    if not values:
        return "—"
    return "%.1f (%.1f–%.1f)" % (statistics.median(values), min(values), max(values))


def table(runs):
    keys = []
    for run in runs:
        seen = {}
        for update in run["updates"]:
            seen[update["type"]] = seen.get(update["type"], 0) + 1
            key = (update["type"], seen[update["type"]], update["file"], update["path"])
            if key not in keys:
                keys.append(key)
    lines = ["| Medição | Quente: mediana (mín–máx) ms | Frio: mediana (mín–máx) ms |",
             "|---|---|---|"]
    warm = [r for r in runs if not r["cold"]]
    cold = [r for r in runs if r["cold"]]
    lines.append("| `ActivityInfoTree::initialize` | %s | %s |" % (
        summary([r["initialize_ms"] for r in warm if r["initialize_ms"] is not None]),
        summary([r["initialize_ms"] for r in cold if r["initialize_ms"] is not None])))

    def pick(run_list, key, field):
        values = []
        for run in run_list:
            seen = {}
            for update in run["updates"]:
                seen[update["type"]] = seen.get(update["type"], 0) + 1
                if (update["type"], seen[update["type"]], update["file"], update["path"]) == key:
                    values.append(update[field])
        return values

    for key in keys:
        label = "`updateResource` %s, chamada %d (%s, `%s`)" % (key[0], key[1], key[3], key[2])
        lines.append("| %s — total | %s | %s |" % (label, summary(pick(warm, key, "total_ms")),
                                                  summary(pick(cold, key, "total_ms"))))
        lines.append("| %s — MD5 | %s | %s |" % (label, summary(pick(warm, key, "checksum_ms")),
                                                summary(pick(cold, key, "checksum_ms"))))

    def sum_updates(run_list, field):
        return [sum(u[field] for u in r["updates"]) for r in run_list]
    lines.append("| Soma de todos os `updateResource` — total | %s | %s |" % (
        summary(sum_updates(warm, "total_ms")), summary(sum_updates(cold, "total_ms"))))
    lines.append("| Soma de todos os `updateResource` — MD5 | %s | %s |" % (
        summary(sum_updates(warm, "checksum_ms")), summary(sum_updates(cold, "checksum_ms"))))
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--binary", type=Path, required=True)
    parser.add_argument("--resources", type=Path, required=True,
                        help="data3 folder with words/, voices-ogg/ and backgroundMusic/ (read only)")
    parser.add_argument("--warm", type=int, default=5)
    parser.add_argument("--cold", type=int, default=3)
    parser.add_argument("--timeout", type=float, default=90)
    parser.add_argument("--json", type=Path, help="write raw per-run results here")
    parser.add_argument("--log-dir", type=Path, help="keep each run's application log here")
    parser.add_argument("--reuse-cache", action="store_true",
                        help="share an isolated checksum cache from warm-up through all measured runs")
    args = parser.parse_args()

    binary = args.binary.resolve()
    resources = args.resources.resolve()
    for name in RESOURCE_DIRS:
        if not (resources / name / "Contents").is_file():
            parser.error("missing %s/Contents in %s" % (name, resources))
    rcc_files = sorted(p for name in RESOURCE_DIRS for p in (resources / name).glob("*.rcc"))
    core_rcc = sorted((binary.parent.parent / "share" / "gcompris-qt" / "rcc").glob("*.rcc"))
    evict_paths = rcc_files + core_rcc + [binary]
    if args.log_dir:
        args.log_dir.mkdir(parents=True, exist_ok=True)

    runs = []
    shared = tempfile.TemporaryDirectory(prefix="gcompris-startup-cache-") if args.reuse_cache else None
    first_run = None
    # One discarded warm-up run fills the page cache before the warm series.
    plan = [("warmup", False)] + [("warm", False)] * args.warm + [("cold", True)] * args.cold
    for index, (kind, cold) in enumerate(plan):
        keep = args.log_dir / ("%02d-%s.log" % (index, kind)) if args.log_dir else None
        result = run_once(binary, resources, cold, evict_paths, args.timeout, keep,
                          Path(shared.name) if shared else None)
        result["kind"] = kind
        if cold:
            worst = max(result["residency_before_start"].values())
            result["max_residency_before_start"] = worst
            rcc_worst = max(result["residency_before_start"][str(p)] for p in rcc_files)
            result["max_external_rcc_residency_before_start"] = rcc_worst
        print("%s run %d: initialize=%s ms, updates=%d, complete=%s%s" % (
            kind, index, result["initialize_ms"], len(result["updates"]), result["complete"],
            ", max residency before start=%.3f" % result["max_residency_before_start"] if cold else ""),
            file=sys.stderr)
        if kind == "warmup":
            first_run = result
        if kind != "warmup":
            runs.append(result)

    if shared:
        shared.cleanup()
    info = {"reuse_cache": args.reuse_cache, "first_run_empty_cache": first_run,
            "binary": str(binary), "binary_sha256": sha256(binary), "resources": str(resources),
            "external_rcc": [str(p) for p in rcc_files],
            "evicted_files_for_cold": len(evict_paths)}
    if args.json:
        args.json.write_text(json.dumps({"info": info, "runs": runs}, indent=2), encoding="utf-8")
    print("binary: %s\nbinary sha256: %s" % (info["binary"], info["binary_sha256"]))
    print("runs: %d warm, %d cold, all complete: %s" % (
        args.warm, args.cold, all(r["complete"] for r in runs)))
    cold_runs = [r for r in runs if r["cold"]]
    if cold_runs:
        print("max page-cache residency right before a cold start: external RCC %.3f, all evicted files %.3f" % (
            max(r["max_external_rcc_residency_before_start"] for r in cold_runs),
            max(r["max_residency_before_start"] for r in cold_runs)))
    print()
    if args.reuse_cache:
        print("First startup with empty checksum cache:")
        print(table([first_run]))
        print("Subsequent startups with persistent checksum cache:")
    print(table(runs))
    return 0 if all(r["complete"] for r in runs) else 1


if __name__ == "__main__":
    sys.exit(main())
