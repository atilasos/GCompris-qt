#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Seal exact frozen sources, retained effective Qt resources and raw receipts."""
import hashlib,io,json,shutil,subprocess,tarfile
from pathlib import Path
from phase import ROOT,freeze
from config import PHASES,CASES

def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def main():
 base=ROOT/'.scratch/pt-pt/functional-cycles';snapshot=base/'snapshot';tool=Path('/home/proteu/Projetos/GCompris-qt/build/pt-pt/bin/pt_audio_rcc_inventory')
 if (base/'index.json').exists():raise ValueError('Archive already sealed')
 commands=[];effective={};canonical={};audio=[]
 for phase,revision in PHASES.items():
  source=freeze(revision);manifest=json.loads((source/'source-manifest.json').read_text());target=base/'sources'/phase;target.mkdir(parents=True,exist_ok=True);shutil.copyfile(source/'source-manifest.json',target/'source-manifest.json')
  with tarfile.open(target/'source.tar.xz','w:xz') as archive:
   for path in sorted(manifest['files']):
    raw=(source/path).read_bytes()
    if hashlib.sha256(raw).hexdigest()!=manifest['files'][path] or raw!=subprocess.check_output(['git','show',revision+':'+path],cwd=ROOT):raise ValueError('Historical source mismatch')
    entry=tarfile.TarInfo(path);entry.size=len(raw);entry.mtime=0;entry.mode=0o644;archive.addfile(entry,io.BytesIO(raw))
 for name,description in CASES.items():
  receipt=json.loads((base/name/'result.json').read_text());rcc=Path(receipt['deployment'])/'share/gcompris-qt/rcc'/(description['activity']+'.rcc');export=ROOT/'build/functional-cycles/exported'/name
  if export.exists():raise ValueError('Export must be new')
  command=[str(tool),str(rcc.resolve()),str(export.resolve())];run=subprocess.run(command,capture_output=True,text=True);run.check_returncode();commands.append({'argv':command,'exit_code':run.returncode});files=json.loads(run.stdout)
  if sha(rcc)!=receipt['private_rcc_sha256']:raise ValueError('Actual private RCC differs')
  destination=base/'effective'/name;destination.mkdir(parents=True,exist_ok=True);shutil.copyfile(rcc,destination/'activity.rcc')
  for row in files:
   path=row['path'].removeprefix(':/gcompris/');target=destination/'files'/path;target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(export/'gcompris'/path,target)
  effective[name]={'rcc_sha256':sha(rcc),'files':files,'runtime_output':str((base/name).resolve()),'runtime_source':str((ROOT/'build/functional-cycles/sources'/PHASES[description['phase']]).resolve())}
  qm=Path(receipt['deployment'])/'share/gcompris-qt/translations/gcompris_qt_pt.qm';target=base/'catalogue'/(description['phase']+'.qm');target.parent.mkdir(exist_ok=True)
  if target.exists() and target.read_bytes()!=qm.read_bytes():raise ValueError('Same phase has different QM')
  shutil.copyfile(qm,target)
  if sha(target)!=receipt['private_qm_sha256']:raise ValueError('Actual QM differs')
 inventory=json.loads((base/'canonical-inventory/index.json').read_text())
 for name,observation in inventory['rccs'].items():
  rcc=snapshot/'share/gcompris-qt/rcc'/(name+'.rcc');target=base/'canonical'/name;target.mkdir(parents=True,exist_ok=True)
  if sha(rcc)!=observation['rcc_sha256']:raise ValueError('Canonical RCC changed')
  shutil.copyfile(rcc,target/'resource.rcc');canonical[name]=observation
  for row in observation['files']:
   path=row['path'].removeprefix(':/gcompris/');source=ROOT/'build/functional-cycles/canonical'/name/'gcompris'/path;destination=target/'files'/path;destination.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,destination)
   if sha(destination)!=row['sha256']:raise ValueError('Canonical extraction changed')
   if destination.suffix.lower() in ['.wav','.ogg']:
    command=['gst-launch-1.0','-q','filesrc','location='+str(destination.resolve()),'!','decodebin','!','audioconvert','!','fakesink'];run=subprocess.run(command,capture_output=True,text=True,timeout=30);run.check_returncode();audio.append({'path':path,'sha256':sha(destination),'argv':command,'exit_code':run.returncode,'stderr':run.stderr})
 execution=base/'execution-tools';execution.mkdir(exist_ok=True)
 for path in ['tools/run-native-qml-case.py','tools/run-native-qml-supervised.py','tools/native_qml_supervision.py','tools/native_qml_resources.py','tools/pt-pt-audio/rcc_inventory.cpp']:
  shutil.copyfile(ROOT/path,execution/Path(path).name)
 for name in ['capture.py','run.py','phase.py','lock_plan.py','make_cases.py','make_resources.py','inventory_resources.py','archive.py','config.py']:
  shutil.copyfile(ROOT/'tests/functional_cycles'/name,execution/name)
 shutil.copyfile(snapshot/'manifest.json',base/'snapshot-manifest.json')
 (base/'qt-resources.json').write_text(json.dumps({'inventory_tool_sha256':sha(tool),'effective':effective,'canonical':canonical,'commands':commands,'audio_decode':audio},indent=2)+'\n')
 files={path.relative_to(base).as_posix():sha(path) for path in sorted(base.rglob('*')) if path.is_file() and not any(part.startswith('.') or part=='snapshot' for part in path.relative_to(base).parts)}
 (base/'index.json').write_text(json.dumps({'phases':PHASES,'cases':CASES,'files':files,'scope':'One round trip, one water cycle and three energy levels; historical fixture failures distinct; Linux offline only'},indent=2)+'\n')
 print(json.dumps({'cases':len(CASES),'phases':len(PHASES),'files':len(files),'canonical_rccs':len(canonical),'decoded_audio':len(audio),'index_sha256':sha(base/'index.json')}))
if __name__=='__main__':main()
