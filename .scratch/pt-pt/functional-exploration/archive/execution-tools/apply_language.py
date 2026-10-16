#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Apply/check reviewed task-84 PT strings, without altering source questions."""
import argparse,ast,json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
def strings(block):
 fields={};key=None
 for line in block.splitlines():
  m=re.match(r'(msgid|msgstr|msgctxt) (".*")$',line)
  if m:key=m[1];fields[key]=ast.literal_eval(m[2])
  elif line.startswith('"') and key:fields[key]+=ast.literal_eval(line)
 return fields

def apply(write=False):
 review=json.loads(Path(__file__).with_name('language-review.json').read_text());changes={}
 for row in review:
  for key in ['title','description']:
   old=row['old_'+key];new=row[key]
   if old!=new:
    if old in changes and changes[old]!=new:raise ValueError('Conflicting reviewed text')
    changes[old]=new
 for name in ['question-review.json','help-review.json']:
  for row in json.loads(Path(__file__).with_name(name).read_text()):changes[row['old']]=row['new']
 p=ROOT/'poqm/pt/gcompris_qt.po';blocks=re.split(r'\n\s*\n',p.read_text());seen={old:0 for old in changes};remaining=[];updated=[]
 for block in blocks:
  fields=strings(block);text=fields.get('msgstr','');relevant=any('activities/'+name+'/' in block for name in ['explore_farm_animals','explore_world_animals','explore_world_music','explore_monuments'])
  if relevant:
   for old,new in changes.items():
    if text==old or text==new:
     seen[old]+=1
     if text==old:
      remaining.append(old);block=re.sub(r'^msgstr ".*"(?:\n".*")*','msgstr '+json.dumps(new,ensure_ascii=False),block,flags=re.M)
     break
  updated.append(block)
 if any(value!=1 for value in seen.values()):raise ValueError('Expected one exploration catalogue entry per review: '+repr({k:v for k,v in seen.items() if v!=1}))
 if write and remaining:p.write_text('\n\n'.join(updated)+'\n')
 if remaining and not write:raise ValueError(str(len(remaining))+' reviewed translations remain unapplied')
 return {'reviewed_messages':len(changes),'changed':len(remaining) if write else 0}
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--apply',action='store_true');a=p.parse_args();print(json.dumps(apply(a.apply)))
