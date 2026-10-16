#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Pure validation of finite diagnostic evidence; never a claim of crash correction."""
import argparse,hashlib,json,re,sys,tarfile
from pathlib import Path,PurePosixPath
ROOT=Path(__file__).resolve().parents[2]
EXPECTED_INDEX_SHA256='2c6ab96807acefdc932a2fb8d50b70a29c24fcc1aa45bf0315a7fdc037ae6ecf'
def sha(raw):return hashlib.sha256(raw).hexdigest()
def require(value,message):
 if not value:raise ValueError(message)
def validate_inferior(info,binary_sha256):
 require(info.get('native_exit_code')==0 and info.get('signals')==[],'Observed inferior exit0 and no SIGSEGV; wrapper0 is insufficient')
 require(info.get('identity_observed') is True and isinstance(info.get('qt_pid'),int) and info['qt_pid']>0,'Observed positive inferior PID')
 require(info.get('binary_sha256')==binary_sha256 and info.get('argv') and info['argv'][0]==info.get('binary') and info.get('cmdline_matches_binary') is True,'Actual /proc/PID/cmdline and binary identity')
 require(info.get('gdb_pid_namespace') and info['gdb_pid_namespace']==info.get('qt_pid_namespace'),'Aligned gdb/inferior PID namespaces')
 status=dict(line.split(':',1) for line in info['proc_status']);require(int(status['Pid'])==info['qt_pid'] and int(status['PPid'])==info['gdb_pid'],'Raw proc PID and parent agree with gdb')
 require([int(x) for x in status['NSpid'].split()]==[info['qt_pid']],'Host PID namespace actually observed')
