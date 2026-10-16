#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run native erase campaigns, retaining completed receipts and subprocess exits."""
import argparse
from concurrent.futures import ThreadPoolExecutor
import json
from pathlib import Path
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[2]
ACTIVITIES = ('erase', 'erase_clic', 'erase_2clic')


def run(activity, mode, args):
    name = activity + '-' + ('automatic' if mode == 1 else 'manual')
    case = args.output / (name + '.qml')
    source = (ROOT / 'tests/functional_erase/gameplay.qml.in').read_text()
    case.write_text(source.replace('__MODE__', str(mode)).replace('__LEVELS__', str(args.levels)))
    output = args.output / name
    command = [sys.executable, str(ROOT / 'tools/run-native-qml-case.py'), '--source-root', str(ROOT),
               '--resource-snapshot', str(args.snapshot.resolve()), '--activity', activity,
               '--qml-file', str(ROOT / 'src/activities/erase/Erase.qml'), '--case', str(case),
               '--output', str(output), '--offline', '--timeout', '1000', '--result-marker', 'NATIVE_ERASE_RESULT']
    started = time.time()
    with (args.output / (name + '.launcher.log')).open('x') as log:
        process = subprocess.Popen(command, stdout=log, stderr=subprocess.STDOUT)
        print(json.dumps({'name': name, 'pid': process.pid, 'started_unix': started}), flush=True)
        code = process.wait()
    result_path = output / 'result.json'
    result = json.loads(result_path.read_text()) if result_path.exists() else {}
    receipt = {'name': name, 'pid': process.pid, 'launcher_exit': code,
               'native_exit': result.get('exit_code'), 'native_passed': result.get('passed'),
               'seconds': time.time()-started}
    (args.output / (name + '.process.json')).write_text(json.dumps(receipt, indent=2)+'\n')
    print(json.dumps(receipt), flush=True)
    return receipt


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--snapshot', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--activity', choices=ACTIVITIES, action='append')
    parser.add_argument('--mode', choices=(1, 2), type=int, action='append')
    parser.add_argument('--levels', choices=(1, 6), type=int, default=6,
                        help='1 is a pilot only; final evidence requires all 6 levels')
    args = parser.parse_args()
    if args.output.exists():
        parser.error('Output must be a new directory')
    args.output.mkdir(parents=True)
    tasks = [(activity, mode) for activity in args.activity or ACTIVITIES for mode in args.mode or (1, 2)]
    assert tasks
    with ThreadPoolExecutor(max_workers=3) as pool:
        records = list(pool.map(lambda task: run(*task, args), tasks))
    if not all(row['launcher_exit'] == 0 and row['native_exit'] == 0 and row['native_passed'] for row in records):
        raise SystemExit(1)
    print(json.dumps({'completed_cases': len(records), 'levels_per_case': args.levels}), flush=True)
