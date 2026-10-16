#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Record the actual runner return AFTER wait, separately from Qt and launcher."""
import argparse,hashlib,json,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--output',type=Path,required=True);args,_=p.parse_known_args()
 if args.output.exists():p.error('Output must be new')
 process=subprocess.run([sys.executable,str(ROOT/'tests/functional_orientation/run.py'),*sys.argv[1:]])
 receipt=args.output/'result.json';case=args.output/'case.qml'
 if process.returncode!=2 and receipt.is_file() and case.is_file():
  status={'format':1,'kind':'observed-runner-exit-after-wait','exit_code':process.returncode,'native_receipt_sha256':sha(receipt),'case_sha256':sha(case),'runner_sha256':sha(ROOT/'tests/functional_orientation/run.py'),'capture_sha256':sha(Path(__file__))}
  with (args.output/'tool-status.json').open('x') as stream:stream.write(json.dumps(status,indent=2)+'\n')
 return process.returncode
if __name__=='__main__':raise SystemExit(main())
