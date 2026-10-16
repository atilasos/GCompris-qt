#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Read-only chronology and current filesystem observations, never PID attribution by time alone."""
import argparse,datetime,hashlib,json,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
BASE=ROOT/'.scratch/pt-pt/penalty-shutdown'
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def utc(ms):return datetime.datetime.fromtimestamp(ms/1000,datetime.timezone.utc).isoformat()
def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--original-runtime',type=Path,required=True);parser.add_argument('--main-prefix',type=Path,required=True);parser.add_argument('--output',type=Path,required=True);args=parser.parse_args()
 if args.output.exists():parser.error('Output must be new')
 history=BASE/'history';selection=json.loads((history/'selection.json').read_text());index=json.loads((history/'index.json').read_text());records=[]
 for path,digest in selection['files'].items():
  if sha(history/path)!=digest:raise ValueError('Historical physical input changed: '+path)
  if path in index['files'] and index['files'][path]!=digest:raise ValueError('Original81 index disagrees: '+path)
 for name in ['penalty-complete','penalty-replay','diagnostics/penalty-gdb','diagnostics/penalty-gdb2']:
  receipt=json.loads((history/name/'result.json').read_text());status=json.loads((history/name/'launcher-status.json').read_text());tool=json.loads((history/name/'tool-status.json').read_text());case=history/name/'case.qml';levels=receipt['case_result']['levels'];inputs=[value for row in levels for key,value in row.items() if key in ['firstClick','secondClick']]
  if status['native_receipt_sha256']!=sha(history/name/'result.json') or tool['native_receipt_sha256']!=status['native_receipt_sha256']:raise ValueError('Status identity mismatch')
  if receipt['case_sha256']!=sha(case) or status['case_sha256']!=sha(case):raise ValueError('Case identity mismatch')
  records.append({'name':name,'metadata_created_before_Popen_utc':receipt['timestamp_utc'],'first_observed_input_utc':utc(min(inputs)),'last_observed_input_utc':utc(max(inputs)),'native_or_gdb_wrapper_exit':receipt['exit_code'],'supervisor_exit':status['exit_code'],'tool_exit':tool['exit_code'],'assertions_failed':receipt['case_result']['failures'],'completed_levels':len(levels),'deployment':receipt['deployment'],'snapshot':receipt['resource_snapshot'],'binary_sha256':receipt['binary_sha256'],'active_rcc_sha256':receipt['private_rcc_sha256'],'qm_sha256':receipt['private_qm_sha256'],'case_sha256':receipt['case_sha256'],'pid_in_original_receipt':None,'gdb_wrapper':name.startswith('diagnostics/')})
 observations=[]
 for record in records:
  original=Path(record['deployment']);entries={}
  for relative,expected in [('bin/gcompris-qt',record['binary_sha256']),('share/gcompris-qt/rcc/penalty.rcc',record['active_rcc_sha256']),('share/gcompris-qt/translations/gcompris_qt_pt.qm',record['qm_sha256'])]:
   p=original/relative
   if not p.is_file():entries[relative]={'available_now':False};continue
   st=p.stat();current=sha(p);entries[relative]={'available_now':True,'sha256':current,'matches_receipt':current==expected,'is_symlink':p.is_symlink(),'device':st.st_dev,'inode':st.st_ino,'mtime_ns_observed_now':st.st_mtime_ns,'bytes':st.st_size}
  observations.append({'deployment':str(original),'files':entries})
 snapshot=args.original_runtime/'snapshot';manifest=json.loads((history/'snapshot-manifest.json').read_text());physical=[];shared=[]
 for relative,digest in manifest['files'].items():
  p=snapshot/relative;target=args.main_prefix/relative
  if not p.is_file():physical.append({'path':relative,'available_now':False});continue
  st=p.stat();same=False
  if target.exists():same=(st.st_dev,st.st_ino)==(target.stat().st_dev,target.stat().st_ino)
  if same:shared.append(relative)
  physical.append({'path':relative,'available_now':True,'is_symlink':p.is_symlink(),'matches_historical_manifest':sha(p)==digest,'shares_current_main_inode':same,'device':st.st_dev,'inode':st.st_ino})
 output={'observed_now_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'historical_source_commit':selection['source_commit'],'runs':records,'unique_deployments':len({r['deployment'] for r in records})==len(records),'one_case':len({r['case_sha256'] for r in records})==1,'one_binary':len({r['binary_sha256'] for r in records})==1,'current_deployment_observations':observations,'original_snapshot_observations':physical,'original_snapshot_files':len(manifest['files']),'original_snapshot_available_files':sum(p.get('available_now') is True for p in physical),'verified_no_shared_main_inode':not shared if all(p.get('available_now') is True for p in physical) else None,'shares_current_main_inode':shared,'pid_conclusion':'No PID in original Qt/supervisor receipts. KernelPID4137796 correlation is temporal, not an established process identity. Old gdb lacked pid=host; no old stack is used as evidence.','immutability_conclusion':'Frozen physical snapshot and unique private active RCC/QM/bin; original launcher verified manifest before/after. Current matching bytes and distinct inodes reinforce isolation; no syscall trace from failed process excludes every possible transient host write.','prior23':'23 deliberately rewrote a mapped inactive RCC and captured QResource/qsTr crash. No rewrite is induced here, and no equivalent causal chain is demonstrated.'}
 args.output.parent.mkdir(parents=True,exist_ok=True);args.output.write_text(json.dumps(output,indent=2)+'\n');print(json.dumps({'runs':len(records),'one_case':output['one_case'],'one_binary':output['one_binary'],'unique_deployments':output['unique_deployments'],'snapshot_manifest_files':len(physical),'snapshot_available_files':output['original_snapshot_available_files'],'verified_no_shared_main_inode':output['verified_no_shared_main_inode']}))
if __name__=='__main__':raise SystemExit(main())
