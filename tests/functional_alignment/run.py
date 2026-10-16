#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run real alignment inputs against a pre-frozen source and private snapshot."""
import argparse,hashlib,json,os,shutil,subprocess,sys,uuid
from pathlib import Path
from phase import ACTIVITIES,verify_source
from oracle import draw_route
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent

def main():
 if not __debug__:raise SystemExit('Alignment validation requires assertions; Python -O rejected')
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--source-root',type=Path,required=True);parser.add_argument('--snapshot',type=Path,required=True);parser.add_argument('--activity',choices=ACTIVITIES,required=True);parser.add_argument('--output',type=Path,required=True);group=parser.add_mutually_exclusive_group();group.add_argument('--case',choices=['tracer','gameplay','controls','help','draw','contract','keyboard']);group.add_argument('--exact-case',type=Path);parser.add_argument('--starter',type=int,choices=[1,2],default=1);args=parser.parse_args()
 source=args.source_root.resolve();output=args.output.resolve();verify_source(source)
 if output.exists():parser.error('Use a new output directory')
 gravity=args.activity.startswith('align4');two=args.activity.endswith('2players')
 text=args.exact_case.read_text() if args.exact_case else (HERE/((args.case or 'gameplay')+'.qml')).read_text().replace('__VISIBLE__',(HERE/'visible.fragment').read_text()).replace('__GRAVITY__','true' if gravity else 'false').replace('__TWO__','true' if two else 'false').replace('__DRAW_ROUTE__',json.dumps(draw_route())).replace('__STARTER__',str(args.starter))
 case=ROOT/'build/alignment-cases'/(hashlib.sha256(text.encode()).hexdigest()+'.qml');case.parent.mkdir(parents=True,exist_ok=True)
 if case.exists():assert case.read_text()==text
 else:case.write_text(text)
 syntax=subprocess.run(['/usr/lib/qt6/bin/qmlformat','--ignore-settings',str(case)],capture_output=True,text=True)
 if syntax.returncode:parser.error('Invalid QML case: '+syntax.stderr)
 qml='align4_2players/Align42players.qml' if gravity else 'tic_tac_toe/TicTacToe.qml'
 command=[sys.executable,str(source/'tools/run-native-qml-supervised.py'),'--source-root',str(source),'--resource-snapshot',str(args.snapshot.resolve()),'--activity',args.activity,'--qml-file',str(source/'src/activities'/qml),'--case',str(case),'--output',str(output),'--offline','--timeout','1800','--result-marker','NATIVE_ALIGNMENT_RESULT']
 completed=subprocess.run(command,env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1',PYTHONPYCACHEPREFIX=str(ROOT/'build/alignment-python-cache'/uuid.uuid4().hex)))
 if output.exists():
  shutil.copyfile(case,output/'case.qml');receipt=output/'result.json';status=output/'launcher-status.json';sha=lambda path:hashlib.sha256(path.read_bytes()).hexdigest() if path.is_file() else None
  observed={'kind':'observed-supervisor-subprocess-exit','exit_code':completed.returncode,'native_receipt_sha256':sha(receipt),'launcher_status_sha256':sha(status),'case_sha256':sha(case),'supervisor_sha256':sha(source/'tools/run-native-qml-supervised.py')};(output/'supervisor-exit.json').write_text(json.dumps(observed,indent=2)+'\n')
 return completed.returncode
if __name__=='__main__':raise SystemExit(main())
