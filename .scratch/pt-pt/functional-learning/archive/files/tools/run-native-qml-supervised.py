#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Wait for the native launcher and preserve its exit status beside its receipt.

Accepts the native launcher's options; --launcher can select a historical copy.
The output directory must be new. Redirect parent logs outside that directory.
"""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--launcher',type=Path,default=Path(__file__).with_name('run-native-qml-case.py'))
    parser.add_argument('--case',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    args,forwarded=parser.parse_known_args()
    output=args.output.resolve()
    if output.exists():parser.error('Use a new output directory')
    launcher_hash=sha(args.launcher)
    case_hash=sha(args.case)
    command=[sys.executable,str(args.launcher),*forwarded,'--case',str(args.case),'--output',str(output)]
    child=subprocess.run(command)
    if output.is_dir():
        receipt=output/'result.json'
        status={'format':1,'kind':'observed-subprocess-exit','exit_code':child.returncode,
                'native_receipt_sha256':sha(receipt) if receipt.is_file() else None,
                'case_sha256':case_hash,'launcher_sha256':launcher_hash}
        with (output/'launcher-status.json').open('x') as stream:
            stream.write(json.dumps(status,indent=2)+'\n')
    return child.returncode


if __name__=='__main__':raise SystemExit(main())
