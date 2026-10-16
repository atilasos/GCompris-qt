#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Seal completed candy campaigns without changing historical native receipts."""
import hashlib,json,shutil
from pathlib import Path
from phase import ROOT,freeze
PHASES={'baseline':'dfcd3d9ca77d548a93282ad5b6e893c5858aefb3','portuguese':'ea1db0ab206fb7d6bec5d848de94084c880ecd1e','final':'4382e3ecd23d99294e04fe5eeccfa374c6d2b5a7'}
def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def main():
 base=ROOT/'.scratch/pt-pt/functional-share'
 if (base/'index.json').exists():raise ValueError('Proof index already exists')
 phases={}
 for phase,revision in PHASES.items():
  source=freeze(revision);phases[phase]=source.name;target=base/'phases'/phase;target.mkdir(parents=True,exist_ok=True)
  shutil.copyfile(source/'source-manifest.json',target/'source-manifest.json')
 cases={
  'portuguese-red':{'phase':'baseline','kind':'portuguese','expected_exit':1},
  'portuguese-green':{'phase':'portuguese','kind':'portuguese'},
  'drag-red':{'phase':'portuguese','kind':'drag','expected_exit':1},
  'drag-green':{'phase':'final','kind':'drag'},
  'resources-ready':{'phase':'final','kind':'resources'},
  'resources-effective':{'phase':'final','kind':'resources'},
 }
 summary=json.loads((base/'full/summary.json').read_text())
 if len(summary)!=6 or any(row['exit_code']!=0 for row in summary):raise ValueError('Full campaign outer outcomes failed')
 for row in summary:cases['full/'+row['output']]=dict(row,phase='final',kind='campaign')
 controls=json.loads((base/'controls/summary.json').read_text())
 if len(controls)!=2 or any(row['exit_code']!=0 for row in controls):raise ValueError('Control runner outer outcomes failed')
 for row in controls:cases['controls/'+row['mode']]=dict(row,phase='final',kind='controls')
 for name,description in cases.items():
  status=json.loads((base/name/'launcher-status.json').read_text());receipt=json.loads((base/name/'result.json').read_text())
  if status['exit_code']!=description.get('expected_exit',0) or status['native_receipt_sha256']!=digest(base/name/'result.json') or status['case_sha256']!=digest(base/name/'case.qml') or receipt['case_sha256']!=status['case_sha256']:raise ValueError('Unfinished or changed receipt: '+name)
 for filename in ['tools/run-native-qml-supervised.py','tools/native_qml_supervision.py']:
  target=base/Path(filename).name;shutil.copyfile(ROOT/filename,target)
 files={path.relative_to(base).as_posix():digest(path) for path in sorted(base.rglob('*')) if path.is_file() and not any(part.startswith('.') for part in path.relative_to(base).parts) and path.name!='index.json'}
 (base/'index.json').write_text(json.dumps({'phases':phases,'cases':cases,'pairs':[['portuguese-red','portuguese-green'],['drag-red','drag-green']],'files':files,'scope':'146 primary puzzles; regressions, resources and controls separate; 25 random templates sampled per mode, not all random draws'},indent=2)+'\n')
if __name__=='__main__':main()
