#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Drive native balances by visible labels and audit unit arithmetic independently."""
import argparse
from decimal import Decimal
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]


def mass(label):
    found = re.fullmatch(r'(\d+(?:[.,]\d+)?)\s*(kg|g|lb|oz)?', label.strip())
    if not found:
        raise ValueError(label)
    return Decimal(found[1].replace(',', '.')) * {'kg': 1000, 'g': 1, 'lb': 16, 'oz': 1, None: 1}[found[2]]


def audit(result, partial):
    family = {
        'scalesboard': r'\d+',
        'scalesboard_weight': r'\d+(?:[.,]\d+)?\s+(?:g|kg)',
        'scalesboard_weight_avoirdupois': r'\d+(?:[.,]\d+)?\s+(?:lb|oz)',
    }[result['activity']]
    for puzzle in result['puzzles']:
        labels = puzzle['labels'] + ([puzzle['visibleTarget']] if puzzle['visibleTarget'] else [])
        assert all(re.fullmatch(family, label.strip()) for label in labels), labels
        values = [mass(label) for label in puzzle['labels']]
        assert len(values) == len(puzzle['positions'])
        assert 0 < len(values) <= 7
        assert all(side in [-1, 0, 1] for side in puzzle['positions'])
        if not puzzle['both']:
            assert -1 not in puzzle['positions']
        balance = sum(value * side for value, side in zip(values, puzzle['positions']))
        assert balance == puzzle['canonical'], puzzle
        if puzzle['visibleTarget']:
            assert balance == mass(puzzle['visibleTarget']), puzzle
        else:
            assert puzzle['probes'][-1]['tilt'] == 0
            for probe in puzzle['probes']:
                expected = 1 if probe['sum'] < balance else -1 if probe['sum'] > balance else 0
                assert probe['tilt'] == expected, probe
            prompt = puzzle['prompt']
            if result['activity'] == 'scalesboard_weight':
                assert re.search(r'em (?:quilo)?gramas:', prompt), prompt
            elif result['activity'] == 'scalesboard_weight_avoirdupois':
                assert re.search(r'em (?:onças|libras):', prompt), prompt
            else:
                assert 'peso do presente:' in prompt, prompt
            factor = 1000 if 'quilogram' in prompt else 16 if 'libras' in prompt else 1
            assert Decimal(puzzle['entry']) * factor == balance, puzzle
    if not partial:
        expected = {'scalesboard': (52, 223), 'scalesboard_weight': (45, 222),
                    'scalesboard_weight_avoirdupois': (45, 221)}[result['activity']]
        assert len(result['completed']) == expected[0]
        assert len(result['puzzles']) == expected[1]
    return {'passed': True, 'activity': result['activity'], 'puzzles': len(result['puzzles']),
            'levels': len(result['completed']), 'rejected': result['rejected'], 'real_drags': result['drags']}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--activity', choices=['scalesboard', 'scalesboard_weight', 'scalesboard_weight_avoirdupois'], required=True)
    parser.add_argument('--resource-snapshot', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--controls', action='store_true')
    parser.add_argument('--physical-only', action='store_true', help='disable the visual keyboard preference')
    parser.add_argument('--levels', type=int, default=0, help='partial tracer only; omit for complete gameplay')
    args = parser.parse_args()
    generated = ROOT / 'build/functional-scales' / args.activity / ('controls.qml' if args.controls else str(args.levels) + ('-physical' if args.physical_only else '') + '-levels.qml')
    generated.parent.mkdir(parents=True, exist_ok=True)
    case = (ROOT / 'tests/functional_scales' / ('controls.qml' if args.controls else 'gameplay.qml')).read_text()
    case = case.replace('__SCALES_ORACLE__', (ROOT / 'tests/functional_scales/oracle.js').read_text()).replace('__LEVEL_LIMIT__', str(args.levels)).replace('__VIRTUAL_KEYBOARD__', 'false' if args.physical_only else 'true')
    generated.write_text(case)
    code = subprocess.call([sys.executable, str(ROOT / 'tools/run-native-qml-case.py'),
                           '--resource-snapshot', str(args.resource_snapshot.resolve()), '--activity', args.activity,
                           '--qml-file', str(ROOT / 'src/activities/scalesboard/Scalesboard.qml'), '--case', str(generated),
                           '--output', str(args.output.resolve()), '--offline', '--timeout', '2400', '--result-marker', 'NATIVE_SCALES_RESULT'])
    if args.output.is_dir():
        shutil.copyfile(generated, args.output / 'case.qml')
    if code or args.controls:
        return code
    result = json.loads((args.output / 'result.json').read_text())['case_result']
    report = audit(result, args.levels > 0)
    (args.output / 'oracle.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
