#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Verify a physical copy offline in Python3.12 with a pinned Pillow wheel."""
import argparse,json,shutil,subprocess,tempfile,time
from pathlib import Path
from store import require,sha
ROOT=Path(__file__).resolve().parents[2]
BOOTSTRAP='''import ctypes.util,json,pathlib,shutil,sys
sys.path.insert(0,'/suite/code/tests/patterns_audit')
if pathlib.Path('/home/proteu/Projetos').exists() or shutil.which('git') or ctypes.util.find_library('Qt6Core'):
 raise RuntimeError('Original tree, Git or Qt unexpectedly available')
from PIL import __version__
if __version__!='12.1.1':raise RuntimeError('Pinned Pillow not installed')
from adversarial import exercise
print(json.dumps({'isolation':'copied proof/code only; no network/Git/Qt/original tree','python':sys.version,'pillow':__version__,'checks':exercise(pathlib.Path('/suite/evidence'))}),flush=True)
'''
def main():
 p=argparse.ArgumentParser();p.add_argument('--evidence',type=Path,required=True);p.add_argument('--wheel',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
 if a.output.exists() or a.output.is_symlink():raise FileExistsError('Use a fresh portable report')
 dependency=json.loads(Path(__file__).with_name('dependency.json').read_text());require(a.wheel.name==dependency['filename'] and sha(a.wheel.read_bytes())==dependency['sha256'],'Pinned PyPI wheel bytes')
 image='python:3.12-slim';inspect=subprocess.run(['docker','image','inspect','--format','{{.Id}}',image],capture_output=True,text=True,check=True);identity=inspect.stdout.strip();require(identity=='sha256:a6e34c598f2467ed0e9a8d349809fcd8b5c603269512df273a0bb1784edc11b1','Pinned Python image identity');records=[]
 with tempfile.TemporaryDirectory(prefix='visual copied capsule ') as temporary:
  suite=Path(temporary);suite.chmod(0o755);shutil.copytree(a.evidence,suite/'evidence');code=suite/'code/tests'
  for name in ['patterns_audit','pattern_grid_solver','polygon_geometry_oracle','polygon_observation_audit','pattern_controls_audit','pattern_scene_pixels']:
   shutil.copytree(ROOT/'tests'/name,code/name,ignore=shutil.ignore_patterns('__pycache__'))
  (suite/'deps').mkdir();shutil.copyfile(a.wheel,suite/'deps'/a.wheel.name)
  code_hashes={p.relative_to(suite/'code').as_posix():sha(p.read_bytes()) for p in sorted((suite/'code').rglob('*')) if p.is_file()}
  for optimized in [False,True]:
   inner='import os,subprocess,sys;subprocess.run([sys.executable,"-m","pip","install","--no-index","--no-deps","--no-compile","--no-cache-dir","--disable-pip-version-check","--target","/tmp/pillow","/suite/deps/'+a.wheel.name+'"],check=True);os.environ["PYTHONPATH"]="/tmp/pillow";subprocess.run([sys.executable,'+('"-O",' if optimized else '')+'"-c",'+repr(BOOTSTRAP)+'],check=True)'
   command=['docker','run','--rm','--pull=never','--network=none','--read-only','--cap-drop=ALL','--security-opt=no-new-privileges','--user','1000:1000','--tmpfs','/tmp:rw,exec,mode=1777,size=2g','--mount',f'type=bind,src={suite},dst=/suite,readonly','--env','PYTHONDONTWRITEBYTECODE=1',identity,'python','-c',inner]
   start=time.monotonic();run=subprocess.run(command,capture_output=True,text=True);row={'optimized':optimized,'copied_code_sha256':code_hashes,'capture_sha256':sha((suite/'evidence/capture.json').read_bytes()),'image_tag':image,'image_id':identity,'wheel_sha256':dependency['sha256'],'argv':command,'exit_code':run.returncode,'stdout':run.stdout,'stderr':run.stderr,'seconds':round(time.monotonic()-start,3)};records.append(row);print(json.dumps(row),flush=True);require(run.returncode==0,'Offline portable audit failed')
 with a.output.open('x') as stream:stream.write(json.dumps(records,indent=2)+'\n')
if __name__=='__main__':main()
