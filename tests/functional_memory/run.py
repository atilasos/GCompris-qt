#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Verify three memory activities offline with original Qt cards and private RCCs.

The inherited MemoryCommon component is instrumented by the existing native launcher;
activity RCCs are rebuilt here so data never come from a stale build.
"""
import argparse
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
import uuid
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]
ACTIVITIES = ['memory-wordnumber', 'memory-case-association', 'memory-enumerate']
CASES = {'gameplay': 420, 'controls': 40, 'keyboard_home': 20, 'restart': 30}
def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()
def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--binary', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--case', choices=['all', *CASES], default='all')
    args = parser.parse_args()
    if args.output.exists() and any(args.output.iterdir()):
        parser.error('Use a new empty output directory')
    if not args.binary.is_file():
        parser.error('A built binary is required')
    args.output.mkdir(parents=True, exist_ok=True)
    output = args.output.resolve()
    with (output/'data.log').open('w') as log:
        subprocess.run(['node', '--test', 'tests/functional_memory/data.test.mjs'], cwd=ROOT,
                       stdout=log, stderr=subprocess.STDOUT, check=True)
    deployment = ROOT/'build/memory-native-base'/uuid.uuid4().hex
    (deployment/'bin').mkdir(parents=True)
    binary=deployment/'bin/gcompris-qt'
    shutil.copy2(args.binary,binary)
    original=args.binary.resolve().parent.parent/'share/gcompris-qt'
    share=deployment/'share/gcompris-qt'
    for name in ['rcc','translations']:
        (share/name).mkdir(parents=True)
        for path in (original/name).iterdir():
            if name!='rcc' or path.name not in [activity+'.rcc' for activity in ACTIVITIES+['core']]:
                (share/name/path.name).symlink_to(path)
    if (original.parent.parent/'lib/qml').exists():
        (deployment/'lib').mkdir()
        (deployment/'lib/qml').symlink_to(original.parent.parent/'lib/qml')
    rcc_hashes={}
    source_hashes={}
    for activity in ACTIVITIES+['core']:
        qrc=ET.Element('RCC')
        resources=ET.SubElement(qrc,'qresource',prefix='/gcompris/src/core' if activity=='core' else '/gcompris/src/activities/'+activity)
        source=ROOT/'src/core' if activity=='core' else ROOT/'src/activities'/activity
        for path in sorted(source.rglob('*')):
            if path.is_file():
                ET.SubElement(resources,'file',alias=path.relative_to(source).as_posix()).text=str(path)
                source_hashes[str(path.relative_to(ROOT))]=sha(path)
        qrc_path=deployment/(activity+'.qrc')
        ET.ElementTree(qrc).write(qrc_path,encoding='utf-8')
        rcc=share/'rcc'/(activity+'.rcc')
        subprocess.run(['/usr/lib/qt6/libexec/rcc','--binary',str(qrc_path),'-o',str(rcc)],check=True)
        rcc_hashes[activity]=sha(rcc)
    # A single sealed snapshot includes the fresh datasets and every dependency.
    # Mapped inactive RCCs must not point back to a mutable build either.
    snapshot=deployment/'resource-snapshot'
    with (output/'snapshot.log').open('w') as log:
        subprocess.run([sys.executable,str(ROOT/'tools/native_qml_resources.py'),
            '--binary',str(binary),'--output',str(snapshot)],stdout=log,
            stderr=subprocess.STDOUT,check=True)
    def run(task):
        activity,case=task
        process=subprocess.run([sys.executable,str(ROOT/'tools/run-native-qml-case.py'),
            '--source-root',str(ROOT),'--binary',str(binary),'--resource-snapshot',str(snapshot),'--activity',activity,
            '--qml-file','src/activities/memory/MemoryCommon.qml','--case',f'tests/functional_memory/{case}.qml',
            '--output',str(output/activity/case),'--timeout',str(CASES[case]),
            '--result-marker','NATIVE_MEMORY_RESULT','--offline'],cwd=ROOT,capture_output=True,text=True)
        path=output/activity/case/'result.json'
        return {'activity':activity,'case':case,'exit_code':process.returncode,'result_sha256':sha(path) if path.exists() else None,
                'launcher_output':process.stdout+process.stderr}
    chosen=list(CASES) if args.case=='all' else [args.case]
    with ThreadPoolExecutor(max_workers=4) as executor:
        results=list(executor.map(run,[(activity,case) for activity in ACTIVITIES for case in chosen]))
    summary={'format':1,'source_commit':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
        'source_files_sha256':source_hashes,'activity_rcc_sha256':rcc_hashes,
        'binary_sha256':sha(binary),'resource_snapshot':str(snapshot),
        'snapshot_json_sha256':{path.name:sha(path) for path in snapshot.glob('*.json')},'cases':results,
        'passed':all(row['exit_code']==0 for row in results),
        'scope':'Native actions in named cases only. Global Linux, physical keyboard/audio, Windows and teacher approval pending.'}
    (output/'summary.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({'passed':summary['passed'],'cases':len(results),'output':str(output)}))
    return 0 if summary['passed'] else 1
if __name__=='__main__':
    raise SystemExit(main())
