#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Rerun adversarial proof tests in a copied, offline Python-only container."""
import argparse,json,shutil,subprocess,tempfile,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
BOOTSTRAP='''import ctypes.util, pathlib, runpy, shutil, sys
if pathlib.Path('/home/proteu/Projetos').exists() or shutil.which('git') or ctypes.util.find_library('Qt6Core'):
 raise RuntimeError('Isolation lacks required absence of original tree, Git or Qt')
print('ISOLATION: original tree absent; Git absent; Qt absent; copied proof roots only',flush=True)
sys.argv=['unittest','discover','-s','tests/functional_exploration','-p','test_*.py','-v']
runpy.run_module('unittest',run_name='__main__')
'''
def main():
 parser=argparse.ArgumentParser();parser.add_argument('--output',type=Path,default=ROOT/'.scratch/pt-pt/functional-exploration/portable-verification.json');args=parser.parse_args();out=args.output.resolve()
 if out.exists() or out.is_symlink():raise FileExistsError('Use a fresh verification report destination')
 image='python:3.12-slim';identity=subprocess.run(['docker','image','inspect','--format','{{.Id}}',image],capture_output=True,text=True,check=True).stdout.strip();results=[]
 with tempfile.TemporaryDirectory(prefix='task84-portable-') as temporary:
  suite=Path(temporary)/'code';target=suite/'tests/functional_exploration';target.mkdir(parents=True)
  for p in Path(__file__).parent.iterdir():
   if p.is_file():shutil.copyfile(p,target/p.name)
  for name in ['archive','supplement-archive','supplement2-archive','supplement3-archive']:
   shutil.copytree(ROOT/'.scratch/pt-pt/functional-exploration'/name,suite/'.scratch/pt-pt/functional-exploration'/name)
  # TemporaryDirectory defaults to0700; grant the unprivileged container read access.
  Path(temporary).chmod(0o755)
  for optimize in [False,True]:
   argv=['docker','run','--rm','--pull=never','--network=none','--read-only','--cap-drop=ALL','--security-opt=no-new-privileges','--user','1000:1000','--tmpfs','/tmp:rw,mode=1777,size=2g','--mount',f'type=bind,src={suite},dst=/suite/code,readonly','--workdir','/suite/code','--env','PYTHONDONTWRITEBYTECODE=1',image,'python',*(['-O'] if optimize else []),'-c',BOOTSTRAP]
   start=time.monotonic();run=subprocess.run(argv,capture_output=True,text=True);results.append({'optimized':optimize,'image':image,'image_id':identity,'argv':argv,'exit_code':run.returncode,'stdout':run.stdout,'stderr':run.stderr,'seconds':round(time.monotonic()-start,3)});print(json.dumps(results[-1]),flush=True)
   if run.returncode:raise RuntimeError('Isolated proof tests failed')
 with out.open('x') as stream:stream.write(json.dumps(results,indent=2)+'\n')
if __name__=='__main__':main()
