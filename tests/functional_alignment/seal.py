#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Seal finished receipts and explicitly separate diagnostics from coverage."""
import argparse,hashlib,json
from pathlib import Path
if not __debug__:raise SystemExit('Alignment validation requires assertions; Python -O rejected')
ROOT=Path(__file__).resolve().parents[2]
BASELINE=['align-ai-old-draw-diagnostic','align-ai-preview-diagnostic','align-ai-wait-diagnostic','align-friend-draw-diagnostic','align-friend-help-red','align-friend-help-red-parse-diagnostic','align-help-first-red','align-help-red','align-help-red-parse-diagnostic','align-tracer','align-tracer-parse-diagnostic','tic-ai-complete','tic-friend-complete','tic-tracer','tic-tracer-parse-diagnostic']
HELP=['align-help-green','align-friend-help-green','tic-contract-red','draw-first-red','draw-second-red','draw-first-turn-diagnostic','draw-second-turn-diagnostic']
RULES=['align-ai-complete','align-ai-controls','align-friend-complete','align-friend-key-diagnostic','align-friend-key-diagnostic2','draw-first-green','draw-second-green','keyboard-ai-initial-control','keyboard-ai-red','keyboard-help-observation','keyboard-red','tic-ai-controls','tic-friend-controls','tic-contract-green']
FINAL=['keyboard-green','keyboard-ai-green','align-friend-controls']
NEGATIVE={*[name for name in BASELINE+HELP+RULES+FINAL if 'diagnostic' in name or name.endswith('-red')],'align-help-first-red'}
CASES={name:{'phase':phase,'expected_outer':int(name in NEGATIVE),'expected_native':137 if 'parse-diagnostic' in name else 0} for phase,names in [('baseline',BASELINE),('help',HELP),('rules',RULES),('final',FINAL)] for name in names}

def sha(data):return hashlib.sha256(data).hexdigest()
def seal(base):
 for name,contract in CASES.items():
  path=base/name;raw=(path/'result.json').read_bytes();r=json.loads(raw);status=json.loads((path/'launcher-status.json').read_text());outer=json.loads((path/'supervisor-exit.json').read_text());tool=json.loads((path/'tool-exit.json').read_text())
  assert status['exit_code']==outer['exit_code']==tool['exit_code']==contract['expected_outer'] and r['exit_code']==contract['expected_native'] and r['passed']==(contract['expected_outer']==0),'Incomplete '+name
  assert status['native_receipt_sha256']==outer['native_receipt_sha256']==tool['native_receipt_sha256']==sha(raw)
  assert outer['launcher_status_sha256']==tool['launcher_status_sha256']==sha((path/'launcher-status.json').read_bytes())
 for name,count in [('tic-ai-complete',10),('tic-friend-complete',10),('align-ai-complete',12),('align-friend-complete',10)]:assert len(json.loads((base/name/'result.json').read_text())['case_result']['games'])==count
 files={}
 for name in [*CASES,'identities-baseline','identities-rules','identities-final']:
  for path in sorted((base/name).iterdir()):
   assert path.is_file() and not path.is_symlink();files[path.relative_to(base).as_posix()]=sha(path.read_bytes())
 for name in ['source-tree.zip','source-phases.json','data.json','README.md','execution-notes.md','oracle-red.log','oracle-green.log','audit-red.log','audit-green.log','audit-tests-green.log']:files[name]=sha((base/name).read_bytes())
 (base/'capture.json').write_text(json.dumps({'format':1,'cases':CASES,'files':files},indent=2)+'\n');print(sha((base/'capture.json').read_bytes()))
if __name__=='__main__':
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--evidence',type=Path,default=ROOT/'.scratch/pt-pt/functional-alignment');args=parser.parse_args();seal(args.evidence)
