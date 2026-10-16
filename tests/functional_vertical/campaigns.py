#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Complete all 36 datasets in twelve bounded, independent native cases."""
import argparse,json,subprocess,sys
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor,as_completed
from run import ACTIVITIES,ROOT

def main():
 p=argparse.ArgumentParser(description=__doc__)
 p.add_argument('--snapshot',type=Path,required=True);p.add_argument('--source-root',type=Path,required=True)
 p.add_argument('--output',type=Path,required=True);p.add_argument('--jobs',type=int,default=6)
 a=p.parse_args()
 if a.jobs<1:p.error('jobs must be positive')
 try:a.output.mkdir(parents=True,exist_ok=False)
 except FileExistsError:p.error('Use a new campaign directory')
 tasks=[(activity,start) for activity in ACTIVITIES for start in (1,4,7,10)]
 def run(task):
  activity,start=task;name=f'{activity}-{start:02}'
  command=[sys.executable,str(ROOT/'tests/functional_vertical/run.py'),'--activity',activity,
   '--snapshot',str(a.snapshot.resolve()),'--source-root',str(a.source_root.resolve()),
   '--output',str((a.output/name).resolve()),'--start-level',str(start),'--levels','3']
  code=subprocess.call(command)
  return {'activity':activity,'start':start,'levels':3,'puzzles':30,'exit_code':code,'output':name}
 rows=[]
 with ThreadPoolExecutor(max_workers=a.jobs) as pool:
  for future in as_completed([pool.submit(run,t) for t in tasks]):
   row=future.result();rows.append(row);print(json.dumps(row),flush=True)
   (a.output/'summary.json').write_text(json.dumps(sorted(rows,key=lambda r:r['output']),indent=2)+'\n')
 return 0 if len(rows)==12 and all(r['exit_code']==0 for r in rows) else 1
if __name__=='__main__':raise SystemExit(main())
