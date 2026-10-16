#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run visible magic-hat cases with immutable inputs and post-wait status."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import uuid
from phase import verify_source

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent


def main():
    if not __debug__:raise SystemExit('Magic hat validation requires assertions; Python -O is rejected')
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--source-root',type=Path,required=True);parser.add_argument('--snapshot',type=Path,required=True);parser.add_argument('--activity',choices=['magic-hat-minus','magic-hat-plus'],required=True);parser.add_argument('--output',type=Path,required=True);parser.add_argument('--controls',action='store_true');args=parser.parse_args()
    source=args.source_root.resolve();output=args.output.resolve();verify_source(source)
    if output.exists():parser.error('Use a new output directory')
    text=(HERE/('controls.qml' if args.controls else 'gameplay.qml')).read_text().replace('__VISIBLE__',(HERE/'visible.fragment').read_text())
    case=ROOT/'build/magic-cases'/(hashlib.sha256(text.encode()).hexdigest()+'.qml');case.parent.mkdir(parents=True,exist_ok=True)
    if case.exists():assert case.read_text()==text
    else:case.write_text(text)
    command=[sys.executable,str(source/'tools/run-native-qml-supervised.py'),'--source-root',str(source),'--resource-snapshot',str(args.snapshot.resolve()),'--activity',args.activity,'--qml-file',str(source/'src/activities/magic-hat-minus/MagicHat.qml'),'--case',str(case),'--output',str(output),'--offline','--timeout','1200','--result-marker','NATIVE_MAGIC_RESULT']
    environment=dict(os.environ,PYTHONDONTWRITEBYTECODE='1',PYTHONPYCACHEPREFIX=str(ROOT/'build/magic-python-cache'/uuid.uuid4().hex))
    completed=subprocess.run(command,env=environment)
    if output.exists():
        shutil.copyfile(case,output/'case.qml')
        receipt=output/'result.json';status=output/'launcher-status.json'
        observed={'kind':'observed-supervisor-subprocess-exit','exit_code':completed.returncode,'native_receipt_sha256':hashlib.sha256(receipt.read_bytes()).hexdigest() if receipt.exists() else None,'launcher_status_sha256':hashlib.sha256(status.read_bytes()).hexdigest() if status.exists() else None,'case_sha256':hashlib.sha256(case.read_bytes()).hexdigest(),'supervisor_sha256':hashlib.sha256((source/'tools/run-native-qml-supervised.py').read_bytes()).hexdigest()}
        (output/'supervisor-exit.json').write_text(json.dumps(observed,indent=2)+'\n')
    return completed.returncode

if __name__=='__main__':raise SystemExit(main())
