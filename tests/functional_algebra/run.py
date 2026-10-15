#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Drive real Qt arithmetic screens with reference answers from Fraction."""
import argparse
from fractions import Fraction
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--activity", required=True, choices=["algebra_plus", "algebra_minus", "algebra_by", "algebra_div"])
    parser.add_argument("--resource-snapshot", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    oracle = {name: {} for name in ["algebra_plus", "algebra_minus", "algebra_by", "algebra_div"]}
    for left in range(101):
        for right in range(101):
            a, b = Fraction(left), Fraction(right)
            key = f"{left}:{right}"
            for name, value in [("algebra_plus", a + b), ("algebra_minus", a - b), ("algebra_by", a * b)]:
                oracle[name][key] = int(value)
            if b and (a / b).denominator == 1:
                oracle["algebra_div"][key] = int(a / b)
    assert oracle["algebra_plus"]["13:8"] == 21
    assert oracle["algebra_minus"]["15:7"] == 8
    assert oracle["algebra_by"]["8:7"] == 56
    assert oracle["algebra_div"]["84:7"] == 12
    generated = ROOT / "build/functional-algebra" / args.activity
    generated.mkdir(parents=True, exist_ok=True)
    case = generated / "gameplay.qml"
    case.write_text((ROOT / "tests/functional_algebra/gameplay.qml").read_text().replace("__ARITHMETIC_ORACLE__", json.dumps(oracle)), encoding="utf-8")
    return subprocess.call([sys.executable, str(ROOT / "tools/run-native-qml-case.py"),
        "--source-root", str(ROOT), "--resource-snapshot", str(args.resource_snapshot.resolve()),
        "--activity", args.activity, "--qml-file", "src/activities/algebra_by/Algebra.qml",
        "--case", str(case), "--output", str(args.output.resolve()), "--timeout", "650",
        "--result-marker", "NATIVE_ALGEBRA_RESULT", "--offline"])

if __name__ == "__main__":
    raise SystemExit(main())
