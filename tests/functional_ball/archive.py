#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Archive exact historical source bytes and actual effective Qt RCCs."""
import hashlib,io,json,shutil,subprocess,tarfile
from pathlib import Path
from phase import ROOT,freeze
PHASES={'baseline':'e17dfac0402d085ed87bd47ab03724f2cb60d544','published':'f9431f525','catch-help':'7bf038204','penalty-help':'597c05f0b','reset':'5df4fff50c9edf0ffb0a35460d2e2c50ba1702d4'}
CASES={
 'catch-keyboard':dict(activity='ballcatch',phase='catch-help',kind='gameplay',input='arrow-key'),
 'catch-hands':dict(activity='ballcatch',phase='catch-help',kind='gameplay',input='mouse-on-hand'),
 'penalty-replay':dict(activity='penalty',phase='penalty-help',kind='gameplay'),
 'catch-controls':dict(activity='ballcatch',phase='penalty-help',kind='controls'),
 'penalty-controls-red':dict(activity='penalty',phase='penalty-help',kind='navigation-red',expected_exit=1),
 'penalty-controls-green':dict(activity='penalty',phase='reset',kind='controls'),
 'contract-red':dict(activity='ballcatch',phase='baseline',kind='contract-red',expected_exit=1),
 'contract-green':dict(activity='ballcatch',phase='published',kind='contract-green'),
 'help-red':dict(activity='ballcatch',phase='published',kind='help-red',expected_exit=1),
 'help-green':dict(activity='ballcatch',phase='catch-help',kind='help-green'),
 'penalty-contract-red':dict(activity='penalty',phase='catch-help',kind='contract-red',expected_exit=1),
 'penalty-contract-green':dict(activity='penalty',phase='penalty-help',kind='contract-green'),
 'penalty-help-red':dict(activity='penalty',phase='catch-help',kind='help-red',expected_exit=1),
 'penalty-help-green':dict(activity='penalty',phase='penalty-help',kind='help-green'),
 'penalty-complete':dict(activity='penalty',phase='penalty-help',kind='shutdown-diagnostic',expected_exit=1,qt_exit=139)
}

def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def main():
 base=ROOT/'.scratch/pt-pt/functional-ball';snapshot=base/'snapshot';tool=Path('/tmp/pt-audio-rcc-inventory')
 if (base/'index.json').exists():raise ValueError('Archive already sealed')
 (base/'execution-tools').mkdir(exist_ok=True)
 commands=[];resources={};capsules={}
 for phase,revision in PHASES.items():PHASES[phase]=subprocess.check_output(['git','rev-parse',revision],cwd=ROOT,text=True).strip()
 for phase,revision in PHASES.items():
  source=freeze(revision);manifest=json.loads((source/'source-manifest.json').read_text());capsules[phase]=manifest;target=base/'sources'/phase;target.mkdir(parents=True,exist_ok=True)
  shutil.copyfile(source/'source-manifest.json',target/'source-manifest.json')
  with tarfile.open(target/'source.tar.xz','w:xz') as capsule:
   for path in sorted(manifest['files']):
    raw=(source/path).read_bytes()
    if hashlib.sha256(raw).hexdigest()!=manifest['files'][path] or raw!=subprocess.check_output(['git','show',revision+':'+path],cwd=ROOT):raise ValueError('Historical source mismatch')
    entry=tarfile.TarInfo(path);entry.size=len(raw);entry.mtime=0;entry.mode=0o644;capsule.addfile(entry,io.BytesIO(raw))
 for name,description in CASES.items():
  receipt=json.loads((base/name/'result.json').read_text());rcc=Path(receipt['deployment'])/'share/gcompris-qt/rcc'/(description['activity']+'.rcc');export=ROOT/'build/functional-ball/exported'/name
  command=[str(tool),str(rcc.resolve()),str(export.resolve())];completed=subprocess.run(command,capture_output=True,text=True);commands.append({'argv':command,'exit_code':completed.returncode});completed.check_returncode();files=json.loads(completed.stdout)
  if sha(rcc)!=receipt['private_rcc_sha256']:raise ValueError('Actual effective RCC differs from native receipt')
  destination=base/'effective'/name;destination.mkdir(parents=True,exist_ok=True);shutil.copyfile(rcc,destination/'activity.rcc')
  for entry in files:
   path=entry['path'].removeprefix(':/gcompris/');target=destination/'files'/path;target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(export/'gcompris'/path,target)
  resources[name]={'rcc_sha256':sha(rcc),'files':files,'runtime_output':str((base/name).resolve()),'runtime_source':str((ROOT/'build/functional-ball/sources'/PHASES[description['phase']]).resolve())}
 extras={
  'core':['src/core/Bonus.qml',*[f'src/core/resource/sounds/{name}.wav' for name in ['smudge','brick','flip','bonus']]],
  'ballcatch':['src/activities/ballcatch/resource/tuxok.wav','src/activities/ballcatch/resource/youcannot.wav'],
 }

 imports={}
 for name,paths in extras.items():
  rcc=snapshot/'share/gcompris-qt/rcc'/(name+'.rcc');export=ROOT/'build/functional-ball/exported'/('import-'+name)
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
 for phase,case_name in [('baseline','contract-red'),('published','contract-green'),('catch-help','catch-hands'),('penalty-help','penalty-replay'),('reset','penalty-controls-green')]:
  receipt=json.loads((base/case_name/'result.json').read_text());qm=Path(receipt['deployment'])/'share/gcompris-qt/translations/gcompris_qt_pt.qm';target=base/'catalogue'/(phase+'.qm');target.parent.mkdir(exist_ok=True);shutil.copyfile(qm,target)
  if sha(target)!=receipt['private_qm_sha256']:raise ValueError('Actual compiled catalogue differs')
 files={path.relative_to(base).as_posix():sha(path) for path in sorted(base.rglob('*')) if path.is_file() and not any(part.startswith('.') or part=='snapshot' for part in path.relative_to(base).parts)}
 (base/'index.json').write_text(json.dumps({'phases':PHASES,'cases':CASES,'files':files,'scope':'27 complete route-levels/18 unique levels; original penalty shutdown139 retained separately; Linux offline only'},indent=2)+'\n')
if __name__=='__main__':main()
