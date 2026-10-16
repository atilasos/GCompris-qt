#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Pure audit of physical orientation evidence; all checks survive Python -O."""
import argparse,hashlib,json,re,sys,tarfile
from pathlib import Path,PurePosixPath
from oracle import relation,meaning,matches
ROOT=Path(__file__).resolve().parents[2]
EXPECTED_INDEX_SHA256='0eb2813a2db587e61c88eb05a7ee1af0da41d3a0f45cda4378682a3732354871'
FILES={'leftright':'Leftright.qml','positions':'Positions.qml','left_right_click':'Left_right_click.qml'}
def sha(raw):return hashlib.sha256(raw).hexdigest()
def require(condition,message):
 if not condition:raise ValueError(message)
def audit(base):
 def read(path):return json.loads((base/path).read_text())
 require(sha((base/'index.json').read_bytes())==EXPECTED_INDEX_SHA256,'Immutable original index')
 index=read('index.json');require(len(index['cases'])==11,'Nonempty exact historical case set')
 for path,digest in index['files'].items():
  parsed=PurePosixPath(path);require(not parsed.is_absolute() and '..' not in parsed.parts,'Relative evidence path')
  require(sha((base/path).read_bytes())==digest,'Physical archive bytes: '+path)
 sources={};manifests={}
 for phase,revision in index['phases'].items():
  manifest=read('sources/'+phase+'/source-manifest.json');require(manifest['revision']==revision,'Historical phase commit');raw={}
  with tarfile.open(base/'sources'/phase/'source.tar.xz','r:xz') as capsule:
   for entry in capsule.getmembers():
    parsed=PurePosixPath(entry.name);require(entry.isfile() and not parsed.is_absolute() and '..' not in parsed.parts and entry.name not in raw,'Regular unique capsule member')
    raw[entry.name]=capsule.extractfile(entry).read()
  require({path:sha(data) for path,data in raw.items()}==manifest['files'],'All physical source bytes and manifest')
  sources[phase]=raw;manifests[phase]=manifest['files']
 snapshot=read('snapshot-manifest.json');require(len(snapshot['files'])==269,'Sealed runtime resource identity')
 semantic=read('hand-semantics.json')['images'];require(len(semantic)==8,'All independently inspected photographs')
 for name,entry in semantic.items():require(sha(sources['baseline']['src/activities/leftright/resource/'+name])==entry['sha256'],'Anatomical inventory photo identity')
 resources=read('qt-resources.json');curriculum=read('inventory.json');coverage={};wrongs=0;controls=0;mouse_buttons={'left':0,'right':0};input_modes={'keyboard':0,'mouse':0}
 for name,description in index['cases'].items():
  activity=description['activity'];phase=description['phase'];source=manifests[phase];native=read(name+'/result.json');status=read(name+'/launcher-status.json');tool=read(name+'/tool-status.json');case=(base/name/'case.qml').read_bytes();expected_exit=description.get('expected_exit',0)
  require(native['activity']==activity and native['locale']=='pt_PT' and native['network']=='docker-none','Native offline activity and locale')
  require(native['exit_code']==0 and not native['timeout'],'Observed Qt process return')
  require(status['format']==1 and status['kind']=='observed-subprocess-exit' and status['exit_code']==expected_exit,'Observed post-wait launcher status')
  require(tool['format']==1 and tool['kind']=='observed-runner-exit-after-wait' and tool['exit_code']==expected_exit,'Observed post-wait tool status')
  require(status['native_receipt_sha256']==tool['native_receipt_sha256']==sha((base/name/'result.json').read_bytes()),'Separate statuses bind exact raw Qt receipt')
  require(status['case_sha256']==tool['case_sha256']==native['case_sha256']==sha(case),'Executed exact physical case')
  require(status['launcher_sha256']==native['runner_sha256']==source['tools/run-native-qml-case.py']==sha((base/'execution-tools/run-native-qml-case.py').read_bytes()),'Historical native launcher identity')
  require(tool['capture_sha256']==sha((base/'execution-tools/capture.py').read_bytes()),'Observed capture source')
  require(tool['runner_sha256'] in {sha((base/'execution-tools'/version).read_bytes()) for version in ['run-original.py','run-final.py']},'Exact observed runner bytes')
  for filename in ['run-native-qml-supervised.py','native_qml_supervision.py']:require(sha((base/'execution-tools'/filename).read_bytes())==source['tools/'+filename],'Frozen common supervision code')
  require(native['source_sha256']==source['src/activities/'+activity+'/'+FILES[activity]],'Physical historical QML identity')
  require(native['portuguese_catalogue_sha256']==source['poqm/pt/gcompris_qt.po'],'Physical historical Portuguese catalogue')
  require(native['private_qm_sha256']==sha((base/'catalogue'/(phase+'.qm')).read_bytes()),'Actual compiled PT catalogue')
  expected=dict(snapshot['files']);expected['share/gcompris-qt/rcc/'+activity+'.rcc']=native['private_rcc_sha256'];expected['share/gcompris-qt/translations/gcompris_qt_pt.qm']=native['private_qm_sha256']
  require(native['resource_files_sha256']==expected and native['resource_manifest_sha256']==sha((base/'snapshot-manifest.json').read_bytes()),'All effective runtime files')
  require(native['binary_sha256']==snapshot['files']['bin/gcompris-qt'],'Native snapshot binary')
  effective=resources['effective'][name];require(sha((base/'effective'/name/'activity.rcc').read_bytes())==effective['rcc_sha256']==native['private_rcc_sha256'],'Actual loaded private RCC')
  expected_paths={path for path in sources[phase] if path.startswith('src/activities/'+activity+'/')};require({row['path'].removeprefix(':/gcompris/') for row in effective['files']}==expected_paths,'All effective activity resource files')
  for row in effective['files']:
   path=row['path'].removeprefix(':/gcompris/');actual=(base/'effective'/name/'files'/path).read_bytes();wanted=sources[phase][path]
   if path=='src/activities/'+activity+'/'+FILES[activity]:
    original=wanted.decode();closing=re.search(r'\n    }\s*\n}\s*$',original);fragment=case.decode().replace('__QA_OUTPUT__',effective['runtime_output']).replace('__QA_SOURCE__',effective['runtime_source']);wanted=('import QtTest\n'+original[:closing.start()]+'\n'+fragment+original[closing.start():]).encode()
   require(sha(actual)==row['sha256'] and len(actual)==row['bytes'] and actual==wanted,'Effective Qt resource and exact historical instrumentation')
  for image in native['screenshots']:require(sha((base/name/image['file']).read_bytes())==image['sha256'],'Real native screenshot')
  result=native['case_result'];require(result['failures']==(1 if description['kind']=='translation-red' else 0),'Native QtTest assertion outcome')
  if description['kind']=='translation-red':
   require(not native['passed'] and not native['qml_errors'] and result['evidence']['physicalRightIgnored'] and result['evidence']['screenAnswerWorks'] and 'botão esquerdo ou direito do rato' in result['evidence']['help'],'Actual misleading PT manual reproduction');continue
  if expected_exit:
   require(not native['passed'] and len(result['completed'])==22 and native['qml_errors'] and all('Animal.qml' in error and ('width' in error or 'height' in error) for error in native['qml_errors']),'Actual model-lifetime error reproduction');continue
  require(native['passed'] and not native['qml_errors'],'Clean native case')
  if description['kind']=='gameplay':
   rows=result['completed'];require(activity not in coverage,'One final primary campaign per activity');coverage[activity]=rows
   if activity=='leftright':
    require(len(rows)==32 and result['wins']==6,'Complete hands and natural Bonus')
    for level,rule in enumerate(curriculum['leftright'],1):
     selected=[r for r in rows if r['level']==level];require({(r['stimulus']['image'],r['stimulus']['rotation']) for r in selected}=={(image,rotation) for image in rule['images'] for rotation in rule['rotations']} and len(selected)==len(rule['images'])*len(rule['rotations']),'Every hand photograph and published rotation')
    for row in rows:require(not row['stimulus']['mirror'] and row['side']==semantic[row['stimulus']['image']]['side'],'Anatomical handedness, independent of screen rotation');wrongs+=int(row['wrong_repaired']);input_modes[row['input']]+=1
   elif activity=='positions':
    require(len(rows)==26 and result['wins']==4,'Both position modes and natural Bonus')
    names={'in front of':'front','above':'above','under':'under'}
    for level,rule in enumerate(curriculum['positions'],1):
     selected=[r for r in rows if r['level']==level];seen=set()
     require(len(selected)==len(rule['relations']),'Every relation in published dataset')
     for row in selected:
      require(row['mode']==rule['mode'],'Visible position mode');text_mode=row['mode']=='picture-to-text';want=relation(row['requested']) if text_mode else meaning(row['requested']);options=[meaning(option) if text_mode else relation(option) for option in row['options']]
      require(len(options)==(3 if level<3 else 4) and len(options)==len(set(options)),'Painted distinct answer choices')
      require(0<=row['index']<len(options) and matches(want,options[row['index']]) if text_mode else 0<=row['index']<len(options) and matches(options[row['index']],want),'Independent relative geometry and PT choice')
      if row['wrong'] is not None:require(not (matches(want,options[row['wrong']['index']]) if text_mode else matches(options[row['wrong']['index']],want)),'Actual wrong relation');wrongs+=1
      seen.add('beside' if level==2 and want in ['left','right'] else want);input_modes[row['input']]+=1
     require(seen=={names.get(value,value) for value in rule['relations']},'All visible question meanings, not repeated sample')
   else:
    require(len(rows)==22 and result['wins']==3,'All animals and natural Bonus')
    for level,count in enumerate(curriculum['left_right_click'],1):
     selected=[r for r in rows if r['level']==level];require(len(selected)==count,'All drawn animals in level');require(sum(r['image']=='fish.svg' for r in selected)==[3,3,5][level-1],'Both animal types and published quantities')
    for row in rows:
     fish=row['image']=='fish.svg';require(row['image'] in ['fish.svg','monkey.svg'] and row['button']==('left' if fish else 'right') and row['home']==('pond' if fish else 'tree'),'Independent animal and home semantics')
     box=row['bounds'];point=row['destination'];require(box['x']<=point['x']<=box['x']+box['width'] and box['y']<=point['y']<=box['y']+box['height'],'Real animal motion reaches painted home');mouse_buttons[row['button']]+=1
     if row['wrong'] is not None:require(row['wrong']['unchanged'] and row['wrong']['button']!=row['button'],'Wrong physical button and repair');wrongs+=1
  elif description['kind']=='translation-green':
   evidence=result['evidence'];require(evidence['physicalRightIgnored'] and evidence['screenAnswerWorks'] and evidence['menu'] and '«Mão esquerda»' in evidence['help'] and '«Mão direita» no ecrã' in evidence['help'],'Correct PT screen-answer instruction')
  elif description['kind']=='controls':
   evidence=result['evidence'];require(all(evidence.get(key) is True for key in ['focusAfterHelp','navigationReset','wrap','menu']),'Common control routes')
   require(evidence['help']['title'] and evidence['help']['content'],'Actual PT help')
   if activity=='positions':require(evidence['persistedSelection'] and evidence['restoredSelection'] and not evidence['reloadOffered'],'Dataset persistence and offered controls')
   elif activity=='left_right_click':require(evidence['partialReload'] and evidence['unsupportedKeys'] and not evidence['configurationOffered'],'Offered mouse controls')
   else:require(not evidence['reloadOffered'] and not evidence['configurationOffered'],'Hand activity offers navigation but no reload/configuration')
   controls+=1
 for resource,observation in resources['imports'].items():
  require(observation['rcc_sha256']==snapshot['files']['share/gcompris-qt/rcc/'+resource+'.rcc'],'Imported actual RCC')
  for row in observation['files']:
   path=row['path'].removeprefix(':/gcompris/');raw=(base/'imports'/path).read_bytes();require(sha(raw)==row['sha256'] and len(raw)==row['bytes'],'Physical imported source/assets')
 require(set(coverage)==set(FILES) and sum(map(len,coverage.values()))==80 and wrongs==13 and controls==3,'Nonempty complete final coverage')
 for red,green in [('mouse-red','mouse-complete'),('hand-help-red','hand-help-green')]:require((base/red/'case.qml').read_bytes()==(base/green/'case.qml').read_bytes(),'Exact red/green regression')
 return {'passed':True,'questions':80,'levels':13,'curriculum':{'hand_levels':6,'position_datasets':2,'mouse_levels':3},'wrong_repaired':wrongs,'controls':controls,'native_receipts':11,'mouse_buttons':mouse_buttons,'answer_inputs':input_modes,'scope':'Linux offline; all published levels/modes, not all random permutations; Windows/devices/audio/teacher review pending'}
def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--evidence',type=Path,default=ROOT/'.scratch/pt-pt/functional-orientation');args=parser.parse_args()
 try:print(json.dumps(audit(args.evidence),indent=2))
 except (ValueError,OSError,KeyError,TypeError,tarfile.TarError) as error:print('Orientation evidence rejected: '+str(error),file=sys.stderr);return 1
 return 0
if __name__=='__main__':raise SystemExit(main())
