#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Launch real activities in isolated profiles and detect startup QML failures.

This is a startup check, not proof of level completion or linguistic quality.
"""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import uuid
import time


ERROR = re.compile(r"Expected token|Type \w+ unavailable|(?:Reference|Type|Syntax)Error:|QQmlApplicationEngine failed|module .* is not installed|Error: Your root item")


def write_json(path, value):
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    temporary.replace(path)


def hash_paths(root, paths):
    digest = hashlib.sha256()
    files = []
    for path in paths:
        if path.is_dir():
            # Deployed data packages may be directories linked from another build.
            files.extend(Path(folder) / name for folder, _, names in os.walk(path, followlinks=True) for name in names)
        elif path.is_file():
            files.append(path)
    for path in sorted(set(files)):
        digest.update(str(path.relative_to(root)).encode() + b"\0")
        with path.open("rb") as source:
            for block in iter(lambda: source.read(1024 * 1024), b""):
                digest.update(block)
        digest.update(b"\0")
    return digest.hexdigest()


def fingerprint(binary, source_root, locale, seconds, offline_image):
    source_paths = [source_root / name for name in ("src", "resources", "cmake", "poqm/pt", "po/pt", "CMakeLists.txt")]
    if not any(path.exists() for path in source_paths):
        source_paths = [source_root]
    deployment = binary.parent.parent
    return {"binary": str(binary), "source_root": str(source_root),
            "source_sha256": hash_paths(source_root, source_paths),
            "build_sha256": hash_paths(deployment, [binary, deployment / "share/gcompris-qt"]),
            "runner_sha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
            "locale": locale, "seconds": seconds, "offline_image": offline_image}


def check_activity(binary, activity, locale, seconds, output, offline_image=None):
    path = output / f"{activity}.log"
    with tempfile.TemporaryDirectory(prefix="gcompris-smoke-") as profile:
        env = dict(os.environ, QT_QPA_PLATFORM="offscreen")
        for key, name in (("XDG_CONFIG_HOME", "config"), ("XDG_DATA_HOME", "data"), ("XDG_CACHE_HOME", "cache")):
            env[key] = str(Path(profile) / name)
        command = [str(binary), "--window", "--locale", locale,
                   "--renderer", "software", "--mute", "--launch", activity]
        container = None
        if offline_image:
            container = "gcompris-smoke-" + uuid.uuid4().hex
            settings = [f"{key}={env[key]}" for key in ("QT_QPA_PLATFORM", "XDG_CONFIG_HOME", "XDG_DATA_HOME", "XDG_CACHE_HOME")]
            command = ["docker", "run", "--rm", "--pull=never", "--name", container,
                       "--network", "none", "--read-only", "--mount", "type=bind,src=/,dst=/host,readonly",
                       "--tmpfs", "/host/tmp:rw,mode=1777", offline_image,
                       "chroot", "/host", "/usr/bin/env", *settings, *command]
        with path.open("w", encoding="utf-8") as log:
            process = subprocess.Popen(command, env=env, stdout=log, stderr=subprocess.STDOUT)
            try:
                deadline = time.monotonic() + seconds
                while process.poll() is None and time.monotonic() < deadline:
                    time.sleep(0.1)
                early_exit = process.poll()
            finally:
                if process.poll() is None:
                    if container:
                        subprocess.run(["docker", "stop", "--time", "1", container], capture_output=True, timeout=10)
                    else:
                        process.terminate()
                    try:
                        process.wait(timeout=5)
                    except subprocess.TimeoutExpired:
                        process.kill()
                        process.wait()
        text = path.read_text(encoding="utf-8", errors="replace")
        errors = [line for line in text.splitlines() if ERROR.search(line)]
        launch_requested = f"Start activity {activity}/" in text
        passed = early_exit is None and launch_requested and not errors
        return {"activity": activity, "locale": locale, "seconds": seconds,
                "network_isolation": "docker-network-none" if offline_image else "not-enforced",
                "early_exit": early_exit, "launch_requested": launch_requested,
                "qml_errors": errors, "startup_check": "passed" if passed else "failed",
                "log": str(path)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--binary", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--locale", default="pt_PT")
    parser.add_argument("--seconds", type=float, default=8)
    parser.add_argument("--source-root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--resume", action="store_true", help="reuse results only for identical source/build/config fingerprints")
    parser.add_argument("--offline", action="store_true", help="Linux Docker network-none run with host filesystem read-only")
    parser.add_argument("--offline-container-image", default="alpine:latest", help="already installed image with chroot; never pulled")
    parser.add_argument("activities", nargs="+")
    args = parser.parse_args()
    if args.seconds <= 0 or any(not re.fullmatch(r"[A-Za-z0-9_-]+", name) for name in args.activities):
        parser.error("Use a positive duration and activity identifiers from activities.txt")
    if not args.binary.is_file() or not args.source_root.is_dir():
        parser.error("Binary and source root must exist")
    offline_image = None
    if args.offline:
        try:
            offline_image = subprocess.check_output(["docker", "image", "inspect", "--format", "{{.Id}}", args.offline_container_image], text=True).strip()
        except (OSError, subprocess.CalledProcessError):
            parser.error("Offline mode requires Docker and an already installed container image with chroot")
    identity = fingerprint(args.binary.resolve(), args.source_root.resolve(), args.locale, args.seconds, offline_image)
    args.output.mkdir(parents=True, exist_ok=True)
    metadata = args.output / "run.json"
    result_file = args.output / "results.json"
    results = []
    if args.resume:
        if not metadata.exists() or json.loads(metadata.read_text()) != identity:
            parser.error("Cannot resume: source/build/config fingerprint differs or is missing; use a new output directory")
        if result_file.exists():
            results = json.loads(result_file.read_text())
    elif metadata.exists() or result_file.exists():
        parser.error("Output already contains a run; use --resume or a new output directory")
    write_json(metadata, identity)
    finished = {result["activity"] for result in results}
    for name in args.activities:
        if name in finished:
            continue
        result = check_activity(args.binary.resolve(), name, args.locale, args.seconds, args.output, offline_image)
        results.append(result)
        # Save after each activity so an interrupted run keeps its completed work.
        write_json(result_file, results)
        print(f"{result['activity']}: {result['startup_check']} ({len(result['qml_errors'])} QML errors)", flush=True)
    return int(any(result["startup_check"] != "passed" for result in results))


if __name__ == "__main__":
    raise SystemExit(main())
