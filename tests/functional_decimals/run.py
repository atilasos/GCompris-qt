#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Complete all decimal/quantity datasets through real Qt UI campaigns."""
import argparse
from concurrent.futures import ThreadPoolExecutor
import json
from pathlib import Path
import subprocess
import sys

from inventory import ROOT, inventory
from audit import audit


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--snapshot', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--jobs', type=int, default=4)
    parser.add_argument('--activity', action='append', choices=list(inventory()))
    parser.add_argument('--offline', action='store_true')
    parser.add_argument('--case', choices=['campaign','controls'], default='campaign')
    args = parser.parse_args()
    if args.output.exists():
        parser.error('Use a new output directory')
    args.output.mkdir(parents=True)
    data = inventory()
    (args.output / 'inventory.json').write_text(json.dumps(data, indent=2)+'\n')
    template = (Path(__file__).parent / (args.case+'.qml')).read_text()
    tasks = []
    for activity, datasets in data.items():
        if args.activity and activity not in args.activity:
            continue
        for portrait in ([False, True] if args.case=="campaign" else [False]):
            for virtual in ([False, True] if args.case=="campaign" else [False]):
                name = f'{activity}-{"portrait" if portrait else "landscape"}-{"virtual" if virtual else "physical"}'
                counts = [len(level['subLevels']) for dataset in datasets for level in dataset['levels']]
                case = args.output / (name+'.qml')
                case.write_text(template.replace('__COUNTS__',json.dumps(counts)).replace('__PORTRAIT__',str(portrait).lower()).replace('__VIRTUAL__',str(virtual).lower()))
                tasks.append((activity,name,case,counts))

    def run(task):
        activity,name,case,counts = task
        output = args.output / name
        command = [sys.executable,str(ROOT/'tools/run-native-qml-case.py'),
                   '--resource-snapshot',str(args.snapshot.resolve()),'--activity',activity,
                   '--qml-file',str(ROOT/'src/activities/learn_decimals/Learn_decimals.qml'),
                   '--case',str(case.resolve()),'--output',str(output.resolve()),'--timeout','300']
        if args.offline:
            command.append('--offline')
        with (args.output/(name+'.runner.log')).open('w') as log:
            result = subprocess.run(command,cwd=ROOT,stdout=log,stderr=subprocess.STDOUT)
        report = json.loads((output/'result.json').read_text()) if (output/'result.json').exists() else {}
        actual = len((report.get('case_result') or {}).get('completed',[]))
        row = {'name':name,'command':command,'exit_code':result.returncode,'passed':report.get('passed',False),'expected_completions':sum(counts) if args.case=='campaign' else 0,'actual_completions':actual}
        row['passed'] = result.returncode == 0 and row['passed'] and actual==row['expected_completions']
        print(json.dumps(row),flush=True)
        return row

    with ThreadPoolExecutor(max_workers=args.jobs) as pool:
        results = list(pool.map(run,tasks))
    (args.output/'summary.json').write_text(json.dumps(results,indent=2)+'\n')
    audits = audit(args.output) if args.case=='campaign' else []
    if audits:
        (args.output/'question-audit.json').write_text(json.dumps(audits,indent=2)+'\n')
    return 0 if all(row['passed'] for row in results+audits) else 1

if __name__=='__main__':
    raise SystemExit(main())
