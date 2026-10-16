#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Six finite idle-shutdown probes, not gameplay or a stability acceptance run."""
import argparse,hashlib,json,os,shutil,subprocess,sys
from pathlib import Path
from phase import ROOT,freeze
HISTORY=ROOT/'.scratch/pt-pt/penalty-shutdown/history'
PHASES={'baseline':'597c05f0b1d41946cb0fffe8b99e1c837b627cb2','final':'1729d456c'}
MODES=['bare','retained','logged']
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def adapter(source):
 text=source.read_text();needle='    container = None\n'
 if text.count(needle)!=1 or text.count("'--network', 'none', '--read-only'")!=1:raise ValueError('Diagnostic boundary no longer matches the pinned launcher')
 text=text.replace(needle,"    command = ['/usr/bin/gdb', '--batch', '--return-child-result', '-x', os.environ['PT_SHUTDOWN_GDB_SCRIPT'], '--args', *command]\n"+needle)
 return text.replace("'--network', 'none', '--read-only'","'--pid=host', '--network', 'none', '--read-only'")
def case(mode,payload):
 return '''// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 when:activity.visible
 property string mode: MODE
 property string historicalJSON: PAYLOAD
 property var retained: []
 function test_idle_shutdown(){wait(1000);verify(goal.width>0&&ball.width>0);verify(String(instructionPanel.textItem.text).indexOf('baliza')>=0);if(mode!=='bare'){retained=JSON.parse(historicalJSON);compare(retained.length,9);}}
 function cleanupTestCase(){if(mode==='logged')console.log('DIAGNOSTIC_HISTORICAL_PAYLOAD',JSON.stringify(retained));console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:{mode:mode,primary_levels:0,retained_records:retained.length}}));}
}
'''.replace('property string mode: MODE','property string mode: '+json.dumps(mode)).replace('property string historicalJSON: PAYLOAD','property string historicalJSON: '+json.dumps(payload))
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--snapshot',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
 if a.output.exists():p.error('Output must be new')
 if not (a.snapshot/'manifest.json').is_file():p.error('Sealed snapshot is required')
 # Prepare both complete source trees before any Qt process. No concurrent writers.
 sources={phase:freeze(revision) for phase,revision in PHASES.items()};a.output.mkdir(parents=True);inputs=a.output/'inputs';inputs.mkdir();payload=json.dumps(json.loads((HISTORY/'penalty-complete/result.json').read_text())['case_result']['levels'],separators=(',',':'))
 for mode in MODES:(inputs/(mode+'.qml')).write_text(case(mode,payload))
 observations=[]
 for phase,source in sources.items():
  tools=inputs/phase;tools.mkdir();original=source/'tools/run-native-qml-case.py';launcher=tools/'debug-launcher.py';launcher.write_text(adapter(original));shutil.copyfile(source/'tools/native_qml_resources.py',tools/'native_qml_resources.py')
  for mode in MODES:
   name=phase+'-'+mode;output=a.output/name;case_path=inputs/(mode+'.qml');script=inputs/(name+'.gdb');observer=inputs/(name+'-observe.py');observer.write_text((ROOT/'tests/penalty_shutdown/gdb-observe.py').read_text().replace('__OUTPUT__',str(output.resolve())))
   script.write_text('set pagination off\nset confirm off\nset print thread-events off\nsource '+str(observer.resolve())+'\nrun\n')
   command=[sys.executable,str(source/'tools/run-native-qml-supervised.py'),'--launcher',str(launcher.resolve()),'--source-root',str(source),'--resource-snapshot',str(a.snapshot.resolve()),'--activity','penalty','--qml-file',str(source/'src/activities/penalty/Penalty.qml'),'--case',str(case_path.resolve()),'--output',str(output.resolve()),'--offline','--keep-deployment','--timeout','45']
   memory=Path('/proc/meminfo').read_text();(inputs/(name+'-meminfo-before.txt')).write_text(memory)
   with (inputs/(name+'-supervisor.log')).open('w') as log:process=subprocess.run(command,env=dict(os.environ,PT_SHUTDOWN_GDB_SCRIPT=str(script.resolve())),stdout=log,stderr=subprocess.STDOUT)
   receipt=output/'result.json';status=output/'launcher-status.json';inferior=output/'inferior-status.json'
   if receipt.is_file() and status.is_file():
    shutil.copyfile(case_path,output/'case.qml');record={'kind':'observed-diagnostic-supervisor-return-after-wait','exit_code':process.returncode,'native_receipt_sha256':sha(receipt),'launcher_status_sha256':sha(status),'case_sha256':sha(case_path),'driver_sha256':sha(Path(__file__))};(output/'tool-status.json').write_text(json.dumps(record,indent=2)+'\n')
   else:record={'kind':'failed-before-receipt','exit_code':process.returncode}
   native=json.loads(inferior.read_text()) if inferior.exists() else {};row={'name':name,'phase':source.name,'mode':mode,'supervisor_return':process.returncode,'inferior':native,'source_launcher_sha256':sha(original),'diagnostic_launcher_sha256':sha(launcher),'case_sha256':sha(case_path)};observations.append(row);print(name,process.returncode,native.get('native_exit_code'),native.get('signals'),flush=True)
   # A real SIGSEGV stops this finite matrix so its stack is preserved for diagnosis.
   if 'SIGSEGV' in native.get('signals',[]) or process.returncode!=0 or not native.get('identity_observed'):break
  if observations and (observations[-1]['supervisor_return']!=0 or not observations[-1]['inferior'].get('identity_observed')):break
 (a.output/'observations.json').write_text(json.dumps({'planned':6,'actual':len(observations),'runs':observations,'scope':'Idle diagnostic variants; historical payload is not newly played gameplay; gdb wrapper exit is distinct from inferior status'},indent=2)+'\n')
 return 0 if len(observations)==6 and all(row['supervisor_return']==0 and row['inferior'].get('native_exit_code')==0 and row['inferior'].get('identity_observed') and row['inferior'].get('cmdline_matches_binary') and row['inferior'].get('gdb_pid_namespace')==row['inferior'].get('qt_pid_namespace') for row in observations) else 1
if __name__=='__main__':raise SystemExit(main())
