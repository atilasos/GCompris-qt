#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Audit visible graduated-line arithmetic and exact supervised historical inputs."""
import argparse
from functools import cache
import hashlib,json,subprocess,sys
from pathlib import Path,PurePosixPath
from fractions import Fraction
from oracle import number,at_tick,tick_for
from phase import PREFIXES
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from native_qml_supervision import verify_status
PHASES={'baseline':'052399f75a3bbdda098c0c854cc99368f3219ecf','final':'d1e639c9f44e3124f37c614a58835bb14c90cc26'}
PROOF_REVISION='081b75c0a95a8babef391e627b9911381786ae4d'
PREFIX='.scratch/pt-pt/functional-graduated/'
ACTIVITIES=('graduated_line_read','graduated_line_use')
EXTERNAL={'src/activities/chess/resource/background-wood.svg',*[f'src/core/resource/sounds/{name}.wav' for name in ['completetask','crash','audioclick','smudge']]}
def digest(raw):return hashlib.sha256(raw).hexdigest()

def audit(base,repository):
 @cache
 def blob(revision,path):return subprocess.check_output(['git','-C',str(repository),'show',revision+':'+path])
 def read(path):return json.loads((base/path).read_text())
 index=read('index.json')
 assert (base/'index.json').read_bytes()==blob(PROOF_REVISION,PREFIX+'index.json'),'Immutable proof index'
 for path,sha in index['files'].items():
  parsed=PurePosixPath(path);assert not parsed.is_absolute() and '..' not in parsed.parts
  assert digest((base/path).read_bytes())==sha,path
 manifests={}
 for phase,revision in PHASES.items():
  source=read('phases/'+phase+'/source-manifest.json');assert source['revision']==revision
  expected=set(subprocess.check_output(['git','-C',str(repository),'ls-tree','-r','--name-only',revision,'--',*PREFIXES],text=True).splitlines())
  assert set(source['files'])==expected
  for path,sha in source['files'].items():assert digest(blob(revision,path))==sha,path
  manifests[phase]=read('phases/'+phase+'/snapshot-manifest.json');assert len(manifests[phase]['files'])==269
 resources=read('qt-resources.json');assert set(resources)=={*ACTIVITIES,'core','chess'}
 for name,resource in resources.items():
  assert resource['rcc_sha256']==manifests['final']['files']['share/gcompris-qt/rcc/'+name+'.rcc']
  expected={p for p in read('phases/final/source-manifest.json')['files'] if p.startswith('src/activities/'+name+'/') and not p.endswith('CMakeLists.txt')} if name in ACTIVITIES else {p for p in EXTERNAL if p.startswith('src/core/' if name=='core' else 'src/activities/chess/')}
  assert {row['path'].removeprefix(':/gcompris/') for row in resource['files']}==expected
  for row in resource['files']:
   path=row['path'].removeprefix(':/gcompris/');raw=blob(PHASES['final'],path)
   assert row['sha256']==digest(raw) and row['bytes']==len(raw)
   assert (base/'resources'/path).read_bytes()==raw
 data=read('inventory.json')
 import re
 for activity,levels in data.items():
  expected=[]
  for dataset in range(1,11):
   text=blob(PHASES['final'],f'src/activities/{activity}/resource/{dataset}/Data.qml').decode()
   for within,rules in enumerate(re.findall(r'"rules":\s*(\{[^}]+\})',text),1):expected.append({'dataset':dataset,'within_dataset':within,'rules':json.loads(rules)})
  assert levels==expected and len(levels)==29
 coverage={a:[] for a in ACTIVITIES};seen={};wrong=0;steps=0;controls=0;tracers=0;decimals=0;fractional=0;inputs={'keyboard':0,'pointer':0}
 def visible(view):
  marks=view['marks'];assert len(marks)>2 and 0<=view['index']<len(marks)
  assert marks[0]>0 and marks[-1]<800 and all(marks[i]>marks[i-1] for i in range(1,len(marks)))
  assert all(abs((marks[i]-marks[i-1])-(marks[1]-marks[0]))<0.02 for i in range(2,len(marks)))
  assert number(view['right'])>number(view['left'])
 def sample(activity,row):
  nonlocal steps,decimals,fractional
  view=row['view'];visible(view);config=data[activity][row['level']-1]['rules'];denominator=config.get('denominator',1)
  step=(number(view['right'])-number(view['left']))/(len(view['marks'])-1)*denominator
  assert step.denominator==1 and int(step) in config['steps']
  assert number(view['left'])>=Fraction(config['range'][0],denominator) and number(view['right'])<=Fraction(config['range'][1],denominator)
  if config['fitLimits']:assert number(view['left'])==Fraction(config['range'][0],denominator) and number(view['right'])==Fraction(config['range'][1],denominator)
  seen.setdefault((activity,row['level']),set()).add(int(step));steps+=1
  if activity=='graduated_line_read':assert row['request']==row['response']==at_tick(view['left'],view['right'],len(view['marks']),view['index'])
  else:assert row['response']==tick_for(view['left'],view['right'],len(view['marks']),row['request'])
  if denominator!=1:decimals+=1
  if ',' in row['request']:fractional+=1
 for name,case in index['cases'].items():
  result=read(name+'/result.json');revision=PHASES[case['phase']];kind=case['kind'];positive=kind!='red';native=result['case_result'];activity=case['activity']
  assert result['activity']==activity and result['locale']=='pt_PT' and result['network']=='docker-none'
  assert result['exit_code']==0 and not result['timeout'] and not result['qml_errors'] and result['private_file_ownership_verified']
  assert result['passed']==positive and native['failures']==(0 if positive else 1)
  if positive:assert not result['deployment_retained']
  assert result['source_sha256']==digest(blob(revision,'src/activities/'+result['qml_file']))
  assert result['portuguese_catalogue_sha256']==digest(blob(revision,'poqm/pt/gcompris_qt.po'))
  assert result['runner_sha256']==digest(blob(revision,'tools/run-native-qml-case.py'))
  assert digest(blob(revision,'tools/run-native-qml-supervised.py'))==digest((base/'supervisor.py').read_bytes())
  assert digest(blob(revision,'tools/native_qml_supervision.py'))==digest((base/'supervision-contract.py').read_bytes())
  assert result['case_sha256']==digest((base/name/'case.qml').read_bytes())
  verify_status(base/name/'launcher-status.json',base/name/'result.json',base/name/'case.qml',0 if positive else 1)
  manifest=manifests[case['phase']];assert result['resource_manifest_sha256']==digest((base/'phases'/case['phase']/'snapshot-manifest.json').read_bytes())
  effective=manifest['files'].copy();effective['share/gcompris-qt/rcc/graduated_line_read.rcc']=result['private_rcc_sha256'];effective['share/gcompris-qt/translations/gcompris_qt_pt.qm']=result['private_qm_sha256']
  assert result['resource_files_sha256']==effective and result['binary_sha256']==effective['bin/gcompris-qt']
  for shot in result['screenshots']:assert digest((base/name/shot['file']).read_bytes())==shot['sha256']
  if kind=='campaign':
   expected=[(level,q) for level in range(case['start'],case['start']+case['levels']) for q in range(1,data[activity][level-1]['rules']['nbOfQuestions']+1)]
   assert [(r['level'],r['question']) for r in native['completed']]==expected
   assert native['wins']==case['levels'] and native['levelsCompleted']==list(range(case['start'],case['start']+case['levels']))
   for row in native['completed']:
    sample(activity,row);coverage[activity].append((row['level'],row['question']));inputs[row['input']]+=1
    assert (row['wrong'] is not None)==(row['question']==1)
    if row['wrong'] is not None:
     if activity=='graduated_line_read':assert number(row['wrong']['input'])!=number(row['request'])
     else:assert row['wrong']['index']!=row['response']
     wrong+=1
  elif kind=='step':
   evidence=native['evidence'];assert evidence['solved'] and evidence['attempts']
   row=evidence['sample'];assert row['level']==case['level'];sample(activity,row)
   assert number(evidence['attempts'][-1]['step'])==case['step']
   assert row['view']==evidence['attempts'][-1]['view'];tracers+=1
  elif kind=='controls':
   evidence=native['evidence'];assert all(evidence[k] for k in ['focusAfterHelp','partialRestart','previousAfterProgress','persistedSelection','restoredSelection','menuByCtrlW']);controls+=1
   assert 'Controlos do teclado' in evidence['help']['content']
   if activity=='graduated_line_use':assert evidence['bounds']['left']==1 and evidence['bounds']['right']==len(evidence['bounds']['view']['marks'])-2
  elif kind=='keyboard':
   evidence=native['evidence'];visible(evidence['before'])
   if activity=='graduated_line_read':assert evidence['afterText']=='5'
   else:assert abs(evidence['after']['index']-evidence['before']['index'])==1
  elif kind=='green':
   evidence=native['evidence'];assert any('0 e 20' in text for text in evidence['datasets'])
   if activity=='graduated_line_read':assert evidence['instruction']=='Encontra o número indicado.' and 'Delete: limpar a resposta' in evidence['help']
   else:assert 'Setas Esquerda e Direita: mover o cursor' in evidence['help']
 for activity,levels in data.items():
  expected=[(i,q) for i,row in enumerate(levels,1) for q in range(1,row['rules']['nbOfQuestions']+1)]
  assert sorted(coverage[activity])==expected
  for i,row in enumerate(levels,1):assert seen[(activity,i)]==set(row['rules']['steps'])
  red=read('portuguese-red-'+activity+'/result.json');green=read('portuguese-green-'+activity+'/result.json');assert red['case_sha256']==green['case_sha256']
  before=red['case_result']['evidence']
  if activity=='graduated_line_read':
   assert before['instruction']=='Descobrir a borboleta cor de ferrugem'
   assert 'Algarismos: escreve a tua resposta' in before['help'] and any('0e 20' in text for text in before['datasets'])
  else:assert 'mover a nave' in before['help']
 assert wrong==58 and controls==2 and tracers==4 and len(index['cases'])==22
 return {'passed':True,'questions':sum(map(len,coverage.values())),'levels':58,'datasets':20,'wrong_repaired':wrong,'configured_level_step_pairs':sum(map(len,seen.values())),'step_samples':tracers,'controls':controls,'decimal_level_questions':decimals,'fractional_requests':fractional,'inputs':inputs,'native_receipts':22,'scope':'Linux software only; same-process selection reopening; Windows/hardware/audio/teacher approval pending'}
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--evidence',type=Path,default=ROOT/PREFIX);p.add_argument('--repository',type=Path,default=ROOT);a=p.parse_args()
 try:print(json.dumps(audit(a.evidence,a.repository),indent=2))
 except (AssertionError,OSError,ValueError,KeyError,subprocess.CalledProcessError) as error:print('Graduated evidence rejected: '+str(error),file=sys.stderr);return 1
 return 0
if __name__=='__main__':raise SystemExit(main())
