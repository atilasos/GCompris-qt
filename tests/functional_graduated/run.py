#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run a bounded native campaign through the current post-wait supervisor."""
import argparse,json,shutil,subprocess,sys,tempfile
from pathlib import Path
from inventory import ACTIVITIES,inventory
from phase import freeze
ROOT=Path(__file__).resolve().parents[2]
def main():
 p=argparse.ArgumentParser(description=__doc__)
 p.add_argument('--kind',choices=['gameplay','controls'],default='gameplay')
 p.add_argument('--activity',choices=ACTIVITIES,required=True);p.add_argument('--revision',required=True)
 p.add_argument('--snapshot',type=Path,required=True);p.add_argument('--output',type=Path,required=True)
 p.add_argument('--start-level',type=int,default=1);p.add_argument('--levels',type=int,default=1)
 a=p.parse_args()
 if not 1<=a.start_level<=29 or not 1<=a.levels<=30-a.start_level:p.error('Invalid nonempty level selection')
 if a.output.exists():p.error('Output must be new')
 a.output.parent.mkdir(parents=True,exist_ok=True);source=freeze(a.revision)
 plan=[r['rules']['nbOfQuestions'] for r in inventory(source)[a.activity]][a.start_level-1:a.start_level-1+a.levels]
 text=(ROOT/('tests/functional_graduated/'+a.kind+'.qml')).read_text()
 for name,file in [('VISIBLE','visible.fragment'),('ORACLE','oracle.fragment')]:text=text.replace('__'+name+'__',(ROOT/'tests/functional_graduated'/file).read_text())
 text=text.replace('__START__',str(a.start_level-1)).replace('__PLAN__',json.dumps(plan))
 text=text.replace('tryCompare(', 'assertEventually(').replace('compare(', 'assertEqual(').replace('verify(', 'assertTrue(')
 diagnostics=""" function assertTrue(value,message){if(!value)console.log('ASSERT_FAILED',message);verify(value,message);}
 function assertEqual(actual,expected,message){if(actual!==expected)console.log('COMPARE_FAILED',actual,expected,message);compare(actual,expected,message);}
 function assertEventually(object,property,value,timeout){try{tryCompare(object,property,value,timeout);}catch(error){console.log('WAIT_FAILED',property,object[property],value);throw error;}}
"""
 text=text.replace('TestCase {','TestCase {\n'+diagnostics,1)
 with tempfile.TemporaryDirectory(prefix='graduated-case-') as tmp:
  case=Path(tmp)/'case.qml';case.write_text(text)
  command=[sys.executable,str(ROOT/'tools/run-native-qml-supervised.py'),'--source-root',str(source),'--resource-snapshot',str(a.snapshot.resolve()),'--activity',a.activity,'--qml-file',str(source/'src/activities/graduated_line_read/GraduatedLineRead.qml'),'--case',str(case),'--output',str(a.output.resolve()),'--start-level',str(a.start_level),'--offline','--timeout',str(sum(plan)*20+90),'--result-marker','NATIVE_GRADUATED_RESULT']
  with (a.output.parent/(a.output.name+'-launcher.log')).open('w') as log:process=subprocess.run(command,stdout=log,stderr=subprocess.STDOUT)
  if a.output.exists():shutil.copyfile(case,a.output/'case.qml')
 d=json.loads((a.output/'result.json').read_text()) if (a.output/'result.json').exists() else {}
 native=d.get('case_result') or {}
 return 0 if process.returncode==0 and d.get('passed') and (len(native.get('completed',[]))==sum(plan) and native.get('wins')==a.levels if a.kind=='gameplay' else native.get('evidence',{}).get('menuByCtrlW',False)) else 1
if __name__=='__main__':raise SystemExit(main())
