#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Produce real-input cases from independent rules; never change existing cases."""
import argparse,json
from dataclasses import asdict
from pathlib import Path
from lock_plan import State,plan,step
ROOT=Path(__file__).resolve().parent
def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True);args=parser.parse_args()
 if args.output.exists():parser.error('Case directory must be new')
 common=(ROOT/'controls-common.fragment').read_text();state=State();legs=[]
 for goal in [2,0]:
  rows=[]
  for action in plan(state,goal):state=step(state,action);rows.append({'action':action,'after':asdict(state)})
  legs.append(rows)
 cases={'canal.qml':(ROOT/'canal.qml').read_text().replace('__PLAN__',json.dumps(legs))}
 for activity in ['canal','water','energy']:cases['controls-'+activity+'.qml']=(ROOT/('controls-'+activity+'.qml')).read_text().replace('__COMMON__',common)
 args.output.mkdir(parents=True)
 for name,text in cases.items():(args.output/name).write_text(text)
if __name__=='__main__':main()
