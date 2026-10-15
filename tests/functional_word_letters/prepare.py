#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Compile current language resources privately and seal independent runtimes."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
import xml.etree.ElementTree as ET

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from native_qml_resources import create_snapshot, verify_snapshot


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--base-snapshot',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    if args.output.exists():parser.error('Use a new output directory')
    verify_snapshot(args.base_snapshot)
    runtime=args.output/'runtime'
    shutil.copytree(args.base_snapshot,runtime)
    source=ROOT/'src/activities/lang'
    qrc=ET.Element('RCC')
    resources=ET.SubElement(qrc,'qresource',prefix='/gcompris/src/activities/lang')
    for path in sorted(source.rglob('*')):
        if path.is_file():ET.SubElement(resources,'file',alias=path.relative_to(source).as_posix()).text=str(path)
    qrc_path=args.output/'lang.qrc'
    ET.ElementTree(qrc).write(qrc_path,encoding='utf-8')
    rcc=runtime/'share/gcompris-qt/rcc/lang.rcc'
    subprocess.run(['/usr/lib/qt6/libexec/rcc','--binary',str(qrc_path),'-o',str(rcc)],check=True)
    create_snapshot(runtime/'bin/gcompris-qt',args.output/'full-snapshot')
    # This is the product's genuine fallback: external word assets unavailable.
    shutil.rmtree(runtime/'share/gcompris-qt/rcc/data3/words')
    for full_bundle in (runtime/'share/gcompris-qt/rcc/data3').glob('full-*.rcc'):
        full_bundle.unlink()
    create_snapshot(runtime/'bin/gcompris-qt',args.output/'sample-snapshot')
    metadata={'lang_rcc_sha256':hashlib.sha256(rcc.read_bytes()).hexdigest(),
        'content_pt_sha256':hashlib.sha256((source/'resource/content-pt.json').read_bytes()).hexdigest(),
        'sample_environment':'External words asset directory and full bundle absent; source sample words and images remain; snapshots sealed separately.'}
    (args.output/'build.json').write_text(json.dumps(metadata,indent=2)+'\n')


if __name__=='__main__':main()
