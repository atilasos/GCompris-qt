#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Wait for supervised game cases; every process uses one frozen source capsule."""
import argparse
from concurrent.futures import ThreadPoolExecutor
import json
import os
from pathlib import Path
import subprocess
import sys
import time
from archive import verify,sha

NAMES=('babymatch','babyshapes','imagename')


def run(task,args):
    activity,kind=task;name=activity+'-'+kind;source=args.archive/'files';target=args.output/name
    case=source/'tests/functional_association'/((activity+'-resources.qml') if kind=='resources' else kind+'.qml')
    command=[sys.executable,'-B',str(source/'tools/run-native-qml-supervised.py'),'--launcher',str(source/'tools/run-native-qml-case.py'),
             '--source-root',str(source),'--resource-snapshot',str(args.snapshot.resolve()),'--activity',activity,
             '--qml-file',str(source/'src/activities/babymatch/Babymatch.qml'),'--case',str(case),
             '--output',str(target),'--offline','--timeout','300','--result-marker','NATIVE_ASSOCIATION_RESULT']
    started=time.time()
    with (args.output/(name+'.supervisor.log')).open('x') as log:
        child=subprocess.Popen(command,stdout=log,stderr=subprocess.STDOUT,env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1'))
        print(json.dumps({'case':name,'pid':child.pid,'started':started}),flush=True);code=child.wait()
    receipt=target/'result.json';status=target/'launcher-status.json'
    record={'kind':'observed-supervisor-subprocess-exit','case':name,'exit_code':code,'elapsed':time.time()-started,
            'receipt_sha256':sha(receipt.read_bytes()) if receipt.exists() else None,
            'launcher_status_sha256':sha(status.read_bytes()) if status.exists() else None,
            'supervisor_sha256':sha((source/'tools/run-native-qml-supervised.py').read_bytes())}
    (args.output/(name+'.process.json')).write_text(json.dumps(record,indent=2)+'\n');print(json.dumps(record),flush=True);return record


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--archive',type=Path,required=True);parser.add_argument('--snapshot',type=Path,required=True);parser.add_argument('--output',type=Path,required=True);args=parser.parse_args();args.archive=args.archive.resolve();verify(args.archive)
    assert not args.output.exists();args.output.mkdir(parents=True)
    tasks=[(name,kind) for kind in ('complete','controls','resources') for name in NAMES]+[('babyshapes','edge-portrait')]
    with ThreadPoolExecutor(max_workers=2) as pool:records=list(pool.map(lambda task:run(task,args),tasks))
    assert len(records)==10
    if any(record['exit_code']!=0 for record in records):raise SystemExit(1)
    print(json.dumps({'completed_cases':len(records)}),flush=True)
