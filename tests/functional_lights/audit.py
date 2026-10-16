#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Audit preserved light-board observations without Qt, Git or old runtimes."""
import argparse,hashlib,io,json,re,zipfile
from pathlib import Path
from oracle import press,solve
from inventory import data
if not __debug__:raise RuntimeError('Light audit requires assertions; Python -O is rejected')
ROOT=Path(__file__).resolve().parents[2]
HERE=ROOT/'.scratch/pt-pt/functional-lights'
CAPTURE_SHA='e3a04bc985aff6081294e599fa6d0ce5486f110dd549d55fcfb656713552a5d6'
SOURCE_SHA='a75c804c57daf56a87d991d995d27e537f37651cab2c76ef2fc32753dadea820'
QML='src/activities/lightsoff/Lightsoff.qml'
JS='src/activities/lightsoff/lightsoff.js'
CASES={'dynamic-red':('dynamic-start.qml','baseline',False),'dynamic-green':('dynamic-start.qml','final',True),'restarts-red':('restarts.qml','baseline',False),'restarts-green':('restarts.qml','final',True),'complete':('complete.qml','final',True),'controls':('controls.qml','final',True),'resources':('resources.qml','final',True),'selected-grids':('selected-grids.qml','final',True),'effective-final':('resources.qml','final',True)}
EXTRA={'source-tree.zip','source-manifest.json','resource-snapshot.json','data.json','wav-software-decode.json','qt-rcc-inventory.cpp','qt-effective-inspection.json','execution-notes.json'}|{value[0] for value in CASES.values()}
def sha(value):return hashlib.sha256(value).hexdigest()
def read(path):return json.loads(path.read_text())
def selected_paths(base):
 return {str(p.relative_to(base)) for name in [*CASES,'effective'] for p in (base/name).rglob('*') if p.is_file()}|EXTRA
