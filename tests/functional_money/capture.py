#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Capture the files Qt actually exposes from a sealed money snapshot."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
from phase import freeze

ROOT=Path(__file__).resolve().parents[2]

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--revision',required=True)
    parser.add_argument('--snapshot',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    source=freeze(args.revision)
    args.output.mkdir(parents=True,exist_ok=True)
    inspector=ROOT/'build/money-rcc-inventory'
    flags=subprocess.check_output(['pkg-config','--cflags','--libs','Qt6Core'],text=True).split()
    subprocess.run(['g++','-std=c++17','-fPIC',str(ROOT/'tools/pt-pt-audio/rcc_inventory.cpp'),'-o',str(inspector),*flags],check=True)
    canonical={}
    for name in ['core','money','money_cents','money_back','money_back_cents']:
        path=args.snapshot/'share/gcompris-qt/rcc'/(name+'.rcc')
        canonical[name]={'rcc_sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'files':json.loads(subprocess.check_output([str(inspector),str(path)]))}
    (args.output/'rcc-identities.json').write_text(json.dumps(canonical,indent=2)+'\n')
    targets=set(re.findall(r'"qrc:/gcompris/(src/activities/(?:babymatch|babyshapes)/[^\"]+)"',(source/'src/activities/money/moneyConstants.js').read_text()))
    targets|={'src/activities/family/resource/background.svg','src/activities/mosaic/resource/tux.svg'}
    external={}
    for activity in sorted({path.split('/')[2] for path in targets}):
        path=args.snapshot/'share/gcompris-qt/rcc'/(activity+'.rcc')
        rows=json.loads(subprocess.check_output([str(inspector),str(path)]))
        external[activity]={'rcc_sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'files':[row for row in rows if row['path'].removeprefix(':/gcompris/') in targets]}
    assert sum(len(value['files']) for value in external.values())==len(targets)==17
    (args.output/'external-identities.json').write_text(json.dumps(external,indent=2)+'\n')
    for filename,content in [('source-manifest.json',(source/'source-manifest.json').read_bytes()),('snapshot-manifest.json',(args.snapshot/'manifest.json').read_bytes())]:
        (args.output/filename).write_bytes(content)

if __name__=='__main__':main()
