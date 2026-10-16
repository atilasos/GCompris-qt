#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Audit complete Gnumch receipts using displayed arithmetic and archived inputs."""
import argparse
import hashlib
import json
from pathlib import Path
from oracle import answer

def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def receipt(base,relative):
 folder=base/relative
 d=json.loads((folder/'result.json').read_text())
 assert d['passed'] and d['exit_code']==0 and not d['timeout'] and not d['qml_errors'],folder
 assert d['locale']=='pt_PT' and d['network']=='docker-none'
 assert d['private_file_ownership_verified'] and not d['deployment_retained']
 assert sha(folder/'case.qml')==d['case_sha256']
 assert d['case_result']['failures']==0
 assert sha(base/'native-launcher.py')==d['runner_sha256']
 for image in d['screenshots']:assert sha(folder/image['file'])==image['sha256']
 return d

def audit(base):
 data=json.loads((base/'inventory.json').read_text());summary=json.loads((base/'final/summary.json').read_text())
 assert len(summary)==11 and all(row['exit_code']==0 for row in summary)
 covered={activity:[] for activity in data['activities']};counts={activity:0 for activity in covered};warnings=losses=0;records=[]
 for row in summary:
  folder=base/'final'/row['output'];d=receipt(base,Path('final')/row['output']);r=d['case_result'];activity=row['activity'];kind=activity.removeprefix('gnumch-')
  status=json.loads((folder/'launcher-status.json').read_text());assert status['passed'] and status['exit_code']==0
  expected=list(range(row['start'],row['start']+row['levels']))
  assert [level['level'] for level in r['completed']]==expected and r['wins']==len(expected)
  planned=data['activities'][activity]['levels']
  for level in r['completed']:
   if planned:
    goal=planned[level['level']-1]['goal']
   else:
    goals={'factors':[4,6,8,10,12,15,18,20], 'multiples':list(range(2,10)), 'primes':[4,6,8,12,14,18,20,24]}
    goal=goals[kind][level['level']-1]
   assert level['prompt'].endswith(' '+str(goal))
  for capture in r['captures']:
   if planned:assert planned[capture['level']-1]['operator'] in capture['text']
   assert capture['level'] in expected
   assert answer(kind,capture['text'],capture['prompt'])==capture['correct'],capture
   assert capture['route'] in ('click','keyboard')
  for level in expected:assert any(c['level']==level and c['correct'] for c in r['captures'])
  covered[activity].extend(expected);counts[activity]+=sum(c['correct'] for c in r['captures'])
  warnings+=len(r['warnings']);losses+=r['losses'];records.append({'folder':str(folder.relative_to(base)),'result_sha256':sha(folder/'result.json')})
 for activity,levels in covered.items():assert sorted(levels)==list(range(1,data['activities'][activity]['level_count']+1))
 for activity in covered:
  d=receipt(base,Path('controls')/activity);controls=d['case_result']['evidence']
  assert all(controls[key] for key in ('help','keyboardAfterHelp','navigation','restart'))
  assert controls['datasetChoices']==(4 if activity in ('gnumch-equality','gnumch-inequality') else 0)
  d=receipt(base,Path('monsters')/activity);r=d['case_result']
  assert r['recovered'] and len(r['encounters'])==2 and r['sightings'] and r['recoveryCaptures']
  assert [c['lifeBefore'] for c in r['encounters']]==[True,False]
  assert all('Foste comido' in c['text'] and '"Enter"' in c['text'] for c in r['encounters'])
  assert all(answer(activity.removeprefix('gnumch-'),c['text'],c['prompt']) for c in r['recoveryCaptures'])
 for red,green in [('title-red','title-green'),('return-red','return-green'),('monster-red','monster-green'),('no-monsters-red','no-monsters-green')]:
  a=json.loads((base/red/'result.json').read_text());b=receipt(base,green)
  assert not a['passed'] and a['case_sha256']==b['case_sha256']==sha(base/red/'case.qml')
 assert receipt(base,'no-monsters-green')['case_result']['evidence']['visibleMonsterSamples']==0
 assert receipt(base,'no-monsters-inequality-green')['case_result']['evidence']['visibleMonsterSamples']==0
 identity=json.loads((base/'source-identity.json').read_text());source=base/'frozen-source'
 for value in identity.values():
  for row in value['files']:assert sha(source/row['path'].removeprefix(':/gcompris/'))==row['sha256']
 assert sum(len(value['files']) for value in identity.values())==50
 manifest=json.loads((source/'manifest.json').read_text())
 assert all(sha(source/path)==value for path,value in manifest.items())
 return {'passed':True,'levels':{a:len(v) for a,v in covered.items()},'total_levels':sum(map(len,covered.values())),
  'correct_player_captures':counts,'warnings':warnings,'natural_or_error_losses_during_gameplay':losses,
  'controlled_monster_losses':5,'qt_source_files':50,'gameplay_cases':records,
  'scope':'Linux offline only; random boards/enemies observed, not all arrangements or trajectories; Windows/audio/device/teacher approval pending.'}

if __name__=='__main__':
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('evidence',type=Path);a=p.parse_args();print(json.dumps(audit(a.evidence),ensure_ascii=False,indent=2))
