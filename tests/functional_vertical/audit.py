#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Audit archived vertical operations with independent integer arithmetic."""
import argparse,hashlib,json,re
from pathlib import Path
from oracle import columns
ACTIVITIES=('vertical_addition','vertical_subtraction','vertical_subtraction_compensation')
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def read(path):return json.loads(path.read_text())
def validate_receipts(base):
 bindings=read(base/'receipt-inputs.json')
 actual={p.parent.relative_to(base).as_posix() for p in base.rglob('result.json') if not any(x.startswith('.native-qml-') for x in p.parts)}
 assert set(bindings)==actual,'Every receipt needs its own historical input binding'
 for relative,binding in bindings.items():
  folder=base/relative;d=read(folder/'result.json');source=base/binding['source'];manifest=read(source/'manifest.json')
  assert sha(source/'manifest.json')==binding['source_manifest_sha256']
  assert all(sha(source/p)==value for p,value in manifest.items())
  assert d['source_sha256']==manifest['src/activities/'+d['qml_file']]
  assert d['portuguese_catalogue_sha256']==manifest['poqm/pt/gcompris_qt.po']
  assert sha(base/'native-launcher.py')==d['runner_sha256']
  assert sha(folder/'case.qml')==d['case_sha256']
  snapshot=base/binding['snapshot'];assert sha(snapshot)==d['resource_manifest_sha256']
  expected=read(snapshot)['files'].copy()
  expected['share/gcompris-qt/rcc/vertical_subtraction.rcc']=d['private_rcc_sha256']
  expected['share/gcompris-qt/translations/gcompris_qt_pt.qm']=d['private_qm_sha256']
  assert expected==d['resource_files_sha256'],relative
  assert d['binary_sha256']==expected['bin/gcompris-qt']
  assert d['locale']=='pt_PT' and d['network']=='docker-none' and not d['timeout'] and not d['qml_errors']
  assert d['private_file_ownership_verified']
  for image in d['screenshots']:assert sha(folder/image['file'])==image['sha256']
 return bindings

def positive(base,relative):
 folder=base/relative;d=read(folder/'result.json')
 assert d['passed'] and d['exit_code']==0 and not d['deployment_retained']
 assert d['case_result']['failures']==0
 if (folder/'launcher-status.json').exists():assert read(folder/'launcher-status.json')=={'exit_code':0,'passed':True}
 return d['case_result']

