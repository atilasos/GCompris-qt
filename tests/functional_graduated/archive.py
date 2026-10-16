#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Archive finished supervised cases and actual Qt resource inventories."""
import argparse,hashlib,json,shutil,subprocess
from pathlib import Path
from phase import freeze,ROOT
from inventory import ACTIVITIES
PHASES={'baseline':'052399f75a3bbdda098c0c854cc99368f3219ecf','final':'d1e639c9f44e3124f37c614a58835bb14c90cc26'}
EXTERNAL=['src/activities/chess/resource/background-wood.svg',*[f'src/core/resource/sounds/{name}.wav' for name in ['completetask','crash','audioclick','smudge']]]
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser(description=__doc__)
 p.add_argument('--evidence',type=Path,default=ROOT/'.scratch/pt-pt/functional-graduated')
 p.add_argument('--snapshot',type=Path,required=True);p.add_argument('--inventory-tool',type=Path,required=True)
 a=p.parse_args();base=a.evidence
 for phase,revision in PHASES.items():
  source=freeze(revision);target=base/'phases'/phase;target.mkdir(parents=True,exist_ok=True)
  shutil.copyfile(source/'source-manifest.json',target/'source-manifest.json')
  shutil.copyfile(a.snapshot/'manifest.json',target/'snapshot-manifest.json')
 identities={}
 for name in [*ACTIVITIES,'chess','core']:
  resource=a.snapshot/'share/gcompris-qt/rcc'/(name+'.rcc');export=ROOT/'build/functional-graduated/exported'/name
  completed=subprocess.run([str(a.inventory_tool.resolve()),str(resource.resolve()),str(export.resolve())],capture_output=True,text=True,check=True)
  files=json.loads(completed.stdout)
  if name not in ACTIVITIES:files=[row for row in files if row['path'].removeprefix(':/gcompris/') in EXTERNAL]
  identities[name]={'rcc_sha256':sha(resource),'files':files}
  for row in files:
   relative=row['path'].removeprefix(':/gcompris/');destination=base/'resources'/relative;destination.parent.mkdir(parents=True,exist_ok=True)
   shutil.copyfile(export/'gcompris'/relative,destination)
 (base/'qt-resources.json').write_text(json.dumps(identities,indent=2)+'\n')
 cases={}
 for activity in ACTIVITIES:
  cases['keyboard-baseline-'+activity]={'phase':'baseline','kind':'keyboard','activity':activity}
  for color in ['red','green']:cases['portuguese-'+color+'-'+activity]={'phase':'baseline' if color=='red' else 'final','kind':color,'activity':activity}
  cases['controls/'+activity]={'phase':'final','kind':'controls','activity':activity}
 for row in json.loads((base/'full/summary.json').read_text()):
  assert row['exit_code']==0;cases['full/'+row['output']]=dict(row,phase='final',kind='campaign')
 for row in json.loads((base/'step-tracers/summary.json').read_text()):
  assert row['exit_code']==0;cases['step-tracers/'+row['output']]=dict(row,phase='final',kind='step')
 for name in cases:
  native=json.loads((base/name/'result.json').read_text());status=json.loads((base/name/'launcher-status.json').read_text())
  assert status['native_receipt_sha256']==sha(base/name/'result.json')
  assert status['case_sha256']==sha(base/name/'case.qml')==native['case_sha256']
  assert status['exit_code']==(1 if cases[name]['kind']=='red' else 0)
 files={}
 for file in sorted(base.rglob('*')):
  relative=file.relative_to(base)
  if file.is_file() and not any(part.startswith('.') for part in relative.parts) and relative.as_posix()!='index.json':files[relative.as_posix()]=sha(file)
 (base/'index.json').write_text(json.dumps({'cases':cases,'files':files,'scope':'574 primary questions; supplemental samples and controls separate; Linux only'},indent=2)+'\n')
if __name__=='__main__':main()
