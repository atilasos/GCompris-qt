#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Audit the physical visual-puzzle capsule without Qt/Git/original paths."""
import argparse,json,re
from pathlib import Path
from anchor import CAPTURE_SHA256,ARCHIVE_SHA256
from store import Reader,require,sha,safe
CANONICAL={'core','babymatch','details','paintings','photo_hunter','guesscount','tic_tac_toe'}
OVERRIDES={'details':'babymatch','paintings':'babymatch','photo_hunter':'photo_hunter'}
QM_MAGIC=bytes.fromhex('3cb86418caef9c95cd211cbf60a1bddd')

def verify_physical(reader):
 c=reader.capture;require(set(c['canonical'])==CANONICAL,'Seven canonical imports required');sources=c['sources'];require(sources,'Frozen sources required')
 snapshot=json.loads(reader.blob(c['snapshot']));require(len(snapshot['files'])==269 and c['binary']==snapshot['files']['bin/gcompris-qt'] and sha(reader.blob(c['binary']))==c['binary'],'Physical snapshot executable and269manifest')
 external={}
 for logical in c['files']:
  if logical.startswith('observations/external/'):
   observed=reader.json(logical);require(observed['kind']=='root-recorded-tools-exec-or-write-stdin-completion','External observation provenance')
   for name,row in observed['runs'].items():require(name not in external or external[name]==row,'Conflicting root external observations');external[name]=row
 for revision,entry in sources.items():
  require(revision==entry['manifest']['revision'] and entry['files']==entry['manifest']['files'],'Frozen revision identity')
  for path,digest in entry['files'].items():safe(path);require(reader.capture['files']['sources/'+revision+'/'+path]==digest and sha(reader.blob(digest))==digest,'Every frozen source byte')
 canonical_files={}
 for name,record in c['canonical'].items():
  require(record['exit_code']==0 and record['sha256']==snapshot['files']['share/gcompris-qt/rcc/'+name+'.rcc'],'Canonical runtime identity')
  require(sha(reader.artifact('canonical/'+name+'/resource.rcc'))==record['sha256'] and reader.artifact('canonical/'+name+'/resource.rcc').startswith(b'qres'),'Physical canonical RCC')
  rows=record['files'];expected={row['path'] for row in rows};require(len(expected)==len(rows) and rows,'Nonempty unique canonical extraction')
  actual={':/'+path.split('/files/',1)[1] for path in c['files'] if path.startswith('canonical/'+name+'/files/')};require(actual==expected,'Complete canonical extraction')
  for row in rows:
   relative=row['path'][2:];raw=reader.artifact('canonical/'+name+'/files/'+relative);require(sha(raw)==row['sha256'] and len(raw)==row['bytes'],'Canonical extracted bytes');canonical_files[(name,row['path'])]=raw
 receipts={}
 for name,contract in c['runs'].items():
  prefix='runs/'+name+'/';r=reader.json(prefix+'result.json');launcher=reader.json(prefix+'launcher-status.json');outer=reader.json(prefix+'tool-status.json');case=reader.artifact(prefix+'case.qml');source=sources[contract['source']];files=source['files'];expected=contract['expected_exit'];activity=contract['activity'];override=OVERRIDES[activity]
  require(r['activity']==activity and r['qml_file']==override+'/'+('PhotoHunter.qml' if override=='photo_hunter' else 'Babymatch.qml'),'Activity/shared override identity')
  require(r['exit_code']==0 and not r['timeout'] and not r['qml_errors'] and r['passed']==(expected==0) and r['private_file_ownership_verified'] and r['deployment_retained'],'Finished clean Qt process with honest assertion outcome')
  require(r['runtime_uid']==r['runtime_gid']==1000 and r['network']=='docker-none' and r['locale']=='pt_PT','Offline Portuguese native runtime')
  require(r['source_sha256']==files['src/activities/'+r['qml_file']] and r['portuguese_catalogue_sha256']==files['poqm/pt/gcompris_qt.po'],'Frozen QML/PO identities')
  receipt_hash=sha(reader.artifact(prefix+'result.json'));case_hash=sha(case)
  require(launcher['kind']=='observed-subprocess-exit' and outer['kind']=='observed-supervisor-return-after-wait','Separate launcher/supervisor provenance')
  require(launcher['exit_code']==outer['exit_code']==expected and launcher['native_receipt_sha256']==outer['native_receipt_sha256']==receipt_hash,'Observed inner returns linked to raw receipt')
  require(r['case_sha256']==launcher['case_sha256']==outer['case_sha256']==case_hash and launcher['launcher_sha256']==r['runner_sha256']==files['tools/run-native-qml-case.py'],'Executed exact case and frozen launcher')
  require(outer['launcher_status_sha256']==sha(reader.artifact(prefix+'launcher-status.json')) and outer['capture_sha256']==files['tests/functional_visual_puzzles/capture.py'],'Physical capture tool and launcher observation')
  require(name in external and external[name]['exit_code']==expected and isinstance(external[name]['session_id'],int) and external[name]['session_id']>0 and re.fullmatch('[0-9a-f]{5,}',external[name]['output_chunk']),'Distinct root-recorded external return; no inferred platform signature')
  require(r['resource_manifest_sha256']==c['snapshot'] and r['binary_sha256']==c['binary'],'Independent snapshot reference')
  effective=dict(snapshot['files']);effective['share/gcompris-qt/rcc/'+override+'.rcc']=r['private_rcc_sha256'];effective['share/gcompris-qt/translations/gcompris_qt_pt.qm']=r['private_qm_sha256'];require(effective==r['resource_files_sha256'],'Complete269effective resource set')
  exp=contract['effective'];require(exp['source_root']==source['historical_root'] and exp['exit_code']==0,'Historical extraction/source provenance')
  require(sha(reader.artifact('effective/'+name+'/resource.rcc'))==exp['rcc_sha256']==r['private_rcc_sha256'] and reader.artifact('effective/'+name+'/resource.rcc').startswith(b'qres'),'Actually loaded private RCC bytes')
  qm=reader.artifact('effective/'+name+'/gcompris_qt_pt.qm');require(sha(qm)==exp['qm_sha256']==r['private_qm_sha256'] and qm.startswith(QM_MAGIC),'Actually loaded QM bytes')
  require(sha(reader.artifact('effective/'+name+'/inspector'))==exp['inspector_sha256'],'Physical QtCore resource inspector preserved')
  rows=exp['files'];paths={row['path'] for row in rows};wanted={':/gcompris/'+p for p in files if p.startswith('src/activities/'+override+'/')};require(len(paths)==len(rows) and paths==wanted,'Complete private RCC extraction against frozen source')
  text=reader.blob(files['src/activities/'+r['qml_file']]).decode();closing=re.search(r'\n    }\s*\n}\s*$',text);require(closing is not None,'Known native instrumentation seam');fragment=case.decode().replace('__QA_OUTPUT__',contract['historical_output']).replace('__QA_SOURCE__',source['historical_root']);patched=('import QtTest\n'+text[:closing.start()]+'\n'+fragment+text[closing.start():]).encode()
  for row in rows:
   path=row['path'][len(':/gcompris/'):];raw=reader.artifact('effective/'+name+'/files/gcompris/'+path);require(sha(raw)==row['sha256'] and len(raw)==row['bytes'],'Physical private extraction');require(raw==(patched if path=='src/activities/'+r['qml_file'] else reader.blob(files[path])),'Exact frozen source/instrumentation in actual RCC')
  for screen in r['screenshots']:
   raw=reader.artifact(prefix+screen['file']);require(sha(raw)==screen['sha256'] and len(raw)==screen['bytes'] and raw.startswith(b'\x89PNG\r\n\x1a\n'),'Physical native screenshots')
  log=reader.artifact(prefix+'native.log').decode();markers=re.findall(r'^qml: NATIVE_RESULT (\{.*\})$',log,re.M);require(len(markers)==1 and json.loads(markers[0])==r['case_result'],'Raw observed Qt output matches receipt');require(r['case_result']['failures']==expected and r['case_result']['passes']>0,'Real QtTest assertion counts');receipts[name]=r
 return receipts

def audit(base):
 reader=Reader(base,CAPTURE_SHA256,ARCHIVE_SHA256)
 from semantics import validate
 return validate(reader,verify_physical(reader))
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--evidence',type=Path,required=True);args=p.parse_args();print(json.dumps(audit(args.evidence)))
