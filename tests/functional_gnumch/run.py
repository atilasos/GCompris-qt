#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run one bounded native Gnumch campaign using visible arithmetic."""
import argparse
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ROOT=Path(__file__).resolve().parents[2]
LEVELS={name:40 if name in ('gnumch-equality','gnumch-inequality') else 8
        for name in ('gnumch-equality','gnumch-inequality','gnumch-factors','gnumch-multiples','gnumch-primes')}

def main():
 p=argparse.ArgumentParser(description=__doc__)
 p.add_argument('--activity',choices=list(LEVELS),required=True)
 p.add_argument('--snapshot',type=Path,required=True)
 p.add_argument('--output',type=Path,required=True)
 p.add_argument('--source-root',type=Path,default=ROOT)
 p.add_argument('--start-level',type=int,default=1)
 p.add_argument('--levels',type=int,required=True)
 a=p.parse_args();total=LEVELS[a.activity]
 if not 1<=a.start_level<=total or not 1<=a.levels<=total-a.start_level+1:p.error('Invalid level selection')
 try:a.output.mkdir(parents=True,exist_ok=False)
 except FileExistsError:p.error('Use a new output directory')
 text=(ROOT/'tests/functional_gnumch/gameplay.qml').read_text()
 text=text.replace('__VISIBLE__',(ROOT/'tests/functional_gnumch/visible.fragment').read_text())
 for name,value in [('START',a.start_level-1),('COUNT',a.levels),('TOTAL',total)]:text=text.replace('__'+name+'__',str(value))
 with tempfile.TemporaryDirectory(prefix='gnumch-case-') as temporary:
  case=Path(temporary)/'case.qml';case.write_text(text)
  command=[sys.executable,str(ROOT/'tools/run-native-qml-case.py'),'--source-root',str(a.source_root.resolve()),
   '--resource-snapshot',str(a.snapshot.resolve()),'--activity',a.activity,'--qml-file',str(a.source_root.resolve()/'src/activities/gnumch-equality/Gnumch.qml'),
   '--case',str(case),'--output',str(a.output.resolve()),'--start-level',str(a.start_level),'--offline',
   '--timeout',str(a.levels*200+60),'--result-marker','NATIVE_GNUMCH_RESULT']
  with (a.output.parent/(a.output.name+'-launcher.log')).open('w') as log:run=subprocess.run(command,stdout=log,stderr=subprocess.STDOUT)
  shutil.copyfile(case,a.output/'case.qml')
 report=a.output/'result.json';d=json.loads(report.read_text()) if report.exists() else {}
 native=d.get('case_result') or {}
 passed=run.returncode==0 and d.get('passed',False) and d.get('exit_code')==0 and len(native.get('completed',[]))==a.levels and native.get('wins')==a.levels
 (a.output/'launcher-status.json').write_text(json.dumps({'exit_code':run.returncode,'passed':passed,'command':command},indent=2)+'\n')
 return 0 if passed else 1
if __name__=='__main__':raise SystemExit(main())