def board(value,size):assert len(value)==size*size and all(type(cell) is int and cell in [0,1] for cell in value)
def audit(base=HERE):
 base=Path(base);capture_bytes=(base/'capture.json').read_bytes();assert sha(capture_bytes)==CAPTURE_SHA,'Immutable capture root';capture=json.loads(capture_bytes);assert capture['format']==1 and set(capture['files'])==selected_paths(base)
 for name,digest in capture['files'].items():assert sha((base/name).read_bytes())==digest,'Frozen artifact '+name
 source_bytes=(base/'source-tree.zip').read_bytes();assert sha(source_bytes)==SOURCE_SHA
 manifest=read(base/'source-manifest.json');assert manifest['phases']=={'baseline':'d83e5ab7e','final':'4e2f434cf'} and manifest['zip_sha256']==SOURCE_SHA and len(manifest['files'])==232
 with zipfile.ZipFile(io.BytesIO(source_bytes)) as archive:
  assert len(archive.namelist())==len(set(archive.namelist())) and set(archive.namelist())==set(manifest['files']);sources={name:archive.read(name) for name in archive.namelist()}
 assert all(sha(raw)==manifest['files'][name] for name,raw in sources.items())
 def original(name,phase='final'):return sources[(phase if name==JS else 'final')+'/'+name]
 authored=[{'dataset':str(index),'boards':data(original(f'src/activities/lightsoff/resource/{index}/Data.qml').decode())} for index in range(1,10)]
 assert read(base/'data.json')==authored and [len(row['boards']) for row in authored]==[6,6,12,18,17,10,10,10,10]
 plan=[row for dataset in authored for row in dataset['boards']];assert len(plan)==99 and sum(bool(row.get('dynamic')) for row in plan)==42
 snapshot_bytes=(base/'resource-snapshot.json').read_bytes();snapshot=json.loads(snapshot_bytes);assert len(snapshot['files'])==269
 records={};receipts={}
 for name,(case,phase,positive) in CASES.items():
  folder=base/name;raw=(folder/'result.json').read_bytes();result=json.loads(raw);status=read(folder/'launcher-status.json');tool=read(folder/'tool-status.json');outer=0 if positive else 1
  assert status['format']==1 and status['kind']=='observed-subprocess-exit' and status['exit_code']==outer and status['native_receipt_sha256']==sha(raw)
  assert status['case_sha256']==result['case_sha256']==sha((base/case).read_bytes())==sha((folder/'case.qml').read_bytes()) and status['launcher_sha256']==sha(original('tools/run-native-qml-case.py'))
  assert tool['format']==1 and tool['kind']=='observed-exec-tool-return' and tool['exit_code']==outer and tool['native_receipt_sha256']==sha(raw) and tool['launcher_status_sha256']==sha((folder/'launcher-status.json').read_bytes()) and type(tool['session_id']) is int and tool['chunk_id']!='NEEDS_ACTUAL'
  assert result['passed'] is positive and result['exit_code']==0 and result['timeout'] is False and not result['qml_errors']
  assert result['activity']=='lightsoff' and result['qml_file']=='lightsoff/Lightsoff.qml' and result['locale']=='pt_PT' and result['network']=='docker-none' and result['runtime_uid']==result['runtime_gid']==1000 and result['private_file_ownership_verified']
  assert result['source_sha256']==sha(original(QML)) and result['portuguese_catalogue_sha256']==sha(original('poqm/pt/gcompris_qt.po')) and result['runner_sha256']==sha(original('tools/run-native-qml-case.py')) and result['resource_manifest_sha256']==sha(snapshot_bytes) and result['binary_sha256']==snapshot['files']['bin/gcompris-qt']
  effective=dict(snapshot['files']);effective['share/gcompris-qt/rcc/lightsoff.rcc']=result['private_rcc_sha256'];effective['share/gcompris-qt/translations/gcompris_qt_pt.qm']=result['private_qm_sha256'];assert result['resource_files_sha256']==effective
  record=result['case_result'];assert record['failures']==(0 if positive else 1) and record['passes']==(2 if positive else 1);records[name]=record;receipts[name]=result
 for prefix in ['dynamic','restarts']:assert receipts[prefix+'-red']['case_sha256']==receipts[prefix+'-green']['case_sha256']
 puzzles=records['complete']['boards'];assert len(puzzles)==99 and [row['level'] for row in puzzles]==list(range(1,100));clicks=0
 for observed,wanted in zip(puzzles,plan):
  size=observed['size'];assert size==wanted['size'];initial=observed['before'];board(initial,size);assert any(initial)
  if not wanted.get('dynamic'):assert initial==wanted['level']
  probe=observed['probe'];assert 0<=probe['cell']<len(initial);assert probe['changed']==press(initial,size,probe['cell']) and any(probe['changed']) and probe['restored']==press(probe['changed'],size,probe['cell'])==initial
  moves=observed['moves'];assert moves;current=initial
  for step in moves:
   assert type(step['cell']) is int and 0<=step['cell']<len(current);current=press(current,size,step['cell']);assert step['after']==current;clicks+=1
  assert not any(current) and 'good' in observed['bonus']
  independent=initial
  for cell in solve(initial,size):independent=press(independent,size,cell)
  assert not any(independent)
 assert clicks==1736
 for name in ['dynamic-red','dynamic-green']:
  e=records[name]['evidence'];board(e['before'],9);assert e['size']==9 and len(e['selectedLabels'])==9 and e['selected']==e['selectedLabels'][8] and '9×9' in e['selected']
  assert bool(any(e['before'])) is (name=='dynamic-green') and e['bonusAtStart'] is (name=='dynamic-red')
 red=records['restarts-red']['evidence']['samples'];green=records['restarts-green']['evidence']['samples'];assert len(red)==88 and len(green)==150
 for sample in red+green:board(sample,6)
 assert all(any(sample) for sample in red[:-1]) and not any(red[-1]) and all(any(sample) for sample in green)
 assert records['controls']['evidence']==dict.fromkeys(['keyboard','hint','restart','navigation','configurationSameProcess','helpAndFocus','menu'],True)
 grids=records['selected-grids']['evidence']['grids'];assert [row['dataset'] for row in grids]==[6,7,8]
 for row in grids:board(row['before'],row['size']);assert row['size']==row['dataset'] and any(row['before']) and str(row['size'])+'×'+str(row['size']) in row['label']
 expected={name.removeprefix('final/') for name in sources if name.startswith('final/src/activities/lightsoff/') and name.endswith(('.qml','.js','.svg')) and not name.endswith('/Lightsoff.qml')}|{'src/activities/family/resource/background.svg','src/activities/menu/resource/all.svg','src/activities/ballcatch/resource/tux.svg'}|{f'src/core/resource/sounds/{name}.wav' for name in ['completetask','crash','scroll']}
 assert len(expected)==22
 for name in ['resources','effective-final']:
  assert set(records[name]['resources'])==expected and len(records[name]['resources'])==22
  for path in expected:assert (base/name/'resources'/path).read_bytes()==original(path)
 inspections=read(base/'qt-effective-inspection.json');assert set(inspections)=={'dynamic-red','restarts-red','effective-final'}
 for name,entry in inspections.items():
  phase=CASES[name][1];folder=base/'effective'/name;assert entry['phase']==phase and entry['exit_code']==0 and not entry['stderr'] and entry['rcc_sha256']==receipts[name]['private_rcc_sha256']==sha((folder/'lightsoff.rcc').read_bytes()) and entry['extractor_source_sha256']==sha((base/'qt-rcc-inventory.cpp').read_bytes())
  entries=read(folder/'qt-files.json');assert len(entries)==entry['files']==18
  names={row['path'].removeprefix(':/gcompris/') for row in entries};assert names=={path.removeprefix('final/') for path in sources if path.startswith('final/src/activities/lightsoff/')}
  for row in entries:
   path=row['path'].removeprefix(':/gcompris/');raw=(folder/'resources/gcompris'/path).read_bytes();assert sha(raw)==row['sha256'] and len(raw)==row['bytes'];wanted=original(path,phase)
   if path==QML:
    text=wanted.decode();closing=re.search(r'\n    }\s*\n}\s*$',text);output=Path(receipts[name]['deployment']).parent/name;fragment=(base/CASES[name][0]).read_text().replace('__QA_OUTPUT__',str(output));wanted=('import QtTest\n'+text[:closing.start()]+'\n'+fragment+text[closing.start():]).encode()
   assert raw==wanted,'Effective Qt resource '+name+'/'+path
 decoded=read(base/'wav-software-decode.json')['results'];assert len(decoded)==3
 for row in decoded:assert row['exit_code']==0 and not row['stderr'] and row['sha256']==sha(original(row['resource']))
 return {'levels':99,'datasets':9,'fixed':57,'random':42,'solver_clicks':1736,'nonwinning_and_repair_clicks':198,'restart_samples':150,'cases':9,'positive':7,'expected_red':2,'source_files':232,'runtime_files':269,'qrc_files':22,'scope':'Linux software verification only; Windows, physical audio and teacher acceptance pending.'}
if __name__=='__main__':
 parser=argparse.ArgumentParser();parser.add_argument('--evidence',type=Path,default=HERE);args=parser.parse_args();print(json.dumps(audit(args.evidence),indent=2))
