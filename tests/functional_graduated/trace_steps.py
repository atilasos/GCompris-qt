#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Find a configured step using real previous/next clicks, then solve one sample."""
import argparse,json,shutil,subprocess,sys,tempfile
from pathlib import Path
from inventory import ACTIVITIES,inventory
from phase import freeze
ROOT=Path(__file__).resolve().parents[2]
def main():
 p=argparse.ArgumentParser(description=__doc__)
 p.add_argument('--activity',choices=ACTIVITIES,required=True);p.add_argument('--revision',required=True)
 p.add_argument('--snapshot',type=Path,required=True);p.add_argument('--output',type=Path,required=True)
 p.add_argument('--level',type=int,required=True);p.add_argument('--step',type=int,required=True)
 a=p.parse_args()
 if not 1<=a.level<=29 or a.step<=0:p.error('Positive configured level and step required')
 if a.output.exists():p.error('Output must be new')
 source=freeze(a.revision)
 if a.step not in inventory(source)[a.activity][a.level-1]['rules']['steps']:p.error('Step not published for this level')
 text=(ROOT/'tests/functional_graduated/steps.qml').read_text()
 for name,file in [('VISIBLE','visible.fragment'),('ORACLE','oracle.fragment')]:text=text.replace('__'+name+'__',(ROOT/'tests/functional_graduated'/file).read_text())
 text=text.replace('__LEVEL__',str(a.level)).replace('__STEP__',str(a.step));a.output.parent.mkdir(parents=True,exist_ok=True)
 with tempfile.TemporaryDirectory(prefix='graduated-step-') as tmp:
  case=Path(tmp)/'case.qml';case.write_text(text)
  command=[sys.executable,str(ROOT/'tools/run-native-qml-supervised.py'),'--source-root',str(source),'--resource-snapshot',str(a.snapshot.resolve()),'--activity',a.activity,'--qml-file',str(source/'src/activities/graduated_line_read/GraduatedLineRead.qml'),'--case',str(case),'--output',str(a.output.resolve()),'--start-level',str(a.level),'--offline','--timeout','600','--result-marker','NATIVE_GRADUATED_RESULT']
  with (a.output.parent/(a.output.name+'-launcher.log')).open('w') as log:run=subprocess.run(command,stdout=log,stderr=subprocess.STDOUT)
  if a.output.exists():shutil.copyfile(case,a.output/'case.qml')
 report=a.output/'result.json';d=json.loads(report.read_text()) if report.exists() else {}
 return 0 if run.returncode==0 and d.get('passed') and (d.get('case_result') or {}).get('evidence',{}).get('solved') else 1
if __name__=='__main__':raise SystemExit(main())
