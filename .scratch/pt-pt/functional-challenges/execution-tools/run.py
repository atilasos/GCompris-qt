#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Bounded native arithmetic campaigns with exact archived-case replay."""
import argparse,hashlib,json,shutil,subprocess,sys,tempfile
from pathlib import Path
from phase import ROOT,freeze
from inventory import inventory
ACTIVITIES={'guess24':'Guess24.qml','guesscount':'Guesscount.qml'}
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--activity',choices=ACTIVITIES,required=True);p.add_argument('--revision',required=True);p.add_argument('--snapshot',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--kind',choices=['gameplay','admin','controls'],default='gameplay');p.add_argument('--start-level',type=int,default=1);p.add_argument('--levels',type=int,default=1);p.add_argument('--case-file',type=Path);a=p.parse_args()
 maximum=6 if a.activity=='guess24' else 8 if a.kind=='admin' else 17
 if not 1<=a.start_level<=maximum or not 1<=a.levels<=maximum+1-a.start_level:p.error('Invalid nonempty level selection')
 if a.kind=='admin' and a.activity!='guesscount':p.error('Admin is offered only by guesscount')
 if a.case_file is not None and not a.case_file.is_file():p.error('Replay case must exist')
 if a.output.exists():p.error('Output must be new')
 source=freeze(a.revision);data=inventory(source);a.output.parent.mkdir(parents=True,exist_ok=True);suite=ROOT/'tests/functional_challenges';curriculum=data['admin']['schema'] if a.kind=='admin' else [row['count'] for row in data[a.activity]];plan=curriculum[a.start_level-1:a.start_level-1+a.levels]
 filename=('controls-'+a.activity if a.kind=='controls' else a.activity)+'.qml'
 text=(suite/filename).read_text().replace('__VISIBLE__',(suite/'visible.fragment').read_text()).replace('__SOLVER__',(suite/'solver.fragment').read_text()).replace('__PLAN__',json.dumps(plan)).replace('__START__',str(a.start_level-1)).replace('__ADMIN__','true' if a.kind=='admin' else 'false')
 if a.case_file is not None:text=a.case_file.read_text()
 else:
  text=text.replace('compare(', 'checkEqual(').replace('verify(', 'checkTrue(')
  text=text.replace('TestCase {', '''TestCase {
 function checkEqual(actual,expected,message){if(actual!==expected)console.log('COMPARE_FAILED',actual,expected,message);compare(actual,expected,message);}
 function checkTrue(value,message){if(!value)console.log('ASSERT_FAILED',message);verify(value,message);}
''',1)
 with tempfile.TemporaryDirectory(prefix='challenge-case-') as temporary:
  case=Path(temporary)/'case.qml';case.write_text(text)
  command=[sys.executable,str(ROOT/'tools/run-native-qml-supervised.py'),'--source-root',str(source),'--resource-snapshot',str(a.snapshot.resolve()),'--activity',a.activity,'--qml-file',str(source/'src/activities'/a.activity/ACTIVITIES[a.activity]),'--case',str(case),'--output',str(a.output.resolve()),'--offline','--timeout',str(sum(plan)*30+120),'--result-marker','NATIVE_CHALLENGES_RESULT','--keep-deployment','--start-level',str(a.start_level)]
  with (a.output.parent/(a.output.name+'-launcher.log')).open('w') as log:process=subprocess.run(command,stdout=log,stderr=subprocess.STDOUT)
  status=a.output/'launcher-status.json'
  if process.returncode!=2 and status.is_file() and json.loads(status.read_text()).get('case_sha256')==hashlib.sha256(case.read_bytes()).hexdigest():shutil.copyfile(case,a.output/'case.qml')
 d=json.loads((a.output/'result.json').read_text()) if (a.output/'result.json').exists() else {};native=d.get('case_result') or {}
 valid=native.get('evidence',{}).get('menu',False) if a.kind=='controls' else len(native.get('completed',[]))==sum(plan) and native.get('wins')==a.levels
 return 0 if process.returncode==0 and d.get('passed') is True and valid else 1
if __name__=='__main__':raise SystemExit(main())
