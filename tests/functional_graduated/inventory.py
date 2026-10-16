#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Describe the published dataset rules, not generated solutions."""
import json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
ACTIVITIES=('graduated_line_read','graduated_line_use')
def inventory(source=ROOT):
 result={}
 for activity in ACTIVITIES:
  rows=[]
  for file in sorted((source/'src/activities'/activity/'resource').glob('*/Data.qml'),key=lambda p:int(p.parent.name)):
   text=file.read_text();rules=[json.loads(s) for s in re.findall(r'"rules":\s*(\{[^}]+\})',text)]
   for sublevel,rule in enumerate(rules,1):rows.append({'dataset':int(file.parent.name),'within_dataset':sublevel,'rules':rule})
  result[activity]=rows
 return result
if __name__=='__main__':print(json.dumps(inventory(),indent=2))
