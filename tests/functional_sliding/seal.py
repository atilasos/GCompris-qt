#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Seal only finished native cases, including failed diagnostics separately."""
import argparse,hashlib,json
from pathlib import Path
if not __debug__:raise SystemExit('Sliding validation requires assertions; Python -O rejected')
ROOT=Path(__file__).resolve().parents[2]
NAMES=['fifteen-tracer','sixteen-tracer','fifteen-complete','sixteen-complete','help-red','help-green','fifteen-menu-diagnostic','sixteen-menu-diagnostic','fifteen-menu-diagnostic2','sixteen-menu-diagnostic2','fifteen-menu-diagnostic3','sixteen-menu-diagnostic3','fifteen-controls','sixteen-controls','fifteen-partial-restart','fifteen-art-red','sixteen-art-red','fifteen-art-green','sixteen-art-green','art-english-fallback']
CASES={name:('baseline' if name in NAMES[:5] else 'localized' if name.endswith('art-green') or name=='art-english-fallback' else 'final',1 if name=='help-red' or name.endswith('art-red') or 'diagnostic' in name else 0) for name in NAMES}

def sha(data):return hashlib.sha256(data).hexdigest()
def seal(base):
 for name,(phase,expected) in CASES.items():
  path=base/name;receipt=(path/'result.json').read_bytes();status=json.loads((path/'launcher-status.json').read_text());outer=json.loads((path/'supervisor-exit.json').read_text());tool=json.loads((path/'tool-exit.json').read_text())
  result=json.loads(receipt);assert status['exit_code']==outer['exit_code']==tool['exit_code']==expected and result['exit_code']==0 and result['passed']==(expected==0),'Incomplete or unsuccessful '+name
  assert status['native_receipt_sha256']==outer['native_receipt_sha256']==tool['native_receipt_sha256']==sha(receipt)
  assert outer['launcher_status_sha256']==tool['launcher_status_sha256']==sha((path/'launcher-status.json').read_bytes())
 files={}
 for name in CASES:
  for path in sorted((base/name).iterdir()):
   assert path.is_file() and not path.is_symlink();files[path.relative_to(base).as_posix()]=sha(path.read_bytes())
 for identity in ['identities','identities-localized']:
  for path in sorted((base/identity).iterdir()):
   assert path.is_file() and not path.is_symlink();files[path.relative_to(base).as_posix()]=sha(path.read_bytes())
 for name in ['source-tree.zip','source-phases.json','data.json','README.md','oracle-red.log','oracle-green.log','localized-art.png','art-labels.json','art_bounds.cpp','art-unit-red.log','art-unit-green.log','prepare-red.log','prepare-green.log']:files[name]=sha((base/name).read_bytes())
 (base/'capture.json').write_text(json.dumps({'format':1,'cases':{name:{'phase':phase,'expected_outer':expected} for name,(phase,expected) in CASES.items()},'files':files},indent=2)+'\n');print(sha((base/'capture.json').read_bytes()))
if __name__=='__main__':
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--evidence',type=Path,default=ROOT/'.scratch/pt-pt/functional-sliding');args=parser.parse_args();seal(args.evidence)
