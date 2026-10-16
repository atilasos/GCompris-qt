#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Pure audit of physical arithmetic challenge evidence; all checks survive Python -O."""
import argparse,hashlib,json,re,sys,tarfile
from pathlib import Path,PurePosixPath
from fractions import Fraction
from solver import calculate,admissible
from inventory import inventory_from_text
ROOT=Path(__file__).resolve().parents[2]
EXPECTED_INDEX_SHA256='27c4850c2c0df1307eef9f55051b32b47cbae1a0ed9ef183f96790893749f3de'
FILES={'guess24':'Guess24.qml','guesscount':'Guesscount.qml'}
def sha(raw):return hashlib.sha256(raw).hexdigest()
def require(condition,message):
 if not condition:raise ValueError(message)
def check_steps(row,activity,correct):
 values=list(row['values']);operators=row['operators'];steps=row['steps'];require(values and operators,'Nonempty visible operands/operators')
 if activity=='guess24':
  require(len(values)==4 and len(steps)==3,'Four cards and three binary operations');state=dict(enumerate(values))
  for step in steps:
   a,b=step['a'],step['b'];require(a!=b and a in state and b in state,'Only remaining visible cards');left,right=state.pop(a),state.pop(b);require(step['left']==left and step['right']==right and step['op'] in operators,'Independent visible pair operands');value=calculate(left,step['op'],right);require(admissible(value) and value==step['result'],'Exact nonnegative integer arithmetic');state[b]=int(value)
  result=next(iter(state.values()))
 else:
  require(len(steps)==len(operators),'One operation per visible row; operators may be reused');used={steps[0]['a']};require(0<=steps[0]['a']<len(values),'First painted operand');result=values[steps[0]['a']]
  for step in steps:
   b=step['b'];require(0<=b<len(values) and b not in used and step['op'] in operators,'Unused drawn number and available operator');used.add(b);require(step['left']==result and step['right']==values[b],'Independent previous row result');value=calculate(result,step['op'],values[b]);require(admissible(value) and value==step['result'],'Exact rational arithmetic respects integer UI');result=int(value)
 require((result==row['target']) is correct,'Independent target equality or intentional wrong answer')

