#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run bounded vertical arithmetic through the visible Qt interface."""
import argparse,json,shutil,subprocess,sys,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
ACTIVITIES=('vertical_addition','vertical_subtraction','vertical_subtraction_compensation')
def main():
 p=argparse.ArgumentParser(description=__doc__)
 p.add_argument('--activity',choices=ACTIVITIES,required=True)
 p.add_argument('--kind',choices=['gameplay','controls'],default='gameplay')
 p.add_argument('--snapshot',type=Path,required=True);p.add_argument('--source-root',type=Path,default=ROOT)
 p.add_argument('--output',type=Path,required=True);p.add_argument('--start-level',type=int,default=1)
 p.add_argument('--levels',type=int,default=1);p.add_argument('--puzzles',type=int,default=10)
 a=p.parse_args()
 if not 1<=a.start_level<=12 or not 1<=a.levels<=13-a.start_level or not 1<=a.puzzles<=10:p.error('Invalid nonempty level/puzzle selection')
 try:a.output.mkdir(parents=True,exist_ok=False)
 except FileExistsError:p.error('Use a new output directory')
 text=(ROOT/('tests/functional_vertical/'+a.kind+'.qml')).read_text().replace('__ORACLE__',(ROOT/'tests/functional_vertical/oracle.qml').read_text())
 for key,value in [('START',a.start_level-1),('LEVELS',a.levels),('PUZZLES',a.puzzles)]:text=text.replace('__'+key+'__',str(value))
 with tempfile.TemporaryDirectory(prefix='vertical-case-') as tmp:
  case=Path(tmp)/'case.qml';case.write_text(text)
  command=[sys.executable,str(ROOT/'tools/run-native-qml-case.py'),'--source-root',str(a.source_root.resolve()),'--resource-snapshot',str(a.snapshot.resolve()),'--activity',a.activity,'--qml-file',str(a.source_root.resolve()/'src/activities/vertical_subtraction/VerticalSubtraction.qml'),'--case',str(case),'--output',str(a.output.resolve()),'--start-level',str(a.start_level),'--offline','--timeout',str(a.levels*a.puzzles*25+60),'--result-marker','NATIVE_VERTICAL_RESULT']
  with (a.output.parent/(a.output.name+'-launcher.log')).open('w') as log:run=subprocess.run(command,stdout=log,stderr=subprocess.STDOUT)
  shutil.copyfile(case,a.output/'case.qml')
 d=json.loads((a.output/'result.json').read_text()) if (a.output/'result.json').exists() else {}
 native=d.get('case_result') or {}
 passed=run.returncode==0 and d.get('passed',False) and d.get('exit_code')==0 and (len(native.get('completed',[]))==a.levels*a.puzzles if a.kind=='gameplay' else native.get('evidence',{}).get('menu',False))
 (a.output/'launcher-status.json').write_text(json.dumps({'exit_code':run.returncode,'passed':passed},indent=2)+'\n')
 return 0 if passed else 1
if __name__=='__main__':raise SystemExit(main())