def audit(base):
 def read(path):return json.loads((base/path).read_text())
 require(sha((base/'index.json').read_bytes())==EXPECTED_INDEX_SHA256,'Immutable diagnostic index')
 index=read('index.json')
 for path,digest in index['files'].items():
  parsed=PurePosixPath(path);require(not parsed.is_absolute() and '..' not in parsed.parts,'Relative archive path');require(sha((base/path).read_bytes())==digest,'Physical diagnostic bytes: '+path)
 selection=read('history/selection.json');old_index=read('history/index.json');require(selection['source_commit']=='a1226d4de3b620f47253cacd226c756a30cf2b3a','Pinned original81 Git proof')
 for path,digest in selection['files'].items():
  require(sha((base/'history'/path).read_bytes())==digest,'Original selected historical byte identity')
  if path in old_index['files']:require(old_index['files'][path]==digest,'Original81 immutable index agrees')
 original=read('history/penalty-complete/result.json');replay=read('history/penalty-replay/result.json');require(original['exit_code']==139 and not original['passed'] and original['case_result']['failures']==0 and len(original['case_result']['levels'])==9,'Original139 remains a failed shutdown, not a green campaign')
 require(replay['exit_code']==0 and replay['passed'] and original['case_sha256']==replay['case_sha256'],'Previously accepted exact normal replay remains distinct')
 chronology=read('chronology-final.json');require(chronology['one_case'] and chronology['one_binary'] and chronology['unique_deployments'] and all(row['pid_in_original_receipt'] is None for row in chronology['runs']),'Historical process uncertainty is retained')
 require(chronology['original_snapshot_available_files']==0 and chronology['verified_no_shared_main_inode'] is None,'Removed historical runtime cannot certify inode identity')
 observation=read('probes/observations.json');parent=read('probes/parent-status.json');require(observation['planned']==6 and observation['actual']==6 and len(observation['runs'])==6,'Exact finite nonempty matrix')
 require(parent['exit_code']==0 and parent['observations_sha256']==sha((base/'probes/observations.json').read_bytes()) and parent['session_id']==71199 and parent['chunk_id']=='d8ceb6','Observed external driver return, not inferred')
 sources={};manifests={}
 for phase,revision in index['phases'].items():
  manifest=read('sources/'+phase+'/source-manifest.json');require(manifest['revision']==revision,'Frozen phase revision');files={}
  with tarfile.open(base/'sources'/phase/'source.tar.xz','r:xz') as capsule:
   for entry in capsule.getmembers():
    path=PurePosixPath(entry.name);require(entry.isfile() and not path.is_absolute() and '..' not in path.parts and entry.name not in files,'Regular unique source capsule member');files[entry.name]=capsule.extractfile(entry).read()
  require({name:sha(raw) for name,raw in files.items()}==manifest['files'],'Exact frozen physical source bytes');sources[phase]=files;manifests[phase]=manifest['files']
 snapshot=read('snapshot-manifest.json');require(len(snapshot['files'])==269,'Complete new snapshot manifest');comparison=read('snapshot-comparison.json');require(comparison['same_binary'] and comparison['old_files']==comparison['new_files']==269 and len(comparison['changes'])==26,'Explicit new/historical environment differences')
 effective=read('effective-resources.json');seen=set()
 for row in observation['runs']:
  name=row['name'];phase=name.split('-')[0];mode=row['mode'];seen.add((phase,mode));prefix='probes/'+name;receipt=read(prefix+'/result.json');status=read(prefix+'/launcher-status.json');tool=read(prefix+'/tool-status.json');inferior=read(prefix+'/inferior-status.json');case=(base/prefix/'case.qml').read_bytes();source=sources[phase];manifest=manifests[phase];qml='src/activities/penalty/Penalty.qml'
  require(row['phase']==index['phases'][phase] and row['supervisor_return']==tool['exit_code']==status['exit_code']==0,'Actually observed launcher and supervisor returns')
  require(tool['native_receipt_sha256']==status['native_receipt_sha256']==sha((base/prefix/'result.json').read_bytes()) and tool['launcher_status_sha256']==sha((base/prefix/'launcher-status.json').read_bytes()),'All post-wait layers bind the raw wrapper receipt')
  require(row['case_sha256']==receipt['case_sha256']==status['case_sha256']==tool['case_sha256']==sha(case),'Exact executed diagnostic case')
  require(row['inferior']==inferior,'Inferior observation copied without inference');validate_inferior(inferior,snapshot['files']['bin/gcompris-qt'])
  require(tool['driver_sha256']==sha((base/'execution-tools/run.py').read_bytes()),'Exact finite driver bytes')
  adapter=base/'probes/inputs'/phase/'debug-launcher.py';require(sha(adapter.read_bytes())==row['diagnostic_launcher_sha256']==receipt['runner_sha256']==status['launcher_sha256'],'Exact private debugger adapter, distinct from original helper')
  require(row['source_launcher_sha256']==manifest['tools/run-native-qml-case.py'] and "'--pid=host'" in adapter.read_text(),'Frozen original helper plus explicit PID alignment delta')
  require(receipt['source_sha256']==manifest[qml] and receipt['portuguese_catalogue_sha256']==manifest['poqm/pt/gcompris_qt.po'],'Historical QML and PO phase identity')
  require(receipt['activity']=='penalty' and receipt['network']=='docker-none' and receipt['locale']=='pt_PT' and not receipt['timeout'] and receipt['passed'] and not receipt['qml_errors'],'Clean isolated diagnostic wrapper receipt')
  expected=dict(snapshot['files']);expected['share/gcompris-qt/rcc/penalty.rcc']=receipt['private_rcc_sha256'];expected['share/gcompris-qt/translations/gcompris_qt_pt.qm']=receipt['private_qm_sha256'];require(receipt['resource_files_sha256']==expected and receipt['resource_manifest_sha256']==sha((base/'snapshot-manifest.json').read_bytes()),'All effective runtime resource identities')
  evidence=receipt['case_result']['evidence'];require(receipt['case_result']['failures']==0 and evidence=={'mode':mode,'primary_levels':0,'retained_records':0 if mode=='bare' else 9},'No invented new gameplay from historical payload')
  if mode=='logged':require('qml: DIAGNOSTIC_HISTORICAL_PAYLOAD ' in (base/prefix/'native.log').read_text(),'Actual historical payload logging observed')
  resource=effective[name];require(sha((base/'effective'/name/'activity.rcc').read_bytes())==receipt['private_rcc_sha256'] and sha((base/'effective'/name/'catalogue.qm').read_bytes())==receipt['private_qm_sha256'],'Actual private RCC and QM')
  require({entry['path'].removeprefix(':/gcompris/') for entry in resource['files']}=={path for path in source if path.startswith('src/activities/penalty/')},'All actual activity resources preserved')
  for entry in resource['files']:
   path=entry['path'].removeprefix(':/gcompris/');actual=(base/'effective'/name/'files'/path).read_bytes();wanted=source[path]
   if path==qml:
    raw=wanted.decode();closing=re.search(r'\n    }\s*\n}\s*$',raw);fragment=case.decode().replace('__QA_OUTPUT__',resource['runtime_output']).replace('__QA_SOURCE__',resource['runtime_source']);wanted=('import QtTest\n'+raw[:closing.start()]+'\n'+fragment+raw[closing.start():]).encode()
   require(actual==wanted and sha(actual)==entry['sha256'] and len(actual)==entry['bytes'],'Actual RCC contents equal frozen source and exact diagnostic instrumentation')
 require(seen=={(phase,mode) for phase in ['baseline','final'] for mode in ['bare','retained','logged']},'All six planned variants, without stress expansion')
 for mode in ['bare','retained','logged']:require((base/'probes'/('baseline-'+mode)/'case.qml').read_bytes()==(base/'probes'/('final-'+mode)/'case.qml').read_bytes(),'Same diagnostic case across source phases')
 require(len(read('external-commands.json'))==6 and all(c['exit_code']==0 for c in read('external-commands.json')),'Observed real resource extraction commands')
 return {'archive_valid':True,'finite_probes':6,'inferior_exits':[0]*6,'historical_exit':139,'reproduced':False,'cause_known':False,'issue_resolved':False,'historical_pid_link':'temporal only','historical_runtime_files_available':0,'snapshot_changed_files':26,'scope':'No gameplay replay, no memory-pressure induction, no production fix, no Windows/global acceptance'}
def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--evidence',type=Path,default=ROOT/'.scratch/pt-pt/penalty-shutdown');args=parser.parse_args()
 try:print(json.dumps(audit(args.evidence),indent=2))
 except (ValueError,OSError,KeyError,TypeError,tarfile.TarError) as error:print('Shutdown evidence rejected: '+str(error),file=sys.stderr);return 1
 return 0
if __name__=='__main__':raise SystemExit(main())
