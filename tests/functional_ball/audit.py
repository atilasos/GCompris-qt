#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Pure audit of physical orientation evidence; all checks survive Python -O."""
import argparse,hashlib,json,re,sys,tarfile
from pathlib import Path,PurePosixPath

ROOT=Path(__file__).resolve().parents[2]
EXPECTED_INDEX_SHA256='b2ffbae0afb4cf46645dd7d3ff630a64b1b20c4293899172c655f3188ddba88d'
FILES={'ballcatch':'Ballcatch.qml','penalty':'Penalty.qml'}
def sha(raw):return hashlib.sha256(raw).hexdigest()
def require(condition,message):
 if not condition:raise ValueError(message)
def audit(base):
 def read(path):return json.loads((base/path).read_text())
 require(sha((base/'index.json').read_bytes())==EXPECTED_INDEX_SHA256,'Immutable original index')
 index=read('index.json');require(len(index['cases'])==15,'Nonempty exact historical case set')
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
 resources=read('qt-resources.json');coverage={};controls=0;wrongs=0
 for name,description in index['cases'].items():
  activity=description['activity'];phase=description['phase'];source=manifests[phase];native=read(name+'/result.json');status=read(name+'/launcher-status.json');tool=read(name+'/tool-status.json');case=(base/name/'case.qml').read_bytes();expected_exit=description.get('expected_exit',0)
  require(native['activity']==activity and native['locale']=='pt_PT' and native['network']=='docker-none','Native offline activity and locale')
  require(native['exit_code']==description.get('qt_exit',0) and not native['timeout'],'Observed Qt process return')
  require(status['format']==1 and status['kind']=='observed-subprocess-exit' and status['exit_code']==expected_exit,'Observed post-wait launcher status')
  require(tool['format']==1 and tool['kind']=='observed-exec-tool-return' and tool['exit_code']==expected_exit,'Observed post-wait tool status')
  require(status['native_receipt_sha256']==tool['native_receipt_sha256']==sha((base/name/'result.json').read_bytes()),'Separate statuses bind exact raw Qt receipt')
  require(status['case_sha256']==native['case_sha256']==sha(case),'Executed exact physical case')
  require(status['launcher_sha256']==native['runner_sha256']==source['tools/run-native-qml-case.py']==sha((base/'execution-tools/run-native-qml-case.py').read_bytes()),'Historical native launcher identity')
  require(isinstance(tool['session_id'],int) and tool['session_id']>0 and tool['chunk_id'] and tool['provenance'] and tool['launcher_status_sha256']==sha((base/name/'launcher-status.json').read_bytes()),'Actually observed external tool return and exact supervisor receipt')
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
  result=native['case_result'];kind=description['kind']
  if kind=='shutdown-diagnostic':
   require(not native['passed'] and result['failures']==0 and len(result['levels'])==9 and native['exit_code']==139 and expected_exit==1,'Original completed assertions with failed native shutdown remains non-green')
   continue
  if expected_exit:
   require(not native['passed'] and result['failures']==1 and not native['qml_errors'],'Actual QtTest red assertion with process0')
   if kind=='contract-red':require(result['evidence']=={'current':0,'total':0},'Public total0 reproduction')
   elif kind=='navigation-red':require(any(bar['visible'] and bar['color']=='#ff0000' and bar['width']>0 for bar in result['evidence']['afterNavigation']['bars']),'Visible stale bar in new level')
   elif kind=='help-red':require(not result['evidence']['goal'],'Actual incorrect PT instruction/goal')
   continue
  require(native['passed'] and not native['qml_errors'] and result['failures']==0,'Clean standard native run')
  if kind=='gameplay':
   rows=result['levels'];require([r['level'] for r in rows]==list(range(1,10)),'Complete nine-level route with natural progression');coverage[name]=rows
   for row in rows:
    wrongs+=1;require('bad' in row['wrong']['bonus'] and 'good' in row['correct']['bonus'],'Real visible failure/repair and natural success Bonus')
    before=row['before'];correct=row['correct']['path'];require(len(correct)>2,'Observed trajectory samples')
    if activity=='ballcatch':
     target=row['target'];miss=row['wrong']['path'];require(len(miss)>3 and abs(before['x']-target['x'])<1 and abs(miss[-1]['x']-target['x'])>target['width']/2,'Independent geometry of missing Tux')
     require(all(abs(p['x']-before['x'])<1 for p in correct) and correct[-1]['y']<before['y']-20,'Independent straight successful trajectory')
     require(row['wrongInput']['kind']==description['input'] and row['wrongInput']['side'] in ['left','right'],'Actual delayed/incomplete input')
     require([r['side'] for r in row['inputs']]==['left','right'] and all(r['kind']==description['input'] for r in row['inputs']),'Both real presented inputs')
     require(all(row['inputs'][i]['timestamp']<=row['inputs'][i+1]['timestamp'] for i in range(len(row['inputs'])-1)),'Observed input ordering without reading thresholds')
    else:
     target=row['target'];goal=row['goal'];require((row['zone'],row['button'])==((row['level']-1)%3,(row['level']-1)//3),'Three zones and three mouse buttons distributed over levels')
     require(goal['x']-goal['width']/2<target['x']<goal['x']+goal['width']/2 and goal['y']-goal['height']/2<target['y']<goal['y']+goal['height']/2,'Chosen visible region inside goal')
     require(any(bar['visible'] and bar['color']=='#ff0000' and bar['width']>0 for bar in row['wrong']['bars']),'Single delayed click visibly exhausts red bar')
     bar=row['stoppedBar'];require(bar['visible'] and bar['color']=='#00ff00' and 0<bar['width']<bar['total'] and row['firstClick']<=row['secondClick'],'Second real click while drawn bar green')
     require(abs(correct[-1]['x']-target['x'])<3 and abs(correct[-1]['y']-target['y'])<3,'Visible shot reaches selected goal region')
     require('baliza' in row['initialText'] and 'bola' in row['repairText'] and 'posição original' in row['repairText'],'Painted Portuguese goal/repair instructions')
  elif kind=='contract-green':require(result['evidence']=={'current':0,'total':9},'Published total matches nine real levels')
  elif kind=='help-green':
   evidence=result['evidence'];require(evidence['title'] and evidence['content'] and evidence['goal'],'PT help route')
   require(evidence['manual'] if activity=='ballcatch' else evidence['delay'],'Correct tactile/timing instruction')
  elif kind=='controls':
   evidence=result['evidence'];require(all(evidence.get(k) is True for k in ['escape','focusAfterHelp','partialRestart','wrap','menu']),'Actual help/Escape/focus/partial restart/navigation/menu')
   require(not evidence['reloadOffered'] and not evidence['configurationOffered'] and evidence['help']['title'] and evidence['help']['content'],'Only controls actually offered')
   if activity=='ballcatch':require(evidence['correctAfterHelp'],'Real synchronized keyboard input after help')
   else:require(evidence['unsupportedKeyboard'] and all(not bar['visible'] and bar['width']==0 for bar in evidence['afterNavigation']['bars']),'Unsupported keyboard unchanged; old shot stopped on public navigation')
   controls+=1

 for resource,observation in resources['imports'].items():
  require(observation['rcc_sha256']==snapshot['files']['share/gcompris-qt/rcc/'+resource+'.rcc'],'Imported actual RCC')
  for row in observation['files']:
   path=row['path'].removeprefix(':/gcompris/');raw=(base/'imports'/path).read_bytes();require(sha(raw)==row['sha256'] and len(raw)==row['bytes'],'Physical imported source/assets')
 require(set(coverage)=={'catch-keyboard','catch-hands','penalty-replay'} and sum(map(len,coverage.values()))==27 and wrongs==27 and controls==2,'Exact nonempty 27 route-levels/18 unique levels')
 for red,green in [('contract-red','contract-green'),('help-red','help-green'),('penalty-contract-red','penalty-contract-green'),('penalty-help-red','penalty-help-green'),('penalty-controls-red','penalty-controls-green')]:require((base/red/'case.qml').read_bytes()==(base/green/'case.qml').read_bytes(),'Exact historical red/green case')
 require((base/'penalty-complete/case.qml').read_bytes()==(base/'penalty-replay/case.qml').read_bytes(),'Original139 and successful replay use exact same case')
 commands=read('resource-commands.json')['commands'];require(len(commands)==23 and all(c['exit_code']==0 for c in commands),'Observed15 RCC exports plus2 imports and6 WAV decodes')
 return {'passed':True,'route_levels':27,'unique_levels':18,'wrong_repaired':27,'controls':2,'native_receipts':15,'historical_shutdown_failures':1,'scope':'Linux offline only; original native139 remains unresolved historical diagnostic, exact replay0; not all input combinations; Windows/devices/touch/audio/teacher pending'}
def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--evidence',type=Path,default=ROOT/'.scratch/pt-pt/functional-ball');args=parser.parse_args()
 try:print(json.dumps(audit(args.evidence),indent=2))
 except (ValueError,OSError,KeyError,TypeError,tarfile.TarError) as error:print('Ball coordination evidence rejected: '+str(error),file=sys.stderr);return 1
 return 0
if __name__=='__main__':raise SystemExit(main())
