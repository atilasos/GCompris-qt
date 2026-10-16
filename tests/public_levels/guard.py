#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Reject the proven change-handler-only pattern in this repaired inventory.

A static regression guard supplements, and does not replace, native Qt cases.
It does not classify activities outside task 82 or levels hidden by game modes.
"""
import argparse,json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
def violations(root):
 result=[]
 inventory=json.loads((Path(__file__).with_name('inventory.json')).read_text())
 for _,relative,_ in inventory:
  p=root/'src/activities'/relative;t=p.read_text()
  if re.search(r'property int numberOfLevel:\s*0\s*\n',t):
   scripts=list(p.parent.glob('*.js'))
   starts=[re.search(r'function start\([^)]*\)\s*\{(.*?)\n\}',s.read_text(),re.S) for s in scripts]
   if not any(m and re.search(r'items\.numberOfLevel\s*=',m[1]) and m[1].find('items.numberOfLevel =')<m[1].find('Core.getInitialLevel') for m in starts):result.append(relative)
   continue
  if not re.search(r'(?:readonly )?property int numberOfLevel:',t):continue
  if 'onNumberOfLevelChanged:' not in t:continue
  # An explicit initial publication is required; a change handler alone cannot
  # publish a literal initialization reliably in the observed Qt lifecycle.
  handlers=re.findall(r'\bonStart:\s*\{([^}]+)\}',t,re.S)
  if not any(re.search(r'activity\.numberOfLevel\s*=',body) for body in handlers):result.append(relative)
 return sorted(set(result))
if __name__=='__main__':
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--source-root',type=Path,default=ROOT);a=p.parse_args();errors=violations(a.source_root)
 print(json.dumps({'literal_startup_publication_missing':errors}));raise SystemExit(bool(errors))
