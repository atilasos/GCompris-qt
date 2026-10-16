#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Verify follow-up observations and their immutable principal provenance."""
import argparse,json,re
from pathlib import Path
from audit import audit,digest,require,data,unpack,HISTORICAL_INDEX_SHA256
SUPPLEMENT_INDEX_SHA256='765b2a4250614ed298ef58bb2a147df108febf39a950703200a4a1b0a1a7ed5c'
def verify(base,principal,*,anchor=SUPPLEMENT_INDEX_SHA256,before='reviewed',after='supplement',count=6,run_prefix='supplement',previous=None):
 require(digest((base/'sealed.json').read_bytes())==anchor,'Supplement index differs from external anchor')
 seal=data(base/'sealed.json');require(seal and all(not (base/p).is_symlink() and (base/p).is_file() and digest((base/p).read_bytes())==h for p,h in seal.items()),'Supplement physical bytes')
 evidence=data(base/'evidence.json');require(evidence['principal_index_sha256']==digest((principal/'sealed.json').read_bytes())==HISTORICAL_INDEX_SHA256,'Principal provenance')
 sources={phase:unpack(base/'sources'/(phase+'.tar.xz')) for phase in evidence['sources']};require(set(sources)=={before,after},'Both supplemental phases')
 for phase,source in sources.items():require({p:digest(b) for p,b in source.items()}==evidence['sources'][phase],'Frozen supplemental source bytes')
 require(sources[before]==unpack((previous or principal)/'sources'/(before+'.tar.xz')),'Exact historical starting source')
 require(set(sources[after])==set(sources[before]) and all(b==sources[before][p] for p,b in sources[after].items() if p!='poqm/pt/gcompris_qt.po'),'Only Portuguese catalogue changes')
 reviews=data(base/'review.json');require(len(reviews)==count and len({r['image'] for r in reviews})==count,'Six distinct reviewed pages')
 require(set(evidence['runs'])=={run_prefix+'-red',run_prefix+'-green'},'Both supplemental native runs');cases=[]
 snapshot=data(principal/'snapshot-manifest.json')
 for name,record in evidence['runs'].items():
  folder=base/'runs'/name;n=data(folder/'result.json');case=(folder/'case.qml').read_bytes();cases.append(case);source=sources[record['phase']];code=record['expected_exit'];require(code==int(name.endswith('red')),'Expected phase outcome')
  require(n['exit_code']==0 and not n['timeout'] and not n['qml_errors'] and n['network']=='docker-none' and n['private_file_ownership_verified'],'Clean offline native supplement')
  require(n['activity']=='explore_monuments' and n['case_sha256']==digest(case) and n['source_sha256']==digest(source['src/activities/explore_farm_animals/ExploreLevels.qml']) and n['portuguese_catalogue_sha256']==digest(source['poqm/pt/gcompris_qt.po']),'Executed frozen source identity')
  launcher=data(folder/'launcher-status.json');supervisor=data(folder/'supervisor-status.json');tool=data(folder/'tool-status.json')
  for status in [launcher,supervisor,tool]:require(status['exit_code']==code and status['native_receipt_sha256']==digest((folder/'result.json').read_bytes()),'Separate observed returns linked to receipt')
  require(tool['kind']=='observed-runner-exit-after-wait' and launcher['kind']==supervisor['kind']=='observed-subprocess-exit','Observed return provenance')
  require(tool['case_sha256']==launcher['case_sha256']==digest(case) and launcher['launcher_sha256']==n['runner_sha256']==digest(source['tools/run-native-qml-case.py']),'Actual launcher and case')
  require(supervisor['supervisor_sha256']==digest(source['tools/run-native-qml-supervised.py']) and tool['runner_sha256']==supervisor['runner_sha256']==digest((folder/'execution-run.py').read_bytes()) and tool['capture_sha256']==digest((folder/'execution-capture.py').read_bytes()),'Physical supplemental instruments')
  require(n['resource_manifest_sha256']==digest((principal/'snapshot-manifest.json').read_bytes()) and n['binary_sha256']==snapshot['files']['bin/gcompris-qt'],'Independent snapshot identity')
  runtime=dict(snapshot['files']);runtime['share/gcompris-qt/rcc/explore_farm_animals.rcc']=record['rcc'];runtime['share/gcompris-qt/translations/gcompris_qt_pt.qm']=record['qm'];require(n['resource_files_sha256']==runtime,'All269 effective resource hashes')
  for key,nkey in [('rcc','private_rcc_sha256'),('qm','private_qm_sha256')]:require(record[key]==n[nkey]==digest((base/'blobs'/record[key]).read_bytes()),'Physical supplemental '+key)
  extracted=unpack(base/'effective'/(name+'.tar.xz'));require(record['export_exit']==0 and set(extracted)=={r['path'][2:] for r in record['resources']},'Actual complete RCC extraction')
  require({p.removeprefix('gcompris/') for p in extracted}=={p for p in source if p.startswith('src/activities/explore_farm_animals/')},'Complete shared activity resources')
  for row in record['resources']:
   path=row['path'][2:];raw=extracted[path];wanted=source[path.removeprefix('gcompris/')]
   if path.endswith('/ExploreLevels.qml'):
    text=wanted.decode();closing=re.search(r'\n    }\s*\n}\s*$',text);fragment=case.decode().replace('__QA_OUTPUT__',record['runtime_output']).replace('__QA_SOURCE__',record['runtime_source']);wanted=('import QtTest\n'+text[:closing.start()]+'\n'+fragment+text[closing.start():]).encode()
   require(raw==wanted and digest(raw)==row['sha256'] and len(raw)==row['bytes'],'Exact source and injected case bytes')
  for image in n['screenshots']:
   raw=(folder/image['file']).read_bytes();require(digest(raw)==image['sha256'] and len(raw)==image['bytes'] and raw.startswith(b'\x89PNG\r\n\x1a\n'),'Physical supplemental screenshot')
  markers=re.findall(r'^qml: NATIVE_RESULT (\{.*\})$',(folder/'native.log').read_text(),re.M);require(len(markers)==1 and json.loads(markers[0])==n['case_result'],'Raw Qt result')
  result=n['case_result'];require(result['failures']==code and result['passes']>0 and n['passed']==(code==0),'Real supplemental assertion outcome')
  pages=result['pages'];require(len(pages)==count and {p['image'] for p in pages}=={r['image'] for r in reviews},'Six actual distinct presentations')
  for page in pages:
   row=next(r for r in reviews if r['image']==page['image']);require(page['map']==row['map'] and page['title']==row['title'] and page['description']==row['old' if code else 'new'],'Exact visible supplemental meaning')
 require(cases[0]==cases[1],'Identical supplemental red/green case')
 return {'supplemental_presentations':count,'supplemental_red_green_pairs':1}
def combined(base):
 result=audit(base/'archive');result.update(verify(base/'supplement-archive',base/'archive'));return result
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--evidence',type=Path,default=Path(__file__).resolve().parents[2]/'.scratch/pt-pt/functional-exploration');args=p.parse_args();print(json.dumps(combined(args.evidence)))
