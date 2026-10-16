#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run owned native fraction processes against a verified historical source archive."""
import argparse
from concurrent.futures import ThreadPoolExecutor
import json
from pathlib import Path
import subprocess
import sys
import time
from archive import verify, sha

ROOT=Path(__file__).resolve().parents[2]
ACTIVITIES=('fractions_create','fractions_find')


def run(activity,kind,args,manifest):
    name=activity+'-'+kind
    case='tests/functional_fractions/'+('all-levels.qml' if kind=='gameplay' else 'controls.qml')
    source=args.archive/'files'
    target=args.output/name
    command=[sys.executable,str(source/'tools/run-native-qml-case.py'),'--source-root',str(source),
             '--resource-snapshot',str(args.snapshot.resolve()),'--activity',activity,
             '--qml-file',str(source/'src/activities/fractions_create/FractionsCreate.qml'),
             '--case',str(source/case),'--output',str(target),'--offline','--timeout','900',
             '--result-marker','NATIVE_FRACTIONS_RESULT']
    started=time.time()
    with (args.output/(name+'.launcher.log')).open('x') as log:
        process=subprocess.Popen(command,stdout=log,stderr=subprocess.STDOUT)
        print(json.dumps({'case':name,'pid':process.pid,'started':started}),flush=True)
        code=process.wait()
    result_path=target/'result.json';result=json.loads(result_path.read_text()) if result_path.exists() else {}
    record={'activity':activity,'case':kind,'pid':process.pid,'source_commit':manifest['source_commit'],
            'archive_manifest_sha256':sha((args.archive/'manifest.json').read_bytes()),
            'launcher_exit':code,'native_exit':result.get('exit_code'),'native_passed':result.get('passed'),
            'seconds':time.time()-started,'test_file':case}
    (args.output/(name+'.process.json')).write_text(json.dumps(record,indent=2)+'\n')
    print(json.dumps(record),flush=True)
    return record


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--archive',type=Path,required=True);parser.add_argument('--snapshot',type=Path,required=True);parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--activity',choices=ACTIVITIES,action='append');parser.add_argument('--case',choices=('gameplay','controls'),action='append')
    args=parser.parse_args();args.archive=args.archive.resolve()
    manifest=verify(args.archive)
    assert sha((args.snapshot/'manifest.json').read_bytes())==manifest['snapshot_manifest_sha256']
    assert not args.output.exists();args.output.mkdir(parents=True)
    tasks=[(activity,kind) for activity in args.activity or ACTIVITIES for kind in args.case or ('gameplay','controls')]
    assert tasks
    with ThreadPoolExecutor(max_workers=2) as pool:
        records=list(pool.map(lambda task:run(*task,args,manifest),tasks))
    if not all(record['launcher_exit']==record['native_exit']==0 and record['native_passed'] for record in records):raise SystemExit(1)
    print(json.dumps({'completed_cases':len(records)}),flush=True)
