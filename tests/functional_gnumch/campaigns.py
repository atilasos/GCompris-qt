#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run the fixed, nonempty 104-level Gnumch matrix with bounded workers."""
import argparse
from concurrent.futures import ThreadPoolExecutor,as_completed
import json
from pathlib import Path
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[2]

def main():
 p=argparse.ArgumentParser(description=__doc__)
 p.add_argument('--snapshot',type=Path,required=True);p.add_argument('--source-root',type=Path,required=True)
 p.add_argument('--output',type=Path,required=True);p.add_argument('--jobs',type=int,default=11)
 a=p.parse_args()
 if a.jobs<1:p.error('jobs must be positive')
 try:a.output.mkdir(parents=True,exist_ok=False)
 except FileExistsError:p.error('Use a new campaign directory')
 jobs=[(activity,start,10) for activity in ['gnumch-equality','gnumch-inequality'] for start in [1,11,21,31]]
 jobs += [(activity,1,8) for activity in ['gnumch-factors','gnumch-multiples','gnumch-primes']]
 def run(job):
  activity,start,levels=job;output=a.output/f'{activity}-{start:02}'
  code=subprocess.call([sys.executable,str(ROOT/'tests/functional_gnumch/run.py'),'--activity',activity,
   '--snapshot',str(a.snapshot.resolve()),'--source-root',str(a.source_root.resolve()),
   '--start-level',str(start),'--levels',str(levels),'--output',str(output.resolve())],cwd=ROOT)
  return {'activity':activity,'start':start,'levels':levels,'exit_code':code,'output':output.name}
 rows=[]
 with ThreadPoolExecutor(max_workers=a.jobs) as pool:
  for future in as_completed([pool.submit(run,j) for j in jobs]):
   row=future.result();rows.append(row);print(json.dumps(row),flush=True)
   (a.output/'summary.json').write_text(json.dumps(sorted(rows,key=lambda r:r['output']),indent=2)+'\n')
 return 0 if len(rows)==11 and all(row['exit_code']==0 for row in rows) else 1
if __name__=='__main__':raise SystemExit(main())
