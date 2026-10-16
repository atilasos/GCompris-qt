#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run selected ordering journeys with observable, owned native subprocesses."""
import argparse
import json
from pathlib import Path
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[2]
ACTIVITIES = ('ordering_numbers', 'ordering_alphabets', 'ordering_sentences')
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--snapshot', type=Path, required=True)
parser.add_argument('--output', type=Path, required=True)
parser.add_argument('--activity', choices=ACTIVITIES, action='append')
parser.add_argument('--case', choices=('gameplay', 'controls'), action='append')
args = parser.parse_args()
args.output.mkdir(parents=True, exist_ok=True)
receipts = []
for activity in args.activity or ACTIVITIES:
    for case in args.case or ('gameplay', 'controls'):
        target = args.output / (activity + '-' + case)
        command = [sys.executable, str(ROOT / 'tools/run-native-qml-case.py'), '--source-root', str(ROOT),
                   '--resource-snapshot', str(args.snapshot.resolve()), '--activity', activity,
                   '--qml-file', str(ROOT / 'src/activities/ordering_numbers/Ordering.qml'),
                   '--case', str(ROOT / f'tests/functional_ordering/{case}.qml'), '--output', str(target),
                   '--offline', '--timeout', '900' if case == 'gameplay' else '120',
                   '--result-marker', 'NATIVE_ORDERING_RESULT']
        started = time.time()
        with (args.output / (activity + '-' + case + '.launcher.log')).open('x') as log:
            process = subprocess.Popen(command, stdout=log, stderr=subprocess.STDOUT)
            print(json.dumps({'activity': activity, 'case': case, 'pid': process.pid, 'started_unix': started}), flush=True)
            code = process.wait()
        print(json.dumps({'activity': activity, 'case': case, 'pid': process.pid, 'exit': code, 'seconds': time.time()-started}), flush=True)
        if code:
            raise SystemExit(code)
        result = json.loads((target / 'result.json').read_text())
        assert result['passed'] and result['case_result']['passes'] == 2
        receipts.append(str(target))
assert receipts
print(json.dumps({'completed_receipts': receipts}), flush=True)
