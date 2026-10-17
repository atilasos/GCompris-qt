#!/usr/bin/env python3
# SPDX-FileCopyrightText: NONE
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run native CRJM acceptance serially against a complete built resource snapshot."""
import argparse
import json
from pathlib import Path
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[1]
CASES = [name + suffix for name in ('dominorio', 'gatos-caes', 'faisca', 'quelhas',
                                  'atari-go', 'produto', 'y', 'nex')
         for suffix in ('', '-tux')] + ['strategy-regression', 'dominorio-keyboard']


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--resource-snapshot', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--offline-cpus', type=float)
    parser.add_argument('--offline-memory-mib', type=int)
    args = parser.parse_args()
    if args.output.exists():
        parser.error('Use a new output directory')
    args.output.mkdir(parents=True)
    outcomes = []
    for case in CASES:
        command = [sys.executable, str(ROOT / 'tools/run-native-qml-case.py'),
                   '--resource-snapshot', str(args.resource_snapshot.resolve()),
                   '--activity', 'menu', '--from-menu', '--qml-file',
                   str(ROOT / 'src/activities/menu/Menu.qml'), '--case',
                   str(ROOT / 'tests/crjm' / (case + '.qml')), '--output',
                   str(args.output.resolve() / case), '--offline', '--timeout', '240']
        if args.offline_cpus is not None:
            command += ['--offline-cpus', str(args.offline_cpus)]
        if args.offline_memory_mib is not None:
            command += ['--offline-memory-mib', str(args.offline_memory_mib)]
        start = time.monotonic()
        with (args.output / (case + '.runner.log')).open('w') as log:
            completed = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT)
        result_file = args.output / case / 'result.json'
        result = json.loads(result_file.read_text()) if result_file.exists() else {}
        outcome = {'case': case, 'command': command, 'seconds': round(time.monotonic() - start, 3),
                   'passed': completed.returncode == 0 and result.get('passed', False),
                   'case_result': result.get('case_result'), 'qml_errors': result.get('qml_errors')}
        outcomes.append(outcome)
        (args.output / 'summary.json').write_text(json.dumps(outcomes, ensure_ascii=False, indent=2) + '\n')
        print(f"{case}: {'PASS' if outcome['passed'] else 'FAIL'} ({outcome['seconds']} s)", flush=True)
    return 0 if all(item['passed'] for item in outcomes) else 1


if __name__ == '__main__':
    raise SystemExit(main())
