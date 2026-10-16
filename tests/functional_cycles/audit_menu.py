#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Pure physical supplement: actual menu navigation after natural success."""
import argparse,json,re,tarfile
from pathlib import Path,PurePosixPath
from audit import audit as audit_primary,sha,require,check_lock,check_water,check_energy
from config import FILES
ROOT=Path(__file__).resolve().parents[2]
ANCHOR='7ce01a7f0cbafdb63647118feccf52a7e98b498dd0c3e7bc77e64dc2bc6f7e43'
CASES={'canal':'canal_lock','water':'watercycle','energy':'renewable_energy'}
def check_menu(evidence):
 menu=evidence['menuAfterSuccess'];require(menu['isMenu'] is True and menu['depth']==1 and menu['busy'] is False and menu['timestamp']>0,'Real stable post-success menu')
def audit(base,primary):
 audit_primary(primary)
 def read(path):return json.loads((base/path).read_text())
 require(sha((base/'index.json').read_bytes())==ANCHOR,'Immutable supplement index')
 index=read('index.json');require(index['cases']==CASES and index['primary_index_sha256']==sha((primary/'index.json').read_bytes()),'Exact nonempty supplement and primary binding')
 for relative,digest in index['files'].items():
  path=PurePosixPath(relative);target=base/relative;require(not path.is_absolute() and '..' not in path.parts and not target.is_symlink() and target.resolve().is_relative_to(base.resolve()),'Physical supplement path');require(sha(target.read_bytes())==digest,'Physical supplement bytes: '+relative)
 with tarfile.open(primary/'sources/water-words/source.tar.xz','r:xz') as archive:source={row.name:archive.extractfile(row).read() for row in archive.getmembers()}
 snapshot=json.loads((primary/'snapshot-manifest.json').read_text());resources=read('resources.json')
 for name,activity in CASES.items():
  native=read(name+'/result.json');status=read(name+'/launcher-status.json');tool=read(name+'/tool-status.json');case=(base/name/'case.qml').read_bytes();result=native['case_result'];effective=resources[name]
  require(native['activity']==activity and native['locale']=='pt_PT' and native['network']=='docker-none' and native['runtime_uid']==native['runtime_gid']==1000,'Real offline unprivileged activity')
  require(native['passed'] and native['exit_code']==0 and not native['timeout'] and not native['qml_errors'] and result['failures']==0 and result['passes']>0,'Native Qt and actual test succeeded')
  require(status['kind']=='observed-subprocess-exit' and tool['kind']=='observed-supervisor-return-after-wait' and status['exit_code']==tool['exit_code']==0,'Both external returns observed after wait')
  require(status['native_receipt_sha256']==tool['native_receipt_sha256']==sha((base/name/'result.json').read_bytes()) and tool['launcher_status_sha256']==sha((base/name/'launcher-status.json').read_bytes()),'Observed raw receipt and status')
  require(status['case_sha256']==tool['case_sha256']==native['case_sha256']==sha(case),'Exact executed case')
  require(tool['capture_sha256']==sha((primary/'execution-tools/capture.py').read_bytes()) and status['launcher_sha256']==native['runner_sha256']==sha(source['tools/run-native-qml-case.py']),'Physical observed execution tools')
  require(native['source_sha256']==sha(source['src/activities/'+activity+'/'+FILES[activity]]) and native['portuguese_catalogue_sha256']==sha(source['poqm/pt/gcompris_qt.po']),'Frozen final source and PO')
  require(native['private_rcc_sha256']==sha((base/'effective'/name/'activity.rcc').read_bytes()) and native['private_qm_sha256']==sha((base/'effective'/name/'catalogue.qm').read_bytes())==sha((primary/'catalogue/water-words.qm').read_bytes()),'Actual retained RCC and final QM')
  expected=dict(snapshot['files']);expected['share/gcompris-qt/rcc/'+activity+'.rcc']=native['private_rcc_sha256'];expected['share/gcompris-qt/translations/gcompris_qt_pt.qm']=native['private_qm_sha256'];require(native['resource_files_sha256']==expected and native['binary_sha256']==snapshot['files']['bin/gcompris-qt'] and native['resource_manifest_sha256']==sha((primary/'snapshot-manifest.json').read_bytes()),'Complete effective runtime')
  require({r['path'].removeprefix(':/gcompris/') for r in effective['files']}=={p for p in source if p.startswith('src/activities/'+activity+'/')},'All activity entries physically extracted')
  require(effective['extract_exit_code']==0,'Observed QtCore extraction')
  for row in effective['files']:
   path=row['path'].removeprefix(':/gcompris/');wanted=source[path];actual=(base/'effective'/name/'files'/path).read_bytes()
   if path=='src/activities/'+activity+'/'+FILES[activity]:
    text=wanted.decode();closing=re.search(r'\n    }\s*\n}\s*$',text);fragment=case.decode().replace('__QA_OUTPUT__',effective['runtime_output']).replace('__QA_SOURCE__',effective['runtime_source']);wanted=('import QtTest\n'+text[:closing.start()]+'\n'+fragment+text[closing.start():]).encode()
   require(actual==wanted and sha(actual)==row['sha256'] and len(actual)==row['bytes'],'Exact final-source instrumentation and extracted resource')
  markers=re.findall(r'^qml: NATIVE_RESULT (\{.*\})$',(base/name/'native.log').read_text(),re.M);require(len(markers)==1 and json.loads(markers[0])==result,'Actual native log result')
  for screenshot in native['screenshots']:require(sha((base/name/screenshot['file']).read_bytes())==screenshot['sha256'],'Physical screenshot')
  require(any(r['file']=='menu-after-success.png' for r in native['screenshots']),'Actual menu image captured')
  {'canal':check_lock,'water':check_water,'energy':check_energy}[name](result);check_menu(result['evidence'])
  if name=='water':require(result['evidence']['menuAfterSuccess']['timestamp']>=result['evidence']['stages'][-1]['timestamp'],'Menu after successful water cycle')
 return {'passed':True,'menus_after_success':3,'supplement_native_receipts':3,'primary_native_receipts':18,'scope':'Final-PO finite Linux paths followed by actual menu; primary history unchanged; no Windows, hearing, hardware or global acceptance'}
def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--evidence',type=Path,default=ROOT/'.scratch/pt-pt/functional-cycles-menu');parser.add_argument('--primary',type=Path,default=ROOT/'.scratch/pt-pt/functional-cycles');args=parser.parse_args()
 try:print(json.dumps(audit(args.evidence,args.primary),indent=2))
 except (ValueError,OSError,KeyError,TypeError,tarfile.TarError) as error:print(str(error));return 1
 return 0
if __name__=='__main__':raise SystemExit(main())
