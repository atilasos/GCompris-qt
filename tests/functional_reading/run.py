#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run the two reading directions in real Qt, with private resources/profiles."""
import argparse
import hashlib
import json
import shutil
import uuid
import xml.etree.ElementTree as ET
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[2]
def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--binary',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True,help='new parent directory for all four runs')
    args=parser.parse_args()
    if args.output.exists():parser.error('Use a new output directory')
    subprocess.run(['node','--test',str(ROOT/'tests/functional_reading/data.test.mjs')],check=True)
    args.output.mkdir(parents=True)
    # The reading module consumes wordsgame's PT list. Compile that dependency
    # privately too, so a source vocabulary fix cannot be masked by an old RCC.
    deployment=ROOT/'build/native-reading'/uuid.uuid4().hex
    binary=deployment/'bin/gcompris-qt'
    binary.parent.mkdir(parents=True)
    shutil.copy2(args.binary,binary)
    original=args.binary.resolve().parent.parent/'share/gcompris-qt'
    share=deployment/'share/gcompris-qt'
    for name in ['rcc','translations']:
        (share/name).mkdir(parents=True)
        for path in (original/name).iterdir():(share/name/path.name).symlink_to(path)
    folder=ROOT/'src/activities/wordsgame'
    qrc=ET.Element('RCC')
    resources=ET.SubElement(qrc,'qresource',prefix='/gcompris/src/activities/wordsgame')
    for path in sorted(folder.rglob('*')):
        if path.is_file():ET.SubElement(resources,'file',alias=path.relative_to(folder).as_posix()).text=str(path)
    qrc_path=deployment/'wordsgame.qrc'
    ET.ElementTree(qrc).write(qrc_path,encoding='utf-8')
    resource=share/'rcc/wordsgame.rcc'
    resource.unlink()
    subprocess.run(['/usr/lib/qt6/libexec/rcc','--binary',str(qrc_path),'-o',str(resource)],check=True)
    fingerprints={str(path.relative_to(ROOT)):hashlib.sha256(path.read_bytes()).hexdigest() for path in [
        ROOT/'src/activities/readingh/readingh.js',folder/'resource/default-pt.json']}
    fingerprints['private_wordsgame_rcc_sha256']=hashlib.sha256(resource.read_bytes()).hexdigest()
    (args.output/'dependencies.json').write_text(json.dumps(fingerprints,indent=2)+'\n')
    def run(activity):
        outcomes=[]
        for case in ['complete','controls']:
            command=[sys.executable,str(ROOT/'tools/run-native-qml-case.py'),'--binary',str(binary),
                '--activity',activity,'--qml-file',str(ROOT/'src/activities/readingh/Readingh.qml'),
                '--case',str(ROOT/f'tests/functional_reading/{case}.qml'),'--output',str(args.output.resolve()/f'{activity}-{case}'),
                '--result-marker','NATIVE_READING_RESULT','--offline','--timeout','600']
            outcomes.append(subprocess.run(command).returncode)
        return all(code==0 for code in outcomes)
    with ThreadPoolExecutor(max_workers=2) as executor:
        results=list(executor.map(run,['readingh','readingv']))
    return 0 if all(results) else 1
if __name__=='__main__':raise SystemExit(main())
