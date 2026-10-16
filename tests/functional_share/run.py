#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Bounded candy-sharing native UI campaign; child and outer status are distinct."""
import argparse,hashlib,json,shutil,subprocess,sys,tempfile
from pathlib import Path
from phase import ROOT,freeze
from inventory import inventory

def main():
 p=argparse.ArgumentParser(description=__doc__)
 p.add_argument('--revision',required=True);p.add_argument('--snapshot',type=Path,required=True);p.add_argument('--output',type=Path,required=True)
 p.add_argument('--mode',choices=['counters','hidden'],default='counters');p.add_argument('--kind',choices=['gameplay','controls','drag_boundary','resources'],default='gameplay')
 p.add_argument('--start-level',type=int,default=1);p.add_argument('--levels',type=int,default=1)
 a=p.parse_args()
 if not 1<=a.start_level<=15 or not 1<=a.levels<=16-a.start_level:p.error('Invalid nonempty level selection')
 if a.output.exists():p.error('Output must be new')
 source=freeze(a.revision);a.output.parent.mkdir(parents=True,exist_ok=True)
 plan=[len(row['subLevels']) for row in inventory(source)][a.start_level-1:a.start_level-1+a.levels]
 suite=ROOT/'tests/functional_share';text=(suite/(a.kind+'.qml')).read_text().replace('__VISIBLE__',(suite/'visible.fragment').read_text()).replace('__START__',str(a.start_level-1)).replace('__PLAN__',json.dumps(plan)).replace('__EASY__','true' if a.mode=='counters' else 'false')
 text=text.replace('compare(', 'checkEqual(').replace('verify(', 'checkTrue(')
 text=text.replace('TestCase {', '''TestCase {
 function checkEqual(actual,expected,message){if(actual!==expected)console.log('COMPARE_FAILED',actual,expected,message);compare(actual,expected,message);}
 function checkTrue(value,message){if(!value)console.log('ASSERT_FAILED',message);verify(value,message);}
''',1)
 with tempfile.TemporaryDirectory(prefix='share-case-') as tmp:
  case=Path(tmp)/'case.qml';case.write_text(text)
  command=[sys.executable,str(ROOT/'tools/run-native-qml-supervised.py'),'--source-root',str(source),'--resource-snapshot',str(a.snapshot.resolve()),'--activity','share','--qml-file',str(source/'src/activities/share/Share.qml'),'--case',str(case),'--output',str(a.output.resolve()),'--start-level',str(a.start_level),'--offline','--timeout',str(sum(plan)*25+100),'--result-marker','NATIVE_SHARE_RESULT']
  if a.kind=='resources':command.append('--keep-deployment')
  with (a.output.parent/(a.output.name+'-launcher.log')).open('w') as log:process=subprocess.run(command,stdout=log,stderr=subprocess.STDOUT)
  # A rejected pre-existing output belongs to somebody else. Preserve the
  # generated case only when the post-wait status identifies this exact input.
  status=a.output/'launcher-status.json'
  if process.returncode!=2 and status.is_file() and json.loads(status.read_text()).get('case_sha256')==hashlib.sha256(case.read_bytes()).hexdigest():
   shutil.copyfile(case,a.output/'case.qml')
 d=json.loads((a.output/'result.json').read_text()) if (a.output/'result.json').exists() else {};native=d.get('case_result') or {}
 valid=(len(native.get('completed',[]))==sum(plan) and native.get('wins')==a.levels) if a.kind=='gameplay' else native.get('evidence',{}).get('menu',False) if a.kind=='controls' else native.get('passes',0)>0
 return 0 if process.returncode==0 and d.get('passed') is True and valid else 1
if __name__=='__main__':raise SystemExit(main())
