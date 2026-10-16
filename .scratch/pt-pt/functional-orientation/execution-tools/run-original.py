#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""A native orientation case, with physical source and post-wait supervision."""
import argparse,hashlib,json,shutil,subprocess,sys,tempfile
from pathlib import Path
from phase import ROOT,freeze
ACTIVITIES={'leftright':'Leftright.qml','positions':'Positions.qml','left_right_click':'Left_right_click.qml'}
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--activity',choices=ACTIVITIES,required=True);p.add_argument('--revision',required=True);p.add_argument('--snapshot',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--kind',choices=['gameplay','controls'],default='gameplay')
 a=p.parse_args()
 if a.output.exists():p.error('Output must be new')
 source=freeze(a.revision);a.output.parent.mkdir(parents=True,exist_ok=True);suite=ROOT/'tests/functional_orientation'
 name='controls-'+a.activity if a.kind=='controls' else {'leftright':'hands','positions':'positions','left_right_click':'mouse'}[a.activity]
 text=(suite/(name+'.qml')).read_text().replace('__VISIBLE__',(suite/'visible.fragment').read_text()).replace('__SEMANTICS__',json.dumps(json.loads((suite/'hand-semantics.json').read_text())['images']))
 text=text.replace('compare(', 'checkEqual(').replace('verify(', 'checkTrue(')
 text=text.replace('TestCase {', '''TestCase {
 function checkEqual(actual,expected,message){if(actual!==expected)console.log('COMPARE_FAILED',actual,expected,message);compare(actual,expected,message);}
 function checkTrue(value,message){if(!value)console.log('ASSERT_FAILED',message);verify(value,message);}
''',1)
 with tempfile.TemporaryDirectory(prefix='orientation-case-') as temporary:
  case=Path(temporary)/'case.qml';case.write_text(text)
  command=[sys.executable,str(ROOT/'tools/run-native-qml-supervised.py'),'--source-root',str(source),'--resource-snapshot',str(a.snapshot.resolve()),'--activity',a.activity,'--qml-file',str(source/'src/activities'/a.activity/ACTIVITIES[a.activity]),'--case',str(case),'--output',str(a.output.resolve()),'--offline','--timeout','420','--result-marker','NATIVE_ORIENTATION_RESULT','--keep-deployment']
  with (a.output.parent/(a.output.name+'-launcher.log')).open('w') as log:process=subprocess.run(command,stdout=log,stderr=subprocess.STDOUT)
  status=a.output/'launcher-status.json'
  if process.returncode!=2 and status.is_file() and json.loads(status.read_text()).get('case_sha256')==hashlib.sha256(case.read_bytes()).hexdigest():shutil.copyfile(case,a.output/'case.qml')
 data=json.loads((a.output/'result.json').read_text()) if (a.output/'result.json').exists() else {};native=data.get('case_result') or {}
 expected={'leftright':32,'positions':26,'left_right_click':22}
 valid=native.get('evidence',{}).get('menu',False) if a.kind=='controls' else len(native.get('completed',[]))==expected[a.activity]
 return 0 if process.returncode==0 and data.get('passed') is True and valid else 1
if __name__=='__main__':raise SystemExit(main())
