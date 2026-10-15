#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Exercise full tens-complement puzzles and independently audit displayed sums."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
ACTIVITIES = ['tens_complement_' + suffix for suffix in ['find', 'swap', 'calculate', 'use']]


def audit(result):
    activity = result['activity']
    for equation in result['equations']:
        if 'numbers' in equation:
            original, ordered = equation['numbers'], equation['ordered']
            assert sorted(original) == sorted(ordered), equation
            assert all(sum(ordered[i:i + 2]) == 10 for i in range(0, len(ordered) - 1, 2)), equation
            assert sum(original) == equation['result'], equation
        else:
            assert equation['a'] + equation['b'] == equation['result'], equation
            if 'parts' in equation:
                assert equation['parts'][0] == equation['a'], equation
                assert sum(equation['parts'][:2]) == 10, equation
                assert sum(equation['parts']) == equation['result'], equation
    expected = {'tens_complement_find': (40, 120), 'tens_complement_use': (30, 60),
                'tens_complement_swap': (12, 45), 'tens_complement_calculate': (8, 28)}
    puzzles, equations = expected[activity]
    assert result['solved'] == puzzles, result['solved']
    assert len(result['equations']) == equations, len(result['equations'])
    assert result['rejected'] > 0
    if 'rejectedByLevel' in result:
        assert all(count > 0 for count in result['rejectedByLevel']), result['rejectedByLevel']
    return {'activity': activity, 'puzzles': puzzles, 'equations': equations,
            'rejected': result['rejected'], 'independent_python_sums': 'passed'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--activity', choices=ACTIVITIES, required=True)
    parser.add_argument('--resource-snapshot', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--controls', action='store_true')
    args = parser.parse_args()
    base = 'tens_complement_swap' if args.activity.endswith(('swap', 'calculate')) else args.activity
    qml = ROOT / 'src/activities' / base / (base[0].upper() + base[1:] + '.qml')
    case = 'controls' if args.controls else 'swapping' if base.endswith('swap') else 'cards'
    code = subprocess.call([sys.executable, str(ROOT / 'tools/run-native-qml-case.py'),
                           '--source-root', str(ROOT), '--resource-snapshot', str(args.resource_snapshot.resolve()),
                           '--activity', args.activity, '--qml-file', str(qml),
                           '--case', str(ROOT / 'tests/functional_tens' / (case + '.qml')),
                           '--output', str(args.output.resolve()), '--result-marker', 'NATIVE_TENS_RESULT',
                           '--offline', '--timeout', '280'])
    if code:
        return code
    if not args.controls:
        result = json.loads((args.output / 'result.json').read_text())['case_result']
        report = audit(result)
        sources = [ROOT / 'src/activities' / args.activity / 'ActivityInfo.qml',
                   *sorted((ROOT / 'src/activities' / args.activity / 'resource').glob('*/Data.qml'))]
        report['datasets_sha256'] = {str(path.relative_to(ROOT)): hashlib.sha256(path.read_bytes()).hexdigest() for path in sources}
        (args.output / 'oracle.json').write_text(json.dumps(report, indent=2) + '\n')
        print(json.dumps(report))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
