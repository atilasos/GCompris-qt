#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Archive exact historical source bytes and actual effective Qt RCCs."""
import hashlib,io,json,shutil,subprocess,tarfile
from pathlib import Path
from phase import ROOT,freeze
PHASES={'baseline':'65ec383c84d64ded3e9f33345bf232d3a64e2810','final':'18714982cd3da866b0a24f2e931c444dddf40a90','language':'25f91ab4b85e0e8a5e79649ba2b9b6a5281b5dcc'}
CASES={
 'hands-complete':dict(activity='leftright',phase='baseline',kind='gameplay'),
 'positions-complete':dict(activity='positions',phase='baseline',kind='gameplay'),
 'mouse-red':dict(activity='left_right_click',phase='baseline',kind='red',expected_exit=1),
 'mouse-complete':dict(activity='left_right_click',phase='final',kind='gameplay'),
 'hands-controls-baseline':dict(activity='leftright',phase='baseline',kind='checkpoint'),
 'hands-controls':dict(activity='leftright',phase='language',kind='controls'),
 'hand-help-red':dict(activity='leftright',phase='final',kind='translation-red',expected_exit=1),
 'hand-help-green':dict(activity='leftright',phase='language',kind='translation-green'),
 'positions-controls':dict(activity='positions',phase='baseline',kind='controls'),
 'mouse-controls-baseline':dict(activity='left_right_click',phase='baseline',kind='checkpoint'),
 'mouse-controls':dict(activity='left_right_click',phase='final',kind='controls'),
}
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def main():
 base=ROOT/'.scratch/pt-pt/functional-orientation';snapshot=ROOT/'build/functional-orientation/snapshot';tool=Path('/tmp/pt-audio-rcc-inventory')
 if (base/'index.json').exists():raise ValueError('Archive already sealed')
 commands=[];resources={};capsules={}
 for phase,revision in PHASES.items():
  source=freeze(revision);manifest=json.loads((source/'source-manifest.json').read_text());capsules[phase]=manifest;target=base/'sources'/phase;target.mkdir(parents=True,exist_ok=True)
  shutil.copyfile(source/'source-manifest.json',target/'source-manifest.json')
  with tarfile.open(target/'source.tar.xz','w:xz') as capsule:
   for path in sorted(manifest['files']):
    raw=(source/path).read_bytes()
    if hashlib.sha256(raw).hexdigest()!=manifest['files'][path] or raw!=subprocess.check_output(['git','show',revision+':'+path],cwd=ROOT):raise ValueError('Historical source mismatch')
    entry=tarfile.TarInfo(path);entry.size=len(raw);entry.mtime=0;entry.mode=0o644;capsule.addfile(entry,io.BytesIO(raw))
 for name,description in CASES.items():
  receipt=json.loads((base/name/'result.json').read_text());rcc=Path(receipt['deployment'])/'share/gcompris-qt/rcc'/(description['activity']+'.rcc');export=ROOT/'build/functional-orientation/exported'/name
  command=[str(tool),str(rcc.resolve()),str(export.resolve())];completed=subprocess.run(command,capture_output=True,text=True);commands.append({'argv':command,'exit_code':completed.returncode});completed.check_returncode();files=json.loads(completed.stdout)
  if sha(rcc)!=receipt['private_rcc_sha256']:raise ValueError('Actual effective RCC differs from native receipt')
  destination=base/'effective'/name;destination.mkdir(parents=True,exist_ok=True);shutil.copyfile(rcc,destination/'activity.rcc')
  for entry in files:
   path=entry['path'].removeprefix(':/gcompris/');target=destination/'files'/path;target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(export/'gcompris'/path,target)
  resources[name]={'rcc_sha256':sha(rcc),'files':files,'runtime_output':str((base/name).resolve()) if name not in ['mouse-red','mouse-controls-baseline','hands-controls-baseline'] else str((base/('mouse-complete' if name=='mouse-red' else 'hands-controls' if name=='hands-controls-baseline' else 'mouse-controls')).resolve()),'runtime_source':str((ROOT/'build/functional-orientation/sources'/PHASES[description['phase']]).resolve())}
 extras={
  'family':['src/activities/family/resource/background.svg'],
  'canal_lock':['src/activities/canal_lock/resource/sky.svg'],
  'core':['src/core/AnswerButton.qml','src/core/Bonus.qml',*[f'src/core/resource/sounds/{name}.wav' for name in ['completetask','crash','bonus']]],
 }
 imports={}
 for name,paths in extras.items():
  rcc=snapshot/'share/gcompris-qt/rcc'/(name+'.rcc');export=ROOT/'build/functional-orientation/exported'/('import-'+name)
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
 (base/'qt-resources.json').write_text(json.dumps({'effective':resources,'imports':imports},indent=2)+'\n')
 (base/'resource-commands.json').write_text(json.dumps({'inventory_tool_sha256':sha(tool),'commands':commands},indent=2)+'\n')
 for phase,case_name in [('baseline','hands-complete'),('final','mouse-complete'),('language','hand-help-green')]:
  receipt=json.loads((base/case_name/'result.json').read_text());qm=Path(receipt['deployment'])/'share/gcompris-qt/translations/gcompris_qt_pt.qm';target=base/'catalogue'/(phase+'.qm');target.parent.mkdir(exist_ok=True);shutil.copyfile(qm,target)
  if sha(target)!=receipt['private_qm_sha256']:raise ValueError('Actual compiled catalogue differs')
 files={path.relative_to(base).as_posix():sha(path) for path in sorted(base.rglob('*')) if path.is_file() and not any(part.startswith('.') for part in path.relative_to(base).parts)}
 (base/'index.json').write_text(json.dumps({'phases':PHASES,'cases':CASES,'files':files,'scope':'80 primary puzzles,13 levels; controls and red/checkpoint separate; Linux offline only'},indent=2)+'\n')
if __name__=='__main__':main()
