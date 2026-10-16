#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Verify wordsgame offline using native cases and a fresh private source RCC.

The inherited Gletters component is instrumented by the existing native launcher;
wordsgame's own RCC is also built here so its data never come from a stale build.
"""
import argparse
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import uuid
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]
CASES = {'gameplay': 600, 'configurations': 120, 'missed': 100, 'controls': 40}
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
        subprocess.run(['node', '--test', 'tests/functional_words/data.test.mjs'], cwd=ROOT,
                       stdout=log, stderr=subprocess.STDOUT, check=True)
    adapter = ROOT/'build/functional-input'
    subprocess.run(['cmake', '-S', str(ROOT/'tests/functional_letters/native_input'), '-B', str(adapter)], check=True)
    subprocess.run(['cmake', '--build', str(adapter), '-j2'], check=True)
    with (output/'adapter.log').open('w') as log:
        subprocess.run(['/usr/lib/qt6/bin/qmltestrunner', '-input', str(adapter/'check')],
                       env=dict(os.environ, QT_QPA_PLATFORM='offscreen'), stdout=log,
                       stderr=subprocess.STDOUT, check=True)
    deployment = ROOT/'build/word-native-base'/uuid.uuid4().hex
    (deployment/'bin').mkdir(parents=True)
    binary=deployment/'bin/gcompris-qt'
    shutil.copy2(args.binary,binary)
    original=args.binary.resolve().parent.parent/'share/gcompris-qt'
    share=deployment/'share/gcompris-qt'
    for name in ['rcc','translations']:
        (share/name).mkdir(parents=True)
        for path in (original/name).iterdir():
            if name!='rcc' or path.name!='wordsgame.rcc':
                (share/name/path.name).symlink_to(path)
    qrc=ET.Element('RCC')
    resources=ET.SubElement(qrc,'qresource',prefix='/gcompris/src/activities/wordsgame')
    source=ROOT/'src/activities/wordsgame'
    for path in sorted(source.rglob('*')):
        if path.is_file():
            ET.SubElement(resources,'file',alias=path.relative_to(source).as_posix()).text=str(path)
    qrc_path=deployment/'wordsgame.qrc'
    ET.ElementTree(qrc).write(qrc_path,encoding='utf-8')
    rcc=share/'rcc/wordsgame.rcc'
    subprocess.run(['/usr/lib/qt6/libexec/rcc','--binary',str(qrc_path),'-o',str(rcc)],check=True)
    def run(case):
        process=subprocess.run([sys.executable,str(ROOT/'tools/run-native-qml-case.py'),
            '--source-root',str(ROOT),'--binary',str(binary),'--activity','wordsgame',
            '--qml-file','src/activities/gletters/Gletters.qml','--case',f'tests/functional_words/{case}.qml',
            '--output',str(output/case),'--timeout',str(CASES[case]),
            '--result-marker','NATIVE_WORDS_RESULT','--offline'],cwd=ROOT,capture_output=True,text=True)
        path=output/case/'result.json'
        return {'case':case,'exit_code':process.returncode,'result_sha256':sha(path) if path.exists() else None,
                'launcher_output':process.stdout+process.stderr}
    chosen=list(CASES) if args.case=='all' else [args.case]
    with ThreadPoolExecutor(max_workers=4) as executor:
        results=list(executor.map(run,chosen))
    summary={'format':1,'source_commit':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
        'source_data_sha256':sha(source/'resource/default-pt.json'),'wordsgame_rcc_sha256':sha(rcc),
        'binary_sha256':sha(binary),'adapter_source_sha256':sha(ROOT/'tests/functional_letters/native_input/input.cpp'),
        'adapter_binary_sha256':sha(adapter/'libfunctionalinput.so'),'cases':results,
        'passed':all(row['exit_code']==0 for row in results),
        'scope':'Native actions in named cases only. Global Linux, physical keyboard/audio, Windows and teacher approval pending.'}
    (output/'summary.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({'passed':summary['passed'],'cases':len(results),'output':str(output)}))
    return 0 if summary['passed'] else 1
if __name__=='__main__':
    raise SystemExit(main())
