#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Audit immutable visible-candy receipts; checks remain active under Python -O."""
import argparse,hashlib,json,re,subprocess,sys
from pathlib import Path,PurePosixPath
from oracle import share
from phase import PREFIXES
ROOT=Path(__file__).resolve().parents[2]
PROOF_REVISION='ec31c9fb939c98cadede8cff5ad1ddfff7dcb7a6'
PREFIX='.scratch/pt-pt/functional-share/'
def sha(raw):return hashlib.sha256(raw).hexdigest()
def require(condition,message):
 if not condition:raise ValueError(message)
def audit(base,repository):
 def blob(revision,path):return subprocess.check_output(['git','-C',str(repository),'show',revision+':'+path])
 def read(path):return json.loads((base/path).read_text())
 index=read('index.json');require((base/'index.json').read_bytes()==blob(PROOF_REVISION,PREFIX+'index.json'),'Immutable proof index')
 for path,digest in index['files'].items():
  relative=PurePosixPath(path);require(not relative.is_absolute() and '..' not in relative.parts,'Relative archive file')
  require(sha((base/path).read_bytes())==digest,path)
 manifests={}
 for phase,revision in index['phases'].items():
  source=read('phases/'+phase+'/source-manifest.json');require(source['revision']==revision,'Historical source phase')
  paths=subprocess.check_output(['git','-C',str(repository),'ls-tree','-r','--name-only',revision,'--',*PREFIXES],text=True).splitlines()
  expected={path:sha(blob(revision,path)) for path in paths};require(source['files']==expected,'Historical Git source bytes')
  for name in ['run-native-qml-supervised.py','native_qml_supervision.py']:require(sha((base/name).read_bytes())==source['files']['tools/'+name],'Historical supervision tool')
  manifests[phase]=source['files']
 snapshot=read('snapshot-manifest.json');require(len(snapshot['files'])==269,'Sealed resource snapshot')
 resources=read('qt-resources.json')
 for name,resource in resources.items():
  phase=resource['source_phase'];revision=index['phases'][phase]
  if resource['kind']=='snapshot':
   require(resource['rcc_sha256']==snapshot['files']['share/gcompris-qt/rcc/'+name+'.rcc'],'Qt snapshot RCC identity')
  else:
   receipt=read(resource['receipt']+'/result.json')
   require(sha((base/resource['archive_rcc']).read_bytes())==resource['rcc_sha256']==receipt['private_rcc_sha256'],'Actual effective private RCC')
  for entry in resource['files']:
   path=entry['path'].removeprefix(':/gcompris/');raw=(base/resource['archive_prefix']/path).read_bytes()
   require(entry['sha256']==sha(raw) and entry['bytes']==len(raw),'Extracted actual Qt resource bytes')
   expected=blob(revision,path)
   if resource['kind']=='private' and path=='src/activities/share/Share.qml':
    original=expected.decode();closing=re.search(r'\n    }\s*\n}\s*$',original)
    fragment=(base/resource['receipt']/'case.qml').read_text().replace('__QA_OUTPUT__',resource['runtime_output']).replace('__QA_SOURCE__',resource['runtime_source'])
    expected=('import QtTest\n'+original[:closing.start()]+'\n'+fragment+original[closing.start():]).encode()
   require(raw==expected,'Qt resource equals historical source and exact instrumentation')
 # Inventory bytes are sealed in the index; validate their source through Git.
 curriculum=read('inventory.json');coverage={};wrong=0;transfers=0;remainders=0;controls=0
 for name,description in index['cases'].items():
  result=read(name+'/result.json');status=read(name+'/launcher-status.json');case=(base/name/'case.qml').read_bytes();source=manifests[description['phase']]
  expected_exit=description.get('expected_exit',0)
  require(status['format']==1 and status['kind']=='observed-subprocess-exit','Observed post-wait status')
  require(status['exit_code']==expected_exit,'Native launcher outer exit')
  require(status['native_receipt_sha256']==sha((base/name/'result.json').read_bytes()),'Outer receipt hash')
  require(status['case_sha256']==result['case_sha256']==sha(case),'Exact native case')
  require(status['launcher_sha256']==result['runner_sha256']==source['tools/run-native-qml-case.py'],'Historical native launcher')
  require(result['source_sha256']==source['src/activities/share/Share.qml'],'Historical QML source')
  require(result['portuguese_catalogue_sha256']==source['poqm/pt/gcompris_qt.po'],'Historical Portuguese catalogue')
  require(result['resource_manifest_sha256']==sha((base/'snapshot-manifest.json').read_bytes()),'Sealed snapshot identity')
  require(result['binary_sha256']==snapshot['files']['bin/gcompris-qt'],'Snapshot binary')
  require(result['exit_code']==0 and not result['timeout'] and not result['qml_errors'],'Healthy native process')
  require(result['network']=='docker-none' and result['locale']=='pt_PT','Offline PT runtime')
  for screenshot in result['screenshots']:require(sha((base/name/screenshot['file']).read_bytes())==screenshot['sha256'],'Native screenshot')
  native=result['case_result'];require(bool(result['passed'])==(expected_exit==0),'Expected native outcome')
  require(native['failures']==(0 if expected_exit==0 else 1),'Native assertions')
  if description['kind']=='campaign':
   require(native['wins']==5 and native['levelsCompleted']==list(range(description['start'],description['start']+5)),'Natural full-level Bonus')
   expected=[(level,q+1) for level in range(description['start'],description['start']+5) for q in range(len(curriculum[level-1]['subLevels']))]
   require([(r['level'],r['question']) for r in native['completed']]==expected,'Complete configured question coverage')
   for record in native['completed']:
    level,question=record['level'],record['question'];key=(description['mode'],level,question)
    require(key not in coverage,'Unique primary puzzle');coverage[key]=True
    require(record['easy']==(description['mode']=='counters'),'Available counter mode')
    initial,collected,final=(record[field] for field in ['initial','collected','final'])
    require([b['kind'] for b in initial]==[b['kind'] for b in collected]==[b['kind'] for b in final],'Same painted recipients')
    require(all(b['kind'] in ['boy','girl','basket'] and type(b['count']) is int and 0<=b['count']<=6 and str(b['count'])==b['label'] for b in initial+collected+final),'Drawn candy slots and labels')
    children=sum(b['kind']!='basket' for b in collected);total=sum(b['count'] for b in collected);quotient,remainder=share(children,total)
    require((record['children'],record['total'],record['quotient'],record['remainder'])==(children,total,quotient,remainder),'Independent division and remainder')
    require(sum(b['count'] for b in initial)+record['additions']==total==sum(b['count'] for b in final),'Conserved visible inventory')
    require(all(b['count']==(remainder if b['kind']=='basket' else quotient) for b in final),'Equal painted shares and basket remainder')
    require(remainder==0 or any(b['kind']=='basket' for b in final),'Visible remainder basket')
    published=curriculum[level-1]['subLevels'][question-1]
    boys=sum(b['kind']=='boy' for b in initial);girls=sum(b['kind']=='girl' for b in initial)
    if published['randomisedInputData']:
     require(1<=boys<=published['maxBoys'] and 1<=girls<=published['maxGirls'],'Published random recipient bounds')
     require(children<=total<=min(published['maxCandies'],7*children-1),'Published random inventory bounds')
    else:
     require((boys,girls,total)==(published['totalBoys'],published['totalGirls'],published['totalCandies']),'Published fixed puzzle exercised')
     require(all(b['count']==(published['placedInBoys'] if b['kind']=='boy' else published['placedInGirls'] if b['kind']=='girl' else 0) for b in initial),'Initially painted existing candies')
    require(record['instruction'] and not any(word in record['instruction'] for word in ['wants','pieces of candy','Then split']),'Portuguese visible instruction')
    if question==1:require(record['wrong'] is not None and record['wrong']['score']==0,'Error and subsequent repair');wrong+=1
    else:require(record['wrong'] is None,'Only planned wrong attempts')
    transfers+=record['transfers'];remainders+=int(remainder>0)
  elif description['kind']=='controls':
   evidence=native['evidence'];require(all(evidence.get(field) is True for field in ['focusAfterHelp','partialRestart','navigationAfterProgress','persistedModeAndDataset','restoredSelection','hintToggle','unsupportedKeysNoMutation','menu']),'Complete control routes')
   require('frasco de doces' in evidence['help']['content'],'Portuguese help');controls+=1
  elif description['kind']=='resources':
   evidence=native['evidence'];require(evidence['drawnChildAndCandy'] and len(evidence['images'])==4 and all(image['status']==1 and image['width']>0 and image['height']>0 for image in evidence['images']),'Four Qt SVGs ready')
  elif description['kind']=='drag':
   evidence=native['evidence'];require(evidence['after'][1]['count']==evidence['before'][1]['count']+(1 if expected_exit==0 else 0),'Sidebar target regression')
 require(len(coverage)==146 and wrong==30 and controls==2,'All configured datasets, levels and modes')
 for mode in ['counters','hidden']:require(sum(key[0]==mode for key in coverage)==73,'Full available mode')
 for red,green in index['pairs']:require((base/red/'case.qml').read_bytes()==(base/green/'case.qml').read_bytes(),'Identical red/green native case')
 return {'passed':True,'questions':146,'levels':30,'datasets':6,'wrong_repaired':wrong,'remainder_puzzles':remainders,'candy_transfers':transfers,'controls':controls,'native_receipts':len(index['cases']),'scope':'Linux offline software; random templates sampled once per mode, not all random draws; Windows/devices/audio/teacher review pending'}
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--evidence',type=Path,default=ROOT/PREFIX);p.add_argument('--repository',type=Path,default=ROOT);a=p.parse_args()
 try:print(json.dumps(audit(a.evidence,a.repository),indent=2))
 except (OSError,ValueError,KeyError,TypeError,subprocess.CalledProcessError) as error:print('Sharing proof rejected: '+str(error),file=sys.stderr);return 1
 return 0
if __name__=='__main__':raise SystemExit(main())
