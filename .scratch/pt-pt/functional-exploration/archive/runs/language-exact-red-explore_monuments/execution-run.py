#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run an already frozen task-84 phase without replacing prior evidence."""
import argparse,hashlib,json,os,subprocess,sys,tempfile
from pathlib import Path
from phase import ROOT,verify,sha

def freeze_case(case):
 raw=case.read_bytes();folder=ROOT/'build/functional-exploration/cases';folder.mkdir(parents=True,exist_ok=True)
 target=folder/(hashlib.sha256(raw).hexdigest()+'.qml')
 if target.exists():
  if target.is_symlink() or target.read_bytes()!=raw:raise ValueError('Frozen case corrupted')
  return target
 with tempfile.NamedTemporaryFile(dir=folder,delete=False) as stream:
  stream.write(raw);temporary=Path(stream.name)
 try:
  try:os.link(temporary,target)
  except FileExistsError:
   if target.is_symlink() or target.read_bytes()!=raw:raise ValueError('Frozen case differs')
 finally:temporary.unlink()
 return target

def run(activity,phase,case,output,timeout=300):
 output=output.resolve();log=output.with_name(output.name+'.parent.log')
 if output.exists() or output.is_symlink() or log.exists() or log.is_symlink():raise FileExistsError('Use a fresh evidence destination')
 runner_bytes=Path(__file__).read_bytes();runner_hash=hashlib.sha256(runner_bytes).hexdigest()
 source=ROOT/'build/functional-exploration/sources'/phase;verify(source)
 case=freeze_case(case);case_bytes=case.read_bytes()
 snapshot=ROOT/'build/functional-exploration/runtime-snapshot'
 output.parent.mkdir(parents=True,exist_ok=True)
 command=[sys.executable,str(source/'tools/run-native-qml-supervised.py'),'--source-root',str(source),'--activity',activity,'--qml-file',str(source/'src/activities/explore_farm_animals/ExploreLevels.qml'),'--case',str(case.resolve()),'--output',str(output),'--resource-snapshot',str(snapshot),'--offline','--keep-deployment','--timeout',str(timeout)]
 with log.open('x') as stream:process=subprocess.run(command,stdout=stream,stderr=subprocess.STDOUT)
 if process.returncode==2:return 2
 receipt=output/'result.json'
 if not receipt.is_file():raise RuntimeError('Native receipt missing; inspect parent log')
 with (output/'supervisor-status.json').open('x') as stream:stream.write(json.dumps({'kind':'observed-subprocess-exit','exit_code':process.returncode,'native_receipt_sha256':sha(receipt),'supervisor_sha256':sha(source/'tools/run-native-qml-supervised.py'),'runner_sha256':runner_hash},indent=2)+'\n')
 with (output/'execution-run.py').open('xb') as stream:stream.write(runner_bytes)
 shutil_case=output/'case.qml'
 with shutil_case.open('xb') as stream:stream.write(case_bytes)
 print(json.dumps({'activity':activity,'returncode':process.returncode,'output':str(output)}));return process.returncode
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--activity',required=True);p.add_argument('--phase',required=True);p.add_argument('--case',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--timeout',type=int,default=300);a=p.parse_args();raise SystemExit(run(a.activity,a.phase,a.case,a.output,a.timeout))
