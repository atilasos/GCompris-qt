#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Observe the task-84 runner's actual return, then preserve a fresh receipt."""
import argparse,hashlib,json,subprocess,sys
from pathlib import Path

def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);args,_=p.parse_known_args();output=args.output.resolve()
 if output.exists() or output.is_symlink():p.error('Output already exists')
 source=Path(__file__).resolve();runner=source.with_name('run.py');runner_hash=sha(runner);capture_bytes=source.read_bytes()
 process=subprocess.run([sys.executable,str(runner),*sys.argv[1:]])
 receipt=output/'result.json';case=output/'case.qml'
 if process.returncode!=2 and receipt.is_file() and case.is_file():
  with (output/'tool-status.json').open('x') as stream:stream.write(json.dumps({'kind':'observed-runner-exit-after-wait','exit_code':process.returncode,'native_receipt_sha256':sha(receipt),'case_sha256':sha(case),'runner_sha256':runner_hash,'capture_sha256':hashlib.sha256(capture_bytes).hexdigest()},indent=2)+'\n')
  with (output/'execution-capture.py').open('xb') as stream:stream.write(capture_bytes)
 return process.returncode
if __name__=='__main__':raise SystemExit(main())
