#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run one public contract against a physically frozen source phase."""
import argparse,hashlib,json,shutil,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
BASE=ROOT/'.scratch/pt-pt/public-level-contracts'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def freeze(name):
 target=BASE/'sources'/name
 if target.exists():raise ValueError('Source phase already frozen')
 for item in ['src/activities','poqm/pt','CMakeLists.txt','tools/run-native-qml-case.py','tools/run-native-qml-supervised.py','tools/native_qml_resources.py','tools/native_qml_supervision.py']:
  p=ROOT/item;q=target/item;q.parent.mkdir(parents=True,exist_ok=True)
  if p.is_dir():shutil.copytree(p,q)
  else:shutil.copyfile(p,q)
 files={str(p.relative_to(target)):sha(p) for p in sorted(target.rglob('*')) if p.is_file()}
 (target/'manifest.json').write_text(json.dumps(files,indent=2)+'\n')
 return target
def run(phase,activity,qml,total,label=None):
 out=BASE/'runs'/((label or activity)+'-'+phase)
 log_path=out.parent/(out.name+'.log')
 # Refuse before verifying sources, creating cases or opening any prior log.
 if out.exists() or out.is_symlink():raise FileExistsError('Output already exists: '+str(out))
 if log_path.exists() or log_path.is_symlink():raise FileExistsError('Parent log already exists: '+str(log_path))
 source=BASE/'sources'/phase
 for f,h in json.loads((source/'manifest.json').read_text()).items():
  if sha(source/f)!=h:raise ValueError('Frozen source corrupted: '+f)
 case=BASE/'cases'/((label or activity)+'.qml');case.parent.mkdir(exist_ok=True)
 data=(ROOT/'tests/public_levels/contract.qml').read_text().replace('__TOTAL__',str(total))
 if not case.exists():case.write_text(data)
 out.parent.mkdir(exist_ok=True)
 cmd=[sys.executable,str(source/'tools/run-native-qml-supervised.py'),'--source-root',str(source),'--activity',activity,'--qml-file',str(source/'src/activities'/qml),'--case',str(case),'--output',str(out),'--resource-snapshot',str(BASE/'runtime-snapshot'),'--offline','--keep-deployment','--timeout','60']
 with log_path.open('x') as log:p=subprocess.run(cmd,stdout=log,stderr=subprocess.STDOUT)
 if p.returncode==2:return p.returncode
 if not out.exists():raise RuntimeError('Launcher did not make receipt; inspect parent log')
 receipt=out/'result.json'
 with (out/'tool-status.json').open('x') as status:
  status.write(json.dumps({'kind':'observed-subprocess-exit','exit_code':p.returncode,'native_receipt_sha256':sha(receipt),'supervisor_sha256':sha(source/'tools/run-native-qml-supervised.py')},indent=2)+'\n')
 print(activity,phase,p.returncode,json.loads(receipt.read_text()).get('case_result'),flush=True)
 return p.returncode
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('phase');p.add_argument('--freeze',action='store_true');p.add_argument('--activity');p.add_argument('--qml');p.add_argument('--total',type=int);p.add_argument('--label');a=p.parse_args()
 if a.freeze:freeze(a.phase)
 if a.activity:raise SystemExit(run(a.phase,a.activity,a.qml,a.total,a.label))
