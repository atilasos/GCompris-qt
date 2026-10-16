#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Archive exact historical source bytes and actual effective Qt RCCs."""
import hashlib,io,json,shutil,subprocess,tarfile
from pathlib import Path
from phase import ROOT,freeze
from inventory import inventory
from solver import chain,combine
PHASES={'baseline':'ad68de3f69b88b326afa69eeda1bad7c3a1aeafb','pools':'3ae1c80fb49fd373956a7d5e3294274d90d7f34b','data':'d3066266a697a155dbbb14eb2857459e0259b164','label':'8f630b759cae374a7d12e888bf09446e62273dec','language':'436762daa4e972f6c369a33434897cbf008339f6'}
CASES={**{f'guess24-{level:02d}':dict(activity='guess24',phase='baseline',kind='gameplay',start=level,levels=1) for level in range(1,7)},
 **{f'count-{level:02d}':dict(activity='guesscount',phase='pools',kind='gameplay',start=level,levels=count) for level,count in [(1,4),(5,6),(15,3)]},
 'count-11-final':dict(activity='guesscount',phase='label',kind='gameplay',start=11,levels=4),
 **{f'admin-{level:02d}':dict(activity='guesscount',phase='pools',kind='admin',start=level,levels=4) for level in [1,5]},
 'controls24':dict(activity='guess24',phase='pools',kind='controls'),
 'controls-count-complete':dict(activity='guesscount',phase='language',kind='controls'),
 'pool-red':dict(activity='guesscount',phase='baseline',kind='red',expected_exit=1,origin='pool16-red4'),
 'pool-green':dict(activity='guesscount',phase='pools',kind='regression',origin='pool16-green3'),
 'admin-red':dict(activity='guesscount',phase='baseline',kind='red',expected_exit=1,origin='admin8-red3'),
 'admin-green':dict(activity='guesscount',phase='pools',kind='regression',origin='admin8-green2'),
 'unsolvable-red':dict(activity='guesscount',phase='pools',kind='red',expected_exit=1,origin='unsolvable-red'),
 'unsolvable-green':dict(activity='guesscount',phase='data',kind='regression',origin='unsolvable-green'),
 'label-red':dict(activity='guesscount',phase='data',kind='red',expected_exit=1,origin='target-title-red'),
 'label-green':dict(activity='guesscount',phase='language',kind='translation-green',origin='target-title-green')}