def audit(base):
 def read(path):return json.loads((base/path).read_text())
 require(sha((base/'index.json').read_bytes())==EXPECTED_INDEX_SHA256,'Immutable original index')
 index=read('index.json');require(len(index['cases'])==22,'Nonempty exact historical case set')
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
 resources=read('qt-resources.json');curriculum=read('inventory.json');require(curriculum==inventory_from_text(lambda path:sources['language'][path].decode()),'Published curriculum equals physical immutable source');coverage={'guess24':[],'guesscount':[],'admin':[]};wrongs=0;controls=0;inputs={'keyboard':0,'mouse':0,'drag':0}
 for name,description in index['cases'].items():
  activity=description['activity'];phase=description['phase'];source=manifests[phase];native=read('native/'+name+'/result.json');status=read('native/'+name+'/launcher-status.json');tool=read('native/'+name+'/tool-status.json');case=(base/'native'/name/'case.qml').read_bytes();expected_exit=description.get('expected_exit',0)
  require(native['activity']==activity and native['locale']=='pt_PT' and native['network']=='docker-none','Native offline activity and locale')
  require(native['exit_code']==0 and not native['timeout'],'Observed Qt process return')
  require(status['format']==1 and status['kind']=='observed-subprocess-exit' and status['exit_code']==expected_exit,'Observed post-wait launcher status')
  require(tool['format']==1 and tool['kind']=='observed-runner-exit-after-wait' and tool['exit_code']==expected_exit,'Observed post-wait tool status')
  require(status['native_receipt_sha256']==tool['native_receipt_sha256']==sha((base/'native'/name/'result.json').read_bytes()),'Separate statuses bind exact raw Qt receipt')
  require(status['case_sha256']==tool['case_sha256']==native['case_sha256']==sha(case),'Executed exact physical case')
  require(status['launcher_sha256']==native['runner_sha256']==source['tools/run-native-qml-case.py']==sha((base/'execution-tools/run-native-qml-case.py').read_bytes()),'Historical native launcher identity')
  require(tool['capture_sha256']==sha((base/'execution-tools/capture.py').read_bytes()),'Observed capture source')
  require(tool['runner_sha256'] in {sha((base/'execution-tools/run.py').read_bytes())},'Exact observed runner bytes')
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
  for image in native['screenshots']:require(sha((base/'native'/name/image['file']).read_bytes())==image['sha256'],'Real native screenshot')
  result=native['case_result']
  if expected_exit:
   require(not native['passed'] and not native['qml_errors'] and result['failures']==1,'Actual clean QtTest red assertion')
   continue
  require(native['passed'] and not native['qml_errors'] and result['failures']==0,'Clean native case')
  if description['kind'] in ['gameplay','admin']:
   mode='admin' if description['kind']=='admin' else activity
   rows=result['completed'];coverage[mode]+=rows;require(result['wins']==description['levels'],'Natural Bonus for every requested level')
   for level in range(description['start'],description['start']+description['levels']):
    selected=[r for r in rows if r['level']==level];rule=curriculum['admin']['schema'][level-1] if mode=='admin' else curriculum[activity][level-1]['count'];require(len(selected)==rule and [r['question'] for r in selected]==list(range(1,rule+1)),'Complete natural level without missing/repeated ordinal')
   for row in rows:
    check_steps(row,activity,True)
    if activity=='guess24':
     rule=curriculum['guess24'][row['level']-1];require(row['operators']==['+','-','*','/'][:rule['operatorsCount']],'Drawn operators match dataset')
     require(any(sorted(c['values'])==sorted(row['values']) and c['complexity'] in rule['complexities'] for c in curriculum['corpus']),'Draw belongs to published complexity corpus');inputs[row['input']]+=1
    else:
     require(row['mode']==('admin' if mode=='admin' else 'builtin'),'Actual selected mode')
     if mode=='admin':
      operators=curriculum['admin']['operators'][row['level']-1];pool=next(p[1] for p in curriculum['admin']['data'][len(operators)-1] if set(p[0])==set(operators))
     else:
      rule=curriculum['guesscount'][row['level']-1];operators=rule['operators'];matches=[p[1] for g in rule['groups'] for p in g if set(p[0])==set(operators)];previous=sum(1 for earlier in curriculum['guesscount'][:row['level']-1] if set(earlier['operators'])==set(operators));pool=matches[previous]
     require(row['operators']==operators,'Painted available operators');require(any(sorted(v)==sorted(row['values']) and t==row['target'] for v,t in pool),'Correct published question pool');inputs['drag']+=1
    if row['wrong'] is not None:
     if row['wrong'].get('steps') is not None:check_steps(dict(row,steps=row['wrong']['steps']),activity,False)
     else:require(row['wrong'].get('typeRejected') is True,'Wrong tile kind actually rejected')
     if activity=='guess24':require(row['wrong']['hintShown'] and row['wrong']['restored'],'Hint opened and actual undo restored original cards')
     wrongs+=1
    for rejected in row['rejected']:
     value=calculate(rejected['left'],rejected['op'],rejected['right']);require(not admissible(value) and rejected['reason'] in ['negative','fraction'],'Independent invalid operation')
  elif description['kind']=='controls':
   evidence=result['evidence'];require(all(evidence.get(k) is True for k in ['focusAfterHelp','navigationReset','wrap','menu','persistedSelection']),'Common public controls and persistence');require(evidence['help']['title'] and evidence['help']['content'] and not evidence['reloadOffered'],'PT help and controls actually offered')
   if activity=='guess24':require(evidence['undoDelete'] and evidence['tabOperatorSelection'] and evidence['restoredSelection'],'Real keyboard and selection restoration')
   else:
    require(evidence['unsupportedKeys'] and evidence['emptyOperatorsRefused'] and evidence['persistedEditor'] and evidence['restoredEditor'],'Finite public editor invalid/valid configuration')
    require(len(evidence['editedPuzzles'])==4,'Complete edited level')
    for row in evidence['editedPuzzles']:check_steps(row,'guesscount',True)
   controls+=1
  elif description['kind']=='translation-green':require(result['evidence']['menu'] and result['evidence']['instruction'].startswith('Número a obter: '),'Actual corrected PT target label')

 for resource,observation in resources['imports'].items():
  require(observation['rcc_sha256']==snapshot['files']['share/gcompris-qt/rcc/'+resource+'.rcc'],'Imported actual RCC')
  for row in observation['files']:
   path=row['path'].removeprefix(':/gcompris/');raw=(base/'imports'/path).read_bytes();require(sha(raw)==row['sha256'] and len(raw)==row['bytes'],'Physical imported source/assets')
 require({k:len(v) for k,v in coverage.items()}=={'guess24':100,'guesscount':56,'admin':30} and controls==2 and wrongs==31,'Exact nonempty complete curriculum coverage')
 for red,green in [('pool-red','pool-green'),('admin-red','admin-green'),('unsolvable-red','unsolvable-green'),('label-red','label-green')]:require((base/'native'/red/'case.qml').read_bytes()==(base/'native'/green/'case.qml').read_bytes(),'Identical real red/green case')
 witnesses=read('corpus-witnesses.json');require(len(witnesses)==1506,'All 1310 pair puzzles and196 published linear entries, not native draw count')
 expected=[]
 for dataset in range(1,5):
  rule=next(r for r in curriculum['guesscount'] if r['dataset']==dataset)
  for group in rule['groups']:
   for operators,pool in group:
    for values,target in pool:expected.append({'mode':'builtin','dataset':dataset,'values':values,'target':target,'operators':operators})
 for group in curriculum['admin']['data']:
  for operators,pool in group:
   for values,target in pool:expected.append({'mode':'admin','values':values,'target':target,'operators':operators})
 for row in curriculum['corpus']:
  operators=['+','-'] if row['complexity']==1 else ['+','-','*'] if row['complexity']==2 else ['+','-','*','/'];expected.append({'mode':'twenty-four','values':row['values'],'target':24,'complexity':row['complexity'],'operators':operators})
 require([{k:v for k,v in row.items() if k!='steps'} for row in witnesses]==expected,'One exact witness for every published physical entry')
 for row in witnesses:check_steps(row,'guess24' if row['mode']=='twenty-four' else 'guesscount',True)
 return {'passed':True,'primary_puzzles':186,'levels':31,'native_receipts':22,'wrong_repaired':wrongs,'controls':controls,'static_published_entries':len(witnesses),'answer_inputs':inputs,'scope':'Linux offline; full published levels/datasets/default modes and finite operator editor; 1310 pair puzzles statically solved, not all random draws played; Windows/devices/audio/teacher pending'}
def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--evidence',type=Path,default=ROOT/'.scratch/pt-pt/functional-challenges');args=parser.parse_args()
 try:print(json.dumps(audit(args.evidence),indent=2))
 except (ValueError,OSError,KeyError,TypeError,tarfile.TarError) as error:print('Arithmetic challenge evidence rejected: '+str(error),file=sys.stderr);return 1
 return 0
if __name__=='__main__':raise SystemExit(main())
