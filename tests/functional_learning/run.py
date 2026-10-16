#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run and wait for every supervised native case against frozen sources."""
import argparse
from concurrent.futures import ThreadPoolExecutor
import json
import os
from pathlib import Path
import subprocess
import sys
import time
from archive import verify

ACTIVITIES=('learn_digits','learn_additions','learn_subtractions')


def run(task,args):
    activity,kind,mode=task;name=activity+'-'+kind+('-'+str(mode) if mode else '')
    source=args.archive/'files';case=source/'tests/functional_learning'/('mode-'+str(mode)+'.qml' if kind=='gameplay' else kind+'.qml')
    target=args.output/name
    command=[sys.executable,'-B',str(source/'tools/run-native-qml-supervised.py'),
             '--launcher',str(source/'tools/run-native-qml-case.py'),'--source-root',str(source),
             '--resource-snapshot',str(args.snapshot.resolve()),'--activity',activity,
             '--qml-file',str(source/'src/activities/learn_digits/Learn_digits.qml'),
             '--case',str(case),'--output',str(target),'--offline','--timeout','650',
             '--result-marker','NATIVE_LEARNING_RESULT']
    started=time.time()
    with (args.output/(name+'.supervisor.log')).open('x') as log:
        child=subprocess.Popen(command,stdout=log,stderr=subprocess.STDOUT,
                               env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1'))
        print(json.dumps({'case':name,'pid':child.pid,'started':started}),flush=True)
        code=child.wait()
    record={'case':name,'supervisor_exit':code,'elapsed':time.time()-started}
    (args.output/(name+'.process.json')).write_text(json.dumps(record,indent=2)+'\n')
    print(json.dumps(record),flush=True)
    return record


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--archive',type=Path,required=True);parser.add_argument('--snapshot',type=Path,required=True);parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args();args.archive=args.archive.resolve();verify(args.archive)
    assert not args.output.exists();args.output.mkdir(parents=True)
    tasks=[('learn_digits','gameplay',mode) for mode in (1,2,3)]+[(name,'gameplay',1) for name in ACTIVITIES[1:]]+[(name,kind,0) for kind in ('controls','keyboard') for name in ACTIVITIES]
    with ThreadPoolExecutor(max_workers=2) as pool:records=list(pool.map(lambda task:run(task,args),tasks))
    assert len(records)==11
    if any(record['supervisor_exit']!=0 for record in records):raise SystemExit(1)
    print(json.dumps({'completed_cases':len(records)}),flush=True)
