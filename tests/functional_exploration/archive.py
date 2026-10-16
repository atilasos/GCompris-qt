#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Seal selected task-84 observations with physical source and Qt resources."""
import hashlib,io,json,re,shutil,subprocess,tarfile,uuid
from pathlib import Path
from phase import ROOT,ACTIVITIES,sha
BASE=ROOT/'.scratch/pt-pt/functional-exploration'
PHASES=['baseline','pt-final','reviewed']
def capsule(files,path):
 path.parent.mkdir(parents=True,exist_ok=True)
 with tarfile.open(path,'w:xz') as archive:
  for name,raw in sorted(files.items()):
   entry=tarfile.TarInfo(name);entry.size=len(raw);entry.mode=0o644;entry.mtime=0;archive.addfile(entry,io.BytesIO(raw))
def descriptions():
 result={}
 for activity in ACTIVITIES:
  for colour,phase in [('red','baseline'),('green','pt-final')]:result['language-exact-'+colour+'-'+activity]={'activity':activity,'phase':phase,'kind':'language','expected_exit':int(colour=='red'),'pair':'language-'+activity}
  result['gameplay-final-'+activity]={'activity':activity,'phase':'reviewed','kind':'gameplay','expected_exit':0}
  result['controls-final-'+activity]={'activity':activity,'phase':'reviewed','kind':'controls','expected_exit':0}
 for activity in ['explore_farm_animals','explore_world_animals']:
  result['help-red-'+activity]={'activity':activity,'phase':'pt-final','kind':'help-red','expected_exit':1,'pair':'help-'+activity}
  result['controls-final-'+activity]['pair']='help-'+activity
 for name,phase,code in [('gameplay-farm-before','baseline',1),('question-language-green-farm','pt-final',0)]:result[name]={'activity':'explore_farm_animals','phase':phase,'kind':'question-language','expected_exit':code,'pair':'farm-question-wording'}
 return result

