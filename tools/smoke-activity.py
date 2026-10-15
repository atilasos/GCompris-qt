#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Launch real activities in isolated profiles and detect startup QML failures.

This is a startup check, not proof of level completion or linguistic quality.
"""

import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import time


ERROR = re.compile(r"Expected token|Type \w+ unavailable|(?:Reference|Type|Syntax)Error:|QQmlApplicationEngine failed|module .* is not installed|Error: Your root item")


def check_activity(binary, activity, locale, seconds, output):
    path = output / f"{activity}.log"
    with tempfile.TemporaryDirectory(prefix="gcompris-smoke-") as profile:
        env = dict(os.environ, QT_QPA_PLATFORM="offscreen")
        for key, name in (("XDG_CONFIG_HOME", "config"), ("XDG_DATA_HOME", "data"), ("XDG_CACHE_HOME", "cache")):
            env[key] = str(Path(profile) / name)
        with path.open("w", encoding="utf-8") as log:
            process = subprocess.Popen([str(binary), "--window", "--locale", locale,
                                        "--renderer", "software", "--mute", "--launch", activity],
                                       env=env, stdout=log, stderr=subprocess.STDOUT)
            try:
                deadline = time.monotonic() + seconds
                while process.poll() is None and time.monotonic() < deadline:
                    time.sleep(0.1)
                early_exit = process.poll()
            finally:
                if process.poll() is None:
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
                "early_exit": early_exit, "launch_requested": launch_requested,
                "qml_errors": errors, "startup_check": "passed" if passed else "failed",
                "log": str(path)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--binary", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--locale", default="pt_PT")
    parser.add_argument("--seconds", type=float, default=8)
    parser.add_argument("activities", nargs="+")
    args = parser.parse_args()
    if args.seconds <= 0 or any(not re.fullmatch(r"[a-z0-9_-]+", name) for name in args.activities):
        parser.error("Use a positive duration and activity identifiers from activities.txt")
    args.output.mkdir(parents=True, exist_ok=True)
    results = [check_activity(args.binary.resolve(), name, args.locale, args.seconds, args.output)
               for name in args.activities]
    (args.output / "results.json").write_text(json.dumps(results, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    for result in results:
        print(f"{result['activity']}: {result['startup_check']} ({len(result['qml_errors'])} QML errors)")
    return int(any(result["startup_check"] != "passed" for result in results))


if __name__ == "__main__":
    raise SystemExit(main())
