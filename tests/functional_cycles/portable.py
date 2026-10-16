#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Copy physical evidence and verify it in Python without the checkout or Qt."""
import json,shutil,subprocess,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
BASE=ROOT/'.scratch/pt-pt/functional-cycles'
IMAGE='sha256:a6e34c598f2467ed0e9a8d349809fcd8b5c603269512df273a0bb1784edc11b1'
HARNESS='''import json,pathlib,shutil,subprocess,sys
if shutil.which('git') or shutil.which('rcc') or pathlib.Path('/home/proteu/Projetos').exists():
 raise SystemExit('Unexpected checkout or external tools')
reports=[]
for mode in [[],['-O']]:
 command=[sys.executable,*mode,'/proof/code/audit.py','--evidence','/proof/evidence']
 run=subprocess.run(command,text=True,capture_output=True)
 if run.returncode:raise SystemExit(run.stderr)
 reports.append(json.loads(run.stdout))
print(json.dumps({'passed':True,'modes':['normal','-O'],'reports':reports,'checkout_available':False,'git_available':False,'qt_available':False}))
'''
def main():
 index=json.loads((BASE/'index.json').read_text())
 with tempfile.TemporaryDirectory(prefix='cycles-portable-') as tmp:
  root=Path(tmp)
  for relative in ['index.json',*index['files']]:
   target=root/'evidence'/relative;target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(BASE/relative,target)
  (root/'code').mkdir()
  for name in ['audit.py','config.py','lock_plan.py']:shutil.copyfile(ROOT/'tests/functional_cycles'/name,root/'code'/name)
  command=['docker','run','--rm','--pull=never','--network','none','--read-only','--tmpfs','/tmp','-e','PYTHONDONTWRITEBYTECODE=1','-v',str(root)+':/proof:ro',IMAGE,'python3','-c',HARNESS]
  run=subprocess.run(command,capture_output=True,text=True)
  if run.returncode:raise SystemExit(run.stderr)
  print(run.stdout,end='')
if __name__=='__main__':main()
