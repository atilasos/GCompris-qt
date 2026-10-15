#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Rerun scoped NumPad consumer probes using a sealed native resource snapshot."""
import argparse
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
CASES = [
    ('tens_complement_calculate', 'tens_complement_swap/Tens_complement_swap.qml', 'tens'),
    ('scalesboard', 'scalesboard/Scalesboard.qml', 'scales'),
    ('scalesboard_weight', 'scalesboard/Scalesboard.qml', 'scales'),
    ('scalesboard_weight_avoirdupois', 'scalesboard/Scalesboard.qml', 'scales'),
    ('guessnumber', 'guessnumber/Guessnumber.qml', 'guess'),
    ('learn_decimals_additions', 'learn_decimals/Learn_decimals.qml', 'decimals'),
    ('learn_decimals_subtractions', 'learn_decimals/Learn_decimals.qml', 'decimals'),
    ('tens_complement_swap', 'tens_complement_swap/Tens_complement_swap.qml', 'swap'),
    ('learn_decimals', 'learn_decimals/Learn_decimals.qml', 'inactive_decimals'),
    ('learn_quantities', 'learn_decimals/Learn_decimals.qml', 'inactive_decimals'),
]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--resource-snapshot', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    output = args.output.resolve()
    if output.exists() and any(output.iterdir()):
        parser.error('Use a new empty output directory')
    output.mkdir(parents=True, exist_ok=True)
    results = []
    for activity, source, case in CASES:
        command = [sys.executable, str(ROOT / 'tools/run-native-qml-case.py'), '--source-root', str(ROOT),
                   '--resource-snapshot', str(args.resource_snapshot.resolve()), '--activity', activity,
                   '--qml-file', str(ROOT / 'src/activities' / source),
                   '--case', str(Path(__file__).parent / (case + '.qml')), '--output', str(output / activity), '--timeout', '30']
        with (output / (activity + '.launcher.log')).open('w') as log:
            process = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT)
        report_path = output / activity / 'result.json'
        report = json.loads(report_path.read_text()) if report_path.exists() else {}
        results.append({'activity': activity, 'passed': process.returncode == 0 and report.get('passed', False),
                        'scope': 'inactive numerical phase and global shortcuts' if case in ['swap', 'inactive_decimals'] else 'digit, backspace and global shortcuts; decimal separator in decimals case',
                        'result': str(report_path.relative_to(output))})
    summary = {'passed': all(row['passed'] for row in results), 'activities': results,
               'scope': 'Specific numerical input events and prepared phases; not all levels or Windows acceptance'}
    (output / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(json.dumps(summary, indent=2))
    return 0 if summary['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
