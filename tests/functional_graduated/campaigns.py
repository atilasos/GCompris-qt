#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run all 58 levels, including every configured question and natural Bonus."""
import argparse,json,subprocess,sys
from concurrent.futures import ThreadPoolExecutor,as_completed
from pathlib import Path
from inventory import ACTIVITIES,inventory
from phase import freeze
ROOT=Path(__file__).resolve().parents[2]
def main():
 p=argparse.ArgumentParser(description=__doc__)
 p.add_argument('--revision',required=True);p.add_argument('--snapshot',type=Path,required=True)
 p.add_argument('--output',type=Path,required=True);p.add_argument('--jobs',type=int,default=6)
 a=p.parse_args()
 if a.jobs<1:p.error('jobs must be positive')
 if a.output.exists():p.error('Use a new campaign output')
 # Resolve moving revisions and prepare the complete source before any workers.
 revision=freeze(a.revision).name
 a.output.mkdir(parents=True)
 tasks=[(activity,start,min(6,30-start)) for activity in ACTIVITIES for start in [1,7,13,19,25]]
 def run(task):
  activity,start,count=task;folder=f'{activity}-{start:02}'
  code=subprocess.call([sys.executable,str(ROOT/'tests/functional_graduated/run.py'),'--activity',activity,'--revision',revision,'--snapshot',str(a.snapshot.resolve()),'--output',str((a.output/folder).resolve()),'--start-level',str(start),'--levels',str(count)])
  return {'activity':activity,'start':start,'levels':count,'exit_code':code,'output':folder}
 rows=[]
 with ThreadPoolExecutor(max_workers=a.jobs) as pool:
  for future in as_completed([pool.submit(run,t) for t in tasks]):
   row=future.result();rows.append(row);print(json.dumps(row),flush=True)
   (a.output/'summary.json').write_text(json.dumps(sorted(rows,key=lambda r:r['output']),indent=2)+'\n')
 return 0 if len(rows)==10 and all(r['exit_code']==0 for r in rows) else 1
if __name__=='__main__':raise SystemExit(main())