def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def main():
 base=ROOT/'.scratch/pt-pt/functional-challenges';snapshot=ROOT/'build/functional-challenges/snapshot';tool=Path('/tmp/pt-audio-rcc-inventory')
 if (base/'index.json').exists():raise ValueError('Archive already sealed')
 (base/'execution-tools').mkdir(exist_ok=True)
 commands=[];resources={};capsules={}
 data=inventory(freeze(PHASES['language']));(base/'inventory.json').write_text(json.dumps(data,indent=2)+'\n');witnesses=[]
 for dataset in range(1,5):
  rule=next(r for r in data['guesscount'] if r['dataset']==dataset)
  for group in rule['groups']:
   for operators,pool in group:
    for values,target in pool:witnesses.append({'mode':'builtin','dataset':dataset,'values':values,'target':target,'operators':operators,'steps':chain(values,target,operators)})
 for group in data['admin']['data']:
  for operators,pool in group:
   for values,target in pool:witnesses.append({'mode':'admin','values':values,'target':target,'operators':operators,'steps':chain(values,target,operators)})
 for row in data['corpus']:
  operators=['+','-'] if row['complexity']==1 else ['+','-','*'] if row['complexity']==2 else ['+','-','*','/'];witnesses.append({'mode':'twenty-four','values':row['values'],'target':24,'complexity':row['complexity'],'operators':operators,'steps':combine(row['values'],24,operators)})
 if len(witnesses)!=1506 or any(row['steps'] is None for row in witnesses):raise ValueError('Published corpus includes unreachable target')
 (base/'corpus-witnesses.json').write_text(json.dumps(witnesses,indent=2)+'\n')
 for phase,revision in PHASES.items():
  source=freeze(revision);manifest=json.loads((source/'source-manifest.json').read_text());capsules[phase]=manifest;target=base/'sources'/phase;target.mkdir(parents=True,exist_ok=True)
  shutil.copyfile(source/'source-manifest.json',target/'source-manifest.json')
  with tarfile.open(target/'source.tar.xz','w:xz') as capsule:
   for path in sorted(manifest['files']):
    raw=(source/path).read_bytes()
    if hashlib.sha256(raw).hexdigest()!=manifest['files'][path] or raw!=subprocess.check_output(['git','show',revision+':'+path],cwd=ROOT):raise ValueError('Historical source mismatch')
    entry=tarfile.TarInfo(path);entry.size=len(raw);entry.mtime=0;entry.mode=0o644;capsule.addfile(entry,io.BytesIO(raw))
 for name,description in CASES.items():
  receipt=json.loads((base/'native'/name/'result.json').read_text());rcc=Path(receipt['deployment'])/'share/gcompris-qt/rcc'/(description['activity']+'.rcc');export=ROOT/'build/functional-challenges/exported'/name
  command=[str(tool),str(rcc.resolve()),str(export.resolve())];completed=subprocess.run(command,capture_output=True,text=True);commands.append({'argv':command,'exit_code':completed.returncode});completed.check_returncode();files=json.loads(completed.stdout)
  if sha(rcc)!=receipt['private_rcc_sha256']:raise ValueError('Actual effective RCC differs from native receipt')
  destination=base/'effective'/name;destination.mkdir(parents=True,exist_ok=True);shutil.copyfile(rcc,destination/'activity.rcc')
  for entry in files:
   path=entry['path'].removeprefix(':/gcompris/');target=destination/'files'/path;target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(export/'gcompris'/path,target)
  resources[name]={'rcc_sha256':sha(rcc),'files':files,'runtime_output':str((ROOT/'build/functional-challenges'/description['origin']).resolve()) if 'origin' in description else str((base/'native'/name).resolve()),'runtime_source':str((ROOT/'build/functional-challenges/sources'/PHASES[description['phase']]).resolve())}
 extras={
  'core':['src/core/Bonus.qml',*[f'src/core/resource/sounds/{name}.wav' for name in ['completetask','crash','bleep','smudge','bonus']]],
  'chess':['src/activities/chess/resource/undo.svg'],
  'guesscount':['src/activities/guesscount/resource/backgroundW01.svg'],
 }

 imports={}
 for name,paths in extras.items():
  rcc=snapshot/'share/gcompris-qt/rcc'/(name+'.rcc');export=ROOT/'build/functional-challenges/exported'/('import-'+name)
  command=[str(tool),str(rcc.resolve()),str(export.resolve())];completed=subprocess.run(command,capture_output=True,text=True);commands.append({'argv':command,'exit_code':completed.returncode});completed.check_returncode();files=[entry for entry in json.loads(completed.stdout) if entry['path'].removeprefix(':/gcompris/') in paths]
  if len(files)!=len(paths):raise ValueError('Missing actual imported resource')
  imports[name]={'rcc_sha256':sha(rcc),'files':files}
  for entry in files:
   path=entry['path'].removeprefix(':/gcompris/');target=base/'imports'/path;target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(export/'gcompris'/path,target)
   if target.read_bytes()!=subprocess.check_output(['git','show',PHASES['baseline']+':'+path],cwd=ROOT):raise ValueError('Imported source differs from historical Git')
   if path.endswith('.wav'):
    command=['gst-launch-1.0','-q','filesrc','location='+str(target.resolve()),'!','decodebin','!','audioconvert','!','fakesink'];decoded=subprocess.run(command,capture_output=True,text=True,timeout=30);commands.append({'argv':command,'exit_code':decoded.returncode,'stderr':decoded.stderr});decoded.check_returncode()
 shutil.copyfile(snapshot/'manifest.json',base/'snapshot-manifest.json')
 for path in ['tools/run-native-qml-case.py','tools/run-native-qml-supervised.py','tools/native_qml_supervision.py']:
  shutil.copyfile(ROOT/path,base/'execution-tools'/Path(path).name)
 shutil.copyfile(ROOT/'tests/functional_challenges/run.py',base/'execution-tools/run.py');shutil.copyfile(ROOT/'tests/functional_challenges/capture.py',base/'execution-tools/capture.py')
 (base/'qt-resources.json').write_text(json.dumps({'effective':resources,'imports':imports},indent=2)+'\n')
 (base/'resource-commands.json').write_text(json.dumps({'inventory_tool_sha256':sha(tool),'commands':commands},indent=2)+'\n')
 for phase,case_name in [('baseline','guess24-01'),('pools','admin-01'),('data','unsolvable-green'),('label','count-11-final'),('language','label-green')]:
  receipt=json.loads((base/'native'/case_name/'result.json').read_text());qm=Path(receipt['deployment'])/'share/gcompris-qt/translations/gcompris_qt_pt.qm';target=base/'catalogue'/(phase+'.qm');target.parent.mkdir(exist_ok=True);shutil.copyfile(qm,target)
  if sha(target)!=receipt['private_qm_sha256']:raise ValueError('Actual compiled catalogue differs')
 files={path.relative_to(base).as_posix():sha(path) for path in sorted(base.rglob('*')) if path.is_file() and not any(part.startswith('.') for part in path.relative_to(base).parts)}
 (base/'index.json').write_text(json.dumps({'phases':PHASES,'cases':CASES,'files':files,'scope':'100 pair-tree draws; 56 built-in and 30 admin linear puzzles; controls/regressions separate; Linux offline only'},indent=2)+'\n')
if __name__=='__main__':main()