def audit(base):
 bindings=validate_receipts(base)
 inventory=read(base/'inventory.json');summary=read(base/'final/summary.json')
 assert len(summary)==12 and all(r['exit_code']==0 for r in summary)
 for activity,levels in inventory.items():
  assert activity in ACTIVITIES and len(levels)==12
  for i,row in enumerate(levels,1):
   assert row['dataset']==i and row['source']==f'src/activities/{activity}/resource/{i}/Data.qml'
   text=(base/'frozen-source/complete'/row['source']).read_text()
   assert row['data']==json.loads(re.search(r'data:\s*\[\s*(\{.*?\})\s*\]',text,re.S).group(1))
   assert row['objective']==re.search(r'objective: qsTr\("(.*?)"\)',text).group(1)
 for phase,name,count in [('baseline','qt-resource-identity.json',48),('green','green-qt-resource-identity.json',49),('complete','complete-qt-resource-identity.json',48)]:
  files=read(base/name);manifest=read(base/'frozen-source'/phase/'manifest.json')
  assert sum(map(len,files.values()))==count
  expected={p for p in manifest if p.startswith('src/activities/') and not p.endswith('CMakeLists.txt')}
  if phase=='green':expected.add('src/activities/vertical_subtraction/CMakeLists.txt')
  actual={row['path'].removeprefix(':/gcompris/') for rows in files.values() for row in rows}
  assert actual==expected
  for rows in files.values():
   for row in rows:assert row['sha256']==manifest[row['path'].removeprefix(':/gcompris/')]
 coverage={a:[] for a in ACTIVITIES};wrong=0;adjustments=0
 for row in summary:
  activity=row['activity'];result=positive(base,'final/'+row['output']);assert result['wins']==3
  expected=[(level,sublevel) for level in range(row['start'],row['start']+3) for sublevel in range(1,11)]
  assert [(r['level'],r['sublevel']) for r in result['completed']]==expected
  for r in result['completed']:
   config=inventory[activity][r['level']-1]['data'];operator='+' if activity=='vertical_addition' else '-'
   method='compensation' if activity.endswith('_compensation') else 'regrouping'
   assert len(r['operands'])==config['nbLines']
   expected_plan=columns(r['operands'],operator,method)
   assert r['result']==expected_plan['result'] and r['adjustments']==expected_plan['adjustments']
   assert r['laid']==config['alreadyLaid']
   if config.get('doItYourself',False):
    assert r['prompt']==('Escreve a tua própria adição e resolve-a.' if operator=='+' else 'Escreve a tua própria subtração e resolve-a.')
   else:
    assert r['prompt'].startswith('Resolve:' if r['laid'] else 'Escreve:')
    assert list(map(int,re.findall(r'\d+',r['prompt'])))==r['operands']
    assert ' '+operator+' ' in r['prompt']
   assert r['error']==(r['sublevel']==1)
   wrong+=r['error'];adjustments+=len(r['adjustments']);coverage[activity].append((r['level'],r['sublevel']))
 for activity,rows in coverage.items():assert sorted(rows)==[(l,s) for l in range(1,13) for s in range(1,11)]
 controls=read(base/'controls/summary.json');assert len(controls)==3 and all(r['exit_code']==0 for r in controls)
 for activity in ACTIVITIES:
  r=positive(base,'controls/'+activity)['evidence'];assert r['datasetChoices']==12
  assert all(r[k] for k in ['help','focusAfterHelp','wrongAnswer','navigation','restart','persistedSelection','restoredSelection','menu'])
 for activity in ACTIVITIES:
  r=positive(base,'free-input-green-'+activity)['evidence']
  assert all(r[k] for k in ['emptyRejected','singleRejected','gapRejected','recovered'])
  if activity!='vertical_addition':assert r['negativeRejected']
  oracle=columns(r['operands'],'+' if activity=='vertical_addition' else '-', 'compensation' if activity.endswith('_compensation') else 'regrouping')
  assert r['result']==oracle['result'] and r['adjustments']==oracle['adjustments']
 for activity in ACTIVITIES[1:]:
  r=positive(base,'negative-own-green-'+activity)['evidence']
  assert r['operands']==[1,2] and r['emptyRows']==2 and r['negativeWarning'] and not r['okVisible']
 red=read(base/'negative-own-red/result.json')
 assert not red['passed']
 assert red['case_sha256']==read(base/'negative-own-green-vertical_subtraction/result.json')['case_sha256']
 for name in ['previous','copied-zero','config-progress']:
  red=read(base/(name+'-red')/'result.json');green=read(base/(name+'-complete')/'result.json')
  assert not red['passed'] and green['passed'] and red['case_sha256']==green['case_sha256']
  positive(base,name+'-complete')
 index=read(base/'index.json')
 assert index['artifact_sha256']
 assert all(sha(base/path)==value for path,value in index['artifact_sha256'].items())
 selected=index['selected_final_cases']
 expected_folders={'final/'+r['output'] for r in summary}|{'controls/'+a for a in ACTIVITIES}|{'free-input-green-'+a for a in ACTIVITIES}|{'negative-own-green-'+a for a in ACTIVITIES[1:]}|{name+'-complete' for name in ['previous','copied-zero','config-progress']}
 assert {r['folder'] for r in selected}==expected_folders and len(selected)==23
 for row in selected:
  assert bindings[row['folder']]['source']=='frozen-source/complete'
  assert sha(base/row['folder']/'result.json')==row['result_sha256']
  positive(base,row['folder'])
 return {'passed':True,'datasets':36,'puzzles':sum(map(len,coverage.values())),'per_activity':{a:len(v) for a,v in coverage.items()},'wrong_results_repaired':wrong,'carry_borrow_annotations':adjustments,'controls_cases':3,'historically_bound_receipts':len(bindings),'scope':'Linux offline; random inputs sampled, Windows/hardware/audio/teacher acceptance pending'}
if __name__=='__main__':
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('evidence',type=Path);a=p.parse_args();print(json.dumps(audit(a.evidence),indent=2))
