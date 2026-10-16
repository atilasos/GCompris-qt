#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Visible pattern and polygon cases: preserve actual supervisor return after wait and exact case."""
import argparse,hashlib,json,shutil,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--case',type=Path,required=True);parser.add_argument('--output',type=Path,required=True);args,_=parser.parse_known_args()
 if args.output.exists() or args.output.is_symlink():parser.error('Output must be new')
 if not args.case.is_file():parser.error('Case must exist')
 digest=sha(args.case);command=[sys.executable,str(ROOT/'tools/run-native-qml-supervised.py'),*sys.argv[1:]];process=subprocess.run(command)
 receipt=args.output/'result.json';status=args.output/'launcher-status.json'
 if not receipt.is_file() or not status.is_file():return process.returncode or 1
 observed=json.loads(status.read_text())
 if observed.get('case_sha256')!=digest or digest!=sha(args.case):raise ValueError('Executed case identity changed')
 shutil.copyfile(args.case,args.output/'case.qml')
 record={'format':1,'kind':'observed-supervisor-return-after-wait','exit_code':process.returncode,'case_sha256':digest,'native_receipt_sha256':sha(receipt),'launcher_status_sha256':sha(status),'capture_sha256':sha(Path(__file__))}
 with (args.output/'tool-status.json').open('x') as stream:stream.write(json.dumps(record,indent=2)+'\n')
 return process.returncode
if __name__=='__main__':raise SystemExit(main())
