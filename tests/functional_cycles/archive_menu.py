#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Preserve three new post-success runs without touching the primary archive."""
import hashlib,json,shutil,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
CASES={'canal':'canal_lock','water':'watercycle','energy':'renewable_energy'}
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def main():
 base=ROOT/'.scratch/pt-pt/functional-cycles-menu';primary=ROOT/'.scratch/pt-pt/functional-cycles'
 if (base/'index.json').exists():raise ValueError('Historical archive exists')
 effective={};tool=Path('/home/proteu/Projetos/GCompris-qt/build/pt-pt/bin/pt_audio_rcc_inventory')
 for name,activity in CASES.items():
  receipt=json.loads((base/name/'result.json').read_text());deploy=Path(receipt['deployment']);rcc=deploy/'share/gcompris-qt/rcc'/(activity+'.rcc');target=base/'effective'/name;target.mkdir(parents=True)
  export=ROOT/'build/functional-cycles/menu-export'/name
  if export.exists():raise ValueError('New extraction required')
  command=[str(tool),str(rcc),str(export)];run=subprocess.run(command,capture_output=True,text=True);run.check_returncode();files=json.loads(run.stdout)
  shutil.copyfile(rcc,target/'activity.rcc');shutil.copyfile(deploy/'share/gcompris-qt/translations/gcompris_qt_pt.qm',target/'catalogue.qm')
  if sha(target/'activity.rcc')!=receipt['private_rcc_sha256'] or sha(target/'catalogue.qm')!=receipt['private_qm_sha256']:raise ValueError('Actual deployed resources differ')
  for row in files:
   relative=row['path'].removeprefix(':/gcompris/');dest=target/'files'/relative;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(export/'gcompris'/relative,dest)
  effective[name]={'files':files,'runtime_output':str((base/name).resolve()),'runtime_source':str(ROOT/'build/functional-cycles/sources/58e67c399e4de26d84d02d3d43080a488ed6b9cd'),'extract_command':command,'extract_exit_code':run.returncode}
 (base/'resources.json').write_text(json.dumps(effective,indent=2)+'\n')
 files={p.relative_to(base).as_posix():sha(p) for p in sorted(base.rglob('*')) if p.is_file() and not any(part.startswith('.') for part in p.relative_to(base).parts)}
 index={'format':1,'primary_index_sha256':sha(primary/'index.json'),'cases':CASES,'files':files}
 with (base/'index.json').open('x') as stream:stream.write(json.dumps(index,indent=2)+'\n')
 print(json.dumps({'files':len(files),'index_sha256':sha(base/'index.json')}))
if __name__=='__main__':main()