def main():
 final_out=BASE/'archive'
 if final_out.exists():raise FileExistsError('Archive already sealed')
 out=BASE/('.archive-building-'+uuid.uuid4().hex)
 out.mkdir();(out/'blobs').mkdir();records=descriptions();index={'format':1,'sources':{},'runs':records,'imports':{},'audio':[]}
 def blob(p):
  h=sha(p);target=out/'blobs'/h
  if not target.exists():shutil.copyfile(p,target)
  return h
 for phase in PHASES:
  source=ROOT/'build/functional-exploration/sources'/phase
  manifest=json.loads((source/'source-manifest.json').read_text());files={name:(source/name).read_bytes() for name in manifest}
  if {name:hashlib.sha256(raw).hexdigest() for name,raw in files.items()}!=manifest:raise ValueError('Frozen source changed')
  capsule(files,out/'sources'/(phase+'.tar.xz'));index['sources'][phase]=manifest
 tool=Path('/tmp/pt-audio-rcc-inventory')
 def export(rcc,name):
  target=ROOT/'build/functional-exploration/exports'/name
  run=subprocess.run([str(tool),str(rcc.resolve()),str(target)],capture_output=True,text=True);run.check_returncode();rows=json.loads(run.stdout)
  files={row['path'][2:]:(target/row['path'][2:]).read_bytes() for row in rows};capsule(files,out/'effective'/(name+'.tar.xz'))
  return {'rcc':blob(rcc),'resources':rows,'export_exit':run.returncode,'export_tool_sha256':sha(tool)}
 snapshot=ROOT/'build/functional-exploration/runtime-snapshot';shutil.copyfile(snapshot/'manifest.json',out/'snapshot-manifest.json')
 for name,record in records.items():
  original=BASE/name;target=out/'runs'/name;target.mkdir(parents=True)
  for p in original.iterdir():
   if p.is_file():shutil.copyfile(p,target/p.name)
  receipt=json.loads((original/'result.json').read_text());deployment=Path(receipt['deployment']);rcc=deployment/'share/gcompris-qt/rcc/explore_farm_animals.rcc'
  record.update(export(rcc,name));record['qm']=blob(deployment/'share/gcompris-qt/translations/gcompris_qt_pt.qm')
  record['runtime_output']=str(original.resolve());record['runtime_source']=str(ROOT/'build/functional-exploration/sources'/record['phase'])
 for name in [*ACTIVITIES,'core','chess']:
  index['imports'][name]=export(snapshot/'share/gcompris-qt/rcc'/(name+'.rcc'),'import-'+name)
 # Decode exactly the resources taught/played by the final native campaigns.
 played=set()
 for activity in ACTIVITIES:
  receipt=json.loads((BASE/('gameplay-final-'+activity)/'result.json').read_text());played.update(receipt['case_result'].get('playbacks',[]));played.update(p['audio'] for p in receipt['case_result']['pages'] if p['audio'])
 # Intro voices may come from a separate RCC; export it only for observed paths.
 voices=[p for p in played if 'voices-' in p]
 voice_folder=ROOT/'build/functional-exploration/voice-export'
 if voices:
  loaded=set()
  for activity in ACTIVITIES:
   log=(BASE/('gameplay-final-'+activity)/'native.log').read_text()
   loaded.update(re.findall(r'Successfully registered resource "[^"\n]*/voices-ogg/(voices-pt-[^"/]+\.rcc)"',log))
  if len(loaded)!=1:raise ValueError('Expected one actually registered PT voice package')
  voice_name=loaded.pop();voice_rcc=snapshot/'share/gcompris-qt/rcc/data3/voices-ogg'/voice_name
  exported=subprocess.run([str(tool),str(voice_rcc),str(voice_folder)],capture_output=True,text=True);exported.check_returncode()
  selected={p.removeprefix('qrc:/') for p in voices}
  rows=[r for r in json.loads(exported.stdout) if r['path'][2:] in selected]
  if len(rows)!=len(selected):raise ValueError('An observed voice resource was not exported')
  index['voice_import']={'file':'share/gcompris-qt/rcc/data3/voices-ogg/'+voice_name,'rcc':blob(voice_rcc),'resources':rows,'export_exit':exported.returncode,'export_tool_sha256':sha(tool)}
 approval=ROOT/'.scratch/pt-pt/audio-review/teacher-approval.json'
 shutil.copyfile(approval,out/'teacher-approval-32.json');approved=json.loads(approval.read_text())['recordings']
 for resource in sorted(played):
  if not resource.startswith('qrc:/'):raise ValueError('Unexpected audio path '+resource)
  relative=resource.removeprefix('qrc:/');actual=None
  for name in ACTIVITIES:
   p=ROOT/'build/functional-exploration/exports'/('import-'+name)/relative
   if p.is_file():actual=p;break
  if actual is None and (voice_folder/relative).is_file():actual=voice_folder/relative
  if actual is None:raise ValueError('No actual played resource '+resource)
  command=['gst-launch-1.0','-q','filesrc','location='+str(actual.resolve()),'!','decodebin','!','audioconvert','!','fakesink'];run=subprocess.run(command,capture_output=True,text=True,timeout=60);run.check_returncode()
  voice_key=resource.split('/voices-ogg/pt/',1)[-1] if '/voices-ogg/pt/' in resource else None
  approved_match=voice_key in approved and approved[voice_key]['sha256']==sha(actual)
  index['audio'].append({'resource':resource,'approved32_match':approved_match,'blob':blob(actual),'decode_exit':run.returncode,'argv':command,'stderr':run.stderr,'human_listening':False})
 tools=out/'execution-tools';tools.mkdir()
 for name in ['phase.py','curriculum.py','apply_language.py']:
  shutil.copyfile(ROOT/'tests/functional_exploration'/name,tools/name)
 shutil.copyfile(ROOT/'tools/pt-pt-audio/rcc_inventory.cpp',tools/'rcc_inventory.cpp');shutil.copyfile(tool,tools/'rcc-inventory')
 for name in ['language-review.json','question-review.json','help-review.json','lessons.json']:
  shutil.copyfile(ROOT/'tests/functional_exploration'/name,out/name)
 (out/'evidence.json').write_text(json.dumps(index,ensure_ascii=False,indent=2)+'\n')
 files={str(p.relative_to(out)):sha(p) for p in sorted(out.rglob('*')) if p.is_file()};(out/'sealed.json').write_text(json.dumps(files,indent=2)+'\n')
 out.rename(final_out)
 print(json.dumps({'archive':str(final_out),'index_sha256':sha(final_out/'sealed.json')}))
if __name__=='__main__':main()
