#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Prepare complete sources once before a bounded pool of independent cases."""
import argparse,json,subprocess,sys
from concurrent.futures import ThreadPoolExecutor,as_completed
from pathlib import Path
from phase import ROOT,freeze

def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--revision',required=True);p.add_argument('--snapshot',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--jobs',type=int,default=3);a=p.parse_args()
 if a.jobs<1:p.error('Jobs must be positive')
 if a.output.exists():p.error('Output must be new')
 revision=freeze(a.revision).name;a.output.mkdir(parents=True);rows=[]
 tasks=[(activity,kind) for activity in ['leftright','positions','left_right_click'] for kind in ['gameplay','controls']]
 def run(task):
  activity,kind=task;folder=activity+'-'+kind
  code=subprocess.call([sys.executable,str(ROOT/'tests/functional_orientation/capture.py'),'--activity',activity,'--revision',revision,'--snapshot',str(a.snapshot.resolve()),'--output',str((a.output/folder).resolve()),'--kind',kind])
  return {'activity':activity,'kind':kind,'exit_code':code,'output':folder}
 with ThreadPoolExecutor(max_workers=a.jobs) as pool:
  for future in as_completed([pool.submit(run,task) for task in tasks]):
   rows.append(future.result());print(json.dumps(rows[-1]),flush=True);(a.output/'summary.json').write_text(json.dumps(rows,indent=2)+'\n')
 return 0 if len(rows)==6 and all(row['exit_code']==0 for row in rows) else 1
if __name__=='__main__':raise SystemExit(main())
