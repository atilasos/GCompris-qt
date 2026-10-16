#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Prepare once, then finish every dataset in both available counter modes."""
import argparse,json,subprocess,sys
from concurrent.futures import ThreadPoolExecutor,as_completed
from pathlib import Path
from phase import ROOT,freeze

def main():
 p=argparse.ArgumentParser(description=__doc__)
 p.add_argument('--revision',required=True);p.add_argument('--snapshot',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--jobs',type=int,default=6)
 a=p.parse_args()
 if a.jobs<1:p.error('jobs must be positive')
 if a.output.exists():p.error('Output must be new')
 revision=freeze(a.revision).name;a.output.mkdir(parents=True)
 tasks=[(mode,start) for mode in ['counters','hidden'] for start in [1,6,11]]
 def run(task):
  mode,start=task;folder=f'{mode}-{start:02}'
  code=subprocess.call([sys.executable,str(ROOT/'tests/functional_share/run.py'),'--revision',revision,'--snapshot',str(a.snapshot.resolve()),'--output',str((a.output/folder).resolve()),'--mode',mode,'--start-level',str(start),'--levels','5'])
  return {'mode':mode,'start':start,'levels':5,'exit_code':code,'output':folder}
 rows=[]
 with ThreadPoolExecutor(max_workers=a.jobs) as pool:
  for future in as_completed([pool.submit(run,task) for task in tasks]):
   rows.append(future.result());print(json.dumps(rows[-1]),flush=True)
   (a.output/'summary.json').write_text(json.dumps(sorted(rows,key=lambda row:row['output']),indent=2)+'\n')
 return 0 if len(rows)==6 and all(row['exit_code']==0 for row in rows) else 1
if __name__=='__main__':raise SystemExit(main())
