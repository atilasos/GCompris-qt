#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Preserve physical historical inputs and Qt-extracted effective resources."""
import hashlib,io,json,shutil,subprocess,tarfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];BASE=ROOT/'.scratch/pt-pt/public-level-contracts'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def capsule(files,destination):
 destination.parent.mkdir(parents=True,exist_ok=True)
 with tarfile.open(destination,'w:xz') as tar:
  for name,data in sorted(files.items()):
   entry=tarfile.TarInfo(name);entry.size=len(data);entry.mtime=0;entry.mode=0o644;tar.addfile(entry,io.BytesIO(data))
def main():
 out=BASE/'archive'
 if out.exists():raise ValueError('Archive already exists')
 out.mkdir();(out/'blobs').mkdir();records={};sources={}
 inventory=json.loads((ROOT/'tests/public_levels/inventory.json').read_text())
 dirs={q.split('/')[0] for _,q,_ in inventory}|{'sixteen','color_mix_light','bargame_2players','checkers_2players'}
 for phase in ['red','green']:
  source=BASE/'sources'/phase
  files={str(p.relative_to(source)):p.read_bytes() for p in source.rglob('*') if p.is_file() and (str(p.relative_to(source)).startswith(('tools/','poqm/')) or p.name=='CMakeLists.txt' and p.parent==source or any(str(p.relative_to(source)).startswith('src/activities/'+d+'/') for d in dirs))}
  capsule(files,out/(phase+'-sources.tar.xz'));sources[phase]={n:hashlib.sha256(data).hexdigest() for n,data in files.items()}
 def blob(p):
  h=sha(p);target=out/'blobs'/h
  if not target.exists():shutil.copyfile(p,target)
  return h
 tool=Path('/tmp/pt-audio-rcc-inventory')
 for activity,qml,total in inventory:
  label=activity+'-ready' if activity in ['melody','play_piano','piano_composition'] else 'polygons-tutorial' if activity=='polygons' else activity
  for phase in ['red','green']:
   name=label+'-'+phase;run=BASE/'runs'/name;target=out/'runs'/name;target.mkdir(parents=True)
   for p in run.iterdir():
    if p.is_file():shutil.copyfile(p,target/p.name)
   case=BASE/'cases'/(label+'.qml');shutil.copyfile(case,target/'case.qml')
   receipt=json.loads((run/'result.json').read_text());deployment=Path(receipt['deployment']);rcc=deployment/'share/gcompris-qt/rcc'/(qml.split('/')[0]+'.rcc')
   rccblob=blob(rcc);qmblob=blob(deployment/'share/gcompris-qt/translations/gcompris_qt_pt.qm')
   export=BASE/'exports'/name
   p=subprocess.run([str(tool),str(rcc),str(export)],capture_output=True,text=True);p.check_returncode();resources=json.loads(p.stdout)
   extracted={row['path'][2:]: (export/row['path'][2:]).read_bytes() for row in resources}
   capsule(extracted,out/'effective'/(name+'.tar.xz'))
   records[name]={'activity':activity,'qml':qml,'total':total,'phase':phase,'rcc':rccblob,'qm':qmblob,'resources':resources,'export_exit':p.returncode,'export_tool_sha256':sha(tool)}
 for label,activity,qml in [('checkers-no-level','checkers_2players','checkers/Checkers.qml'),('polygons-free-settings','polygons','polygons/Polygons.qml')]:
  name=label+'-green';run=BASE/'runs'/name;target=out/'exclusions'/name;shutil.copytree(run,target);shutil.copyfile(BASE/'cases'/(label+'.qml'),target/'case.qml')
  r=json.loads((run/'result.json').read_text());deployment=Path(r['deployment']);rcc=deployment/'share/gcompris-qt/rcc'/(qml.split('/')[0]+'.rcc');blob(rcc);blob(deployment/'share/gcompris-qt/translations/gcompris_qt_pt.qm')
 shutil.copyfile(BASE/'runtime-snapshot/manifest.json',out/'snapshot-manifest.json')
 # Imported shared code stays physically available without relying on a build.
 imports={}
 for name in ['core','braille_alphabets','sketch','guesscount','family','canal_lock','sixteen','color_mix_light','bargame_2players','checkers_2players']:
  p=BASE/'runtime-snapshot/share/gcompris-qt/rcc'/(name+'.rcc');imports[name]=blob(p)
 (out/'evidence.json').write_text(json.dumps({'sources':sources,'runs':records,'imports':imports,'scope':'Public metadata and real next/previous navigation only; runtime snapshot remains local; no game completions, Windows, audio or teacher approval.'},indent=2)+'\n')
 seal(out)
 print(out)
def seal(out):
 files={str(p.relative_to(out)):sha(p) for p in sorted(out.rglob('*')) if p.is_file() and p.name!='sealed.json'}
 (out/'sealed.json').write_text(json.dumps(files,indent=2)+'\n')
if __name__=='__main__':main()
