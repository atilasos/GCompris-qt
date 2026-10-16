#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Make a new physical supplement without changing the original capsule."""
import hashlib,json,zipfile
from pathlib import Path
if not __debug__:raise SystemExit('Success sealing requires assertions; Python -O rejected')
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent;BASE=ROOT/'.scratch/pt-pt/functional-grids-success';ORIGINAL=ROOT/'.scratch/pt-pt/functional-grids/capsule'
def sha(raw):return hashlib.sha256(raw).hexdigest()
def seal():
 original=(ORIGINAL/'capture.json').read_bytes();assert sha(original)=='d5332fa4e421521e55a67e1e3da85790e64716fefd5055a5005a67865603a8e7';old=json.loads(original);phase=old['phases']['final'];objects={};files={};cases={}
 with zipfile.ZipFile(ORIGINAL/'objects.zip') as z:
  needed=set(phase['source']['files'].values())|{phase['snapshot_manifest']}
  for r in phase['canonical'].values():needed.add(r['rcc_sha256']);needed.update(row['sha256'] for row in r['files'])
  for s in needed:raw=z.read('objects/'+s);assert sha(raw)==s;objects[s]=raw
 def store(raw):s=sha(raw);objects[s]=raw;return s
 for a in ['sudoku','calcudoku']:
  path=BASE/a;r=json.loads((path/'result.json').read_text());assert r['exit_code']==0 and r['passed'] and r['deployment_retained']
  for n in ['launcher-status.json','supervisor-exit.json','tool-exit.json']:assert json.loads((path/n).read_text())['exit_code']==0
  cases[a]={'historical_output':path.as_posix()}
  for p in sorted(path.rglob('*')):
   if p.is_file():assert not p.is_symlink();files['cases/'+a+'/'+p.relative_to(path).as_posix()]=store(p.read_bytes())
 for p in HERE.iterdir():
  if p.is_file() and p.name!='audit.py':files['harness/'+p.name]=store(p.read_bytes())
 for n in ['README.md','audit-red.log']:files[n]=store((BASE/n).read_bytes())
 value={'format':1,'original_capture_sha256':sha(original),'menu_after_success':True,'phase':phase,'cases':cases,'files':files,'objects':sorted(objects)};output=BASE/'capsule';output.mkdir()
 (output/'capture.json').write_text(json.dumps(value,indent=2)+'\n')
 with zipfile.ZipFile(output/'objects.zip','x',zipfile.ZIP_DEFLATED) as z:
  for s,raw in sorted(objects.items()):info=zipfile.ZipInfo('objects/'+s,date_time=(2026,1,1,0,0,0));info.compress_type=zipfile.ZIP_DEFLATED;z.writestr(info,raw)
 print(sha((output/'capture.json').read_bytes()))
if __name__=='__main__':seal()
