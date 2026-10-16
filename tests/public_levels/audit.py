#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Read physical task-82 evidence using only Python, without Qt or Git."""
import argparse,hashlib,json,re,tarfile
from pathlib import Path

# External trust root for the original, already reviewed task-82 archive.
# Keep historical capsules and receipts unchanged when fixing this verifier.
HISTORICAL_INDEX_SHA256 = '39e855e2bd740c70bc6e02f3953cae9babd078ebcd5d5c417764e73353c82f5d'
def digest(data):return hashlib.sha256(data).hexdigest()
def require(ok,message):
 if not ok:raise ValueError(message)
def data(path):return json.loads(path.read_text())
def unpack(path):
 with tarfile.open(path,'r:xz') as archive:
  entries=archive.getmembers();require(all(e.isfile() and not e.name.startswith('/') and '..' not in Path(e.name).parts for e in entries),'Unsafe source archive')
  require(len({e.name for e in entries})==len(entries),'Duplicate physical entries')
  return {e.name:archive.extractfile(e).read() for e in entries}
def audit(base):
 index=base/'sealed.json'
 require(not index.is_symlink() and digest(index.read_bytes())==HISTORICAL_INDEX_SHA256,'Historical archive index differs from external anchor')
 seal=data(index)
 require(seal and all((base/p).is_file() and not (base/p).is_symlink() and digest((base/p).read_bytes())==h for p,h in seal.items()),'Physical archive seal')
 evidence=data(base/'evidence.json');snapshot=data(base/'snapshot-manifest.json');sources={phase:unpack(base/(phase+'-sources.tar.xz')) for phase in ['red','green']}
 for phase,files in sources.items():require({p:digest(raw) for p,raw in files.items()}==evidence['sources'][phase],'Physical historical source set')
 groups={}
 for name,record in evidence['runs'].items():
  phase=record['phase'];folder=base/'runs'/name;native=data(folder/'result.json');launch=data(folder/'launcher-status.json');tool=data(folder/'tool-status.json');case=(folder/'case.qml').read_bytes();source=sources[phase];qml='src/activities/'+record['qml'];expected_exit=int(phase=='red')
  require(native['exit_code']==0 and not native['timeout'] and native['network']=='docker-none' and not native['qml_errors'],'Clean offline native Qt return')
  require(launch['kind']==tool['kind']=='observed-subprocess-exit' and launch['exit_code']==tool['exit_code']==expected_exit,'Separately observed Python returns')
  require(launch['native_receipt_sha256']==tool['native_receipt_sha256']==digest((folder/'result.json').read_bytes()),'Statuses bound to actual native receipt')
  require(launch['case_sha256']==native['case_sha256']==digest(case),'Identical executed case')
  require(launch['launcher_sha256']==native['runner_sha256']==digest(source['tools/run-native-qml-case.py']),'Historical launcher')
  require(tool['supervisor_sha256']==digest(source['tools/run-native-qml-supervised.py']),'Historical supervisor')
  require(native['source_sha256']==digest(source[qml]),'Historical source identity')
  require(native['portuguese_catalogue_sha256']==digest(source['poqm/pt/gcompris_qt.po']),'Historical PT catalogue')
  require(native['binary_sha256']==snapshot['files']['bin/gcompris-qt'],'Independent runtime binary')
  require(native['resource_manifest_sha256']==digest((base/'snapshot-manifest.json').read_bytes()),'Complete baseline resource manifest')
  runtime=dict(snapshot['files']);runtime['share/gcompris-qt/rcc/'+record['qml'].split('/')[0]+'.rcc']=native['private_rcc_sha256'];runtime['share/gcompris-qt/translations/gcompris_qt_pt.qm']=native['private_qm_sha256']
  require(native['resource_files_sha256']==runtime,'Complete effective runtime set')
  for field,expected in [('rcc',native['private_rcc_sha256']),('qm',native['private_qm_sha256'])]:require(record[field]==expected==digest((base/'blobs'/record[field]).read_bytes()),'Physical effective '+field)
  require(record['export_exit']==0,'Observed Qt resource extraction')
  actual=unpack(base/'effective'/(name+'.tar.xz'));rows=record['resources'];require(set(actual)=={r['path'][2:] for r in rows},'All Qt-extracted files')
  prefix='src/activities/'+record['qml'].split('/')[0]+'/'
  require({p.removeprefix('gcompris/') for p in actual}=={p for p in source if p.startswith(prefix)},'All original activity files preserved')
  for row in rows:
   path=row['path'][2:];raw=actual[path];original=source[path.removeprefix('gcompris/')]
   require(digest(raw)==row['sha256'] and len(raw)==row['bytes'],'Extracted Qt bytes')
   if path=='gcompris/'+qml:
    text=original.decode();closing=re.search(r'\n    }\s*\n}\s*$',text)
    # Historical absolute output/source are data; no filesystem access is used.
    output=str(Path(native['deployment']).parent/name)
    source_root=str(Path(native['resource_snapshot']).parent/'sources'/phase)
    fragment=case.decode().replace('__QA_OUTPUT__',output).replace('__QA_SOURCE__',source_root)
    original=('import QtTest\n'+text[:closing.start()]+'\n'+fragment+text[closing.start():]).encode()
   require(raw==original,'Effective resource matches exact frozen source/instrumentation')
  for image in native['screenshots']:
   raw=(folder/image['file']).read_bytes();require(digest(raw)==image['sha256'] and len(raw)==image['bytes'] and raw.startswith(b'\x89PNG\r\n\x1a\n'),'Physical native screenshot')
  require({x['file'] for x in native['screenshots']}=={'initial.png','returned.png'},'Both painted navigation states')
  markers=re.findall(r'^qml: NATIVE_RESULT (\{.*\})$',(folder/'native.log').read_text(),re.M);require(len(markers)==1 and json.loads(markers[0])==native['case_result'],'Raw observed Qt marker')
  result=native['case_result'];e=result['evidence'];require(e['initial']==0 and e['barLevel']==1 and e['selector'] is True,'Real activity selector after startup')
  require(e['total']==(0 if phase=='red' else record['total']),'Public total contract red/green')
  steps=e['steps'];require(len(steps)==2 and [s['action'] for s in steps]==['next','previous'] and [s['bar'] for s in steps]==[2,1],'Real next/previous actions')
  require([s['current'] for s in steps]==([0,0] if phase=='red' and record['activity']=='polygons' else [1,0]),'Public level reflects painted navigation')
  require(all(s['total']==e['total'] for s in steps),'Stable public total while navigating')
  require(result['failures']==expected_exit and result['passes']>0 and native['passed']==(phase=='green'),'Native assertion outcome')
  group=groups.setdefault(record['activity'],{});require(phase not in group,'Duplicate activity phase');group[phase]=(case,record['total'])
 require(len(groups)==24 and all(set(g)=={'red','green'} and g['red']==g['green'] for g in groups.values()),'24 identical red/green pairs')
 for name,h in evidence['imports'].items():require(snapshot['files']['share/gcompris-qt/rcc/'+name+'.rcc']==h==digest((base/'blobs'/h).read_bytes()),'Physical imported runtime RCC')
 for name in ['checkers-no-level-green','polygons-free-settings-green']:
  folder=base/'exclusions'/name;r=data(folder/'result.json');e=r['case_result']['evidence'];require(r['passed'] and r['exit_code']==0 and not r['timeout'] and not r['qml_errors'] and r['network']=='docker-none' and e['total']==0 and e['selector'] is False,'Mode without activity levels')
  launch=data(folder/'launcher-status.json');tool=data(folder/'tool-status.json');case=(folder/'case.qml').read_bytes()
  require(launch['exit_code']==tool['exit_code']==0 and launch['native_receipt_sha256']==tool['native_receipt_sha256']==digest((folder/'result.json').read_bytes()),'Observed no-selector subprocess returns')
  require(r['case_sha256']==launch['case_sha256']==digest(case) and r['source_sha256']==digest(sources['green']['src/activities/'+r['qml_file']]),'Executed no-selector case and source')
  require(r['private_rcc_sha256']==digest((base/'blobs'/r['private_rcc_sha256']).read_bytes()) and r['private_qm_sha256']==digest((base/'blobs'/r['private_qm_sha256']).read_bytes()),'Physical no-selector effective runtime')
  markers=re.findall(r'^qml: NATIVE_RESULT (\{.*\})$',(folder/'native.log').read_text(),re.M);require(len(markers)==1 and json.loads(markers[0])==r['case_result'],'Observed no-selector Qt marker')
  for image in r['screenshots']:require(digest((folder/image['file']).read_bytes())==image['sha256'],'Physical no-selector screenshot')
 return {'activities':len(groups),'identical_red_green_pairs':24,'no_level_modes':2,'scope':'Public metadata and next/previous navigation; no game completions'}
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--evidence',type=Path,default=Path(__file__).resolve().parents[2]/'.scratch/pt-pt/public-level-contracts/archive');a=p.parse_args();print(json.dumps(audit(a.evidence)))
