#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run actual connected-drawing UI with private resources and rendered-target selection."""
import argparse
from concurrent.futures import ThreadPoolExecutor
import hashlib
from datetime import datetime,timezone
import json
from pathlib import Path
import subprocess
import sys
ROOT=Path(__file__).resolve().parents[2]
ACTIVITIES=['number_sequence','clickanddraw','drawletters','drawnumbers']
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--snapshot',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--activity',action='append',choices=ACTIVITIES);p.add_argument('--mode',type=int,choices=[1,2]);p.add_argument('--jobs',type=int,default=4);p.add_argument('--start-level',type=int,default=1);p.add_argument('--levels',type=int,help='Bounded pilot only; omitted means every original level');a=p.parse_args()
if a.start_level<1 or (a.levels is not None and a.levels<1):p.error('Levels must be positive')
if a.output.exists() and any(a.output.iterdir()):p.error('Use a new empty output directory')
a.output.mkdir(parents=True,exist_ok=True)
raw=subprocess.check_output(['node',str(ROOT/'tests/functional_drawing/data.mjs'),'--strict-strokes'],text=True);data=json.loads(raw);(a.output/'data.json').write_text(raw)
if any(a.start_level>len(data[activity]) for activity in (a.activity or ACTIVITIES)):p.error('Start level outside selected activity')
tasks=[(activity,mode,highlight) for activity in (a.activity or ACTIVITIES) for mode in ([a.mode] if a.mode else [1,2]) for highlight in ([True,False] if activity=='number_sequence' else [True])]
if not tasks:p.error('No applicable cases')
def run(task):
 activity,mode,highlight=task;name=activity+'-mode'+str(mode)+'-highlight'+str(highlight).lower();case=a.output/(name+'.qml')
 offset=a.start_level-1
 fixture=data[activity][offset:offset+a.levels] if a.levels else data[activity][offset:]
 template=(ROOT/'tests/functional_drawing/gameplay.qml').read_text().replace('__MODE__',str(mode)).replace('__HIGHLIGHT__',str(highlight).lower()).replace('__FIXTURE__',json.dumps(fixture,ensure_ascii=False)).replace('__AUDIO__',(ROOT/'tests/functional_drawing/audio.fragment').read_text())
 if a.levels or offset:template=template.replace('checked(activity.numberOfLevel,fixture.length);checked(items.numberOfLevel,fixture.length);','checked(activity.numberOfLevel,'+str(len(data[activity]))+');checked(items.numberOfLevel,'+str(len(data[activity]))+');').replace('(level+1)%fixture.length','(level+1)%'+str(len(data[activity])))
 if offset:
  template=template.replace('checked(items.currentLevel,level);','checked(items.currentLevel,level+'+str(offset)+');').replace('(level+1)%'+str(len(data[activity])), '(level+1+'+str(offset)+')%'+str(len(data[activity]))).replace('level:level+1,points','level:level+1+'+str(offset)+',points')
 case.write_text(template)
 result=subprocess.Popen([sys.executable,str(ROOT/'tools/run-native-qml-case.py'),'--source-root',str(ROOT),'--resource-snapshot',str(a.snapshot.resolve()),'--activity',activity,'--qml-file','src/activities/number_sequence/NumberSequence.qml','--case',str(case.resolve()),'--output',str((a.output/name).resolve()),'--start-level',str(a.start_level),'--offline','--timeout','300','--result-marker','NATIVE_DRAWING_RESULT'],stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True)
 process_file=a.output/(name+'.process.json')
 receipt={'pid':result.pid,'started_utc':datetime.now(timezone.utc).isoformat()}
 process_file.write_text(json.dumps(receipt,indent=2)+'\n');print('START',name,'PID',result.pid,flush=True)
 stdout,stderr=result.communicate()
 receipt.update(exit_code=result.returncode,finished_utc=datetime.now(timezone.utc).isoformat());process_file.write_text(json.dumps(receipt,indent=2)+'\n')
 print(name,result.returncode,flush=True)
 return {'case':name,'exit_code':result.returncode,'output':stdout+stderr}
with ThreadPoolExecutor(max_workers=a.jobs) as e:results=list(e.map(run,tasks))
summary={'passed':bool(results) and all(r['exit_code']==0 for r in results),'cases':results,'pilot_levels':a.levels,'first_level':a.start_level,'full_original_levels':a.levels is None and a.start_level==1};(a.output/'summary.json').write_text(json.dumps(summary,indent=2)+'\n');raise SystemExit(0 if summary['passed'] else 1)
