#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Inventory Gnumch source datasets and bytes without its answer validators."""
import hashlib
import json
from pathlib import Path
import re
ROOT=Path(__file__).resolve().parents[2]
ACTIVITIES=['gnumch-equality','gnumch-inequality','gnumch-factors','gnumch-multiples','gnumch-primes']

def inventory():
 result={'activities':{},'source_files':{}}
 for name in ACTIVITIES:
  source=ROOT/'src/activities'/name
  datasets=[];levels=[]
  for path in sorted(source.glob('resource/*/Data.qml'),key=lambda p:int(p.parent.name)):
   data=json.loads(re.search(r'data:\s*(\[[\s\S]*\])',path.read_text())[1]);datasets.append(path.parent.name)
   levels.extend({'dataset':path.parent.name,**row} for row in data)
  result['activities'][name]={'datasets':datasets,'levels':levels,'level_count':len(levels) if datasets else 8}
  for path in source.rglob('*'):
   if path.is_file():result['source_files'][path.relative_to(ROOT).as_posix()]=hashlib.sha256(path.read_bytes()).hexdigest()
 assert sum(v['level_count'] for v in result['activities'].values())==104
 return result
if __name__=='__main__':print(json.dumps(inventory(),indent=2))
