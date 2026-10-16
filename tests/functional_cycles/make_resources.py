#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Build image cases from the real canonical Qt inventory, excluding source artwork."""
import argparse,json
from pathlib import Path
ROOT=Path(__file__).resolve().parent
ACTIVITIES=['canal_lock','watercycle','renewable_energy']
def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--inventory',type=Path,required=True);parser.add_argument('--output',type=Path,required=True);args=parser.parse_args()
 if args.output.exists():parser.error('Case directory must be new')
 inventory=json.loads(args.inventory.read_text());result={}
 def images(name):return [row['path'] for row in inventory['rccs'][name]['files'] if Path(row['path']).suffix.lower() in ['.svg','.png','.jpg','.jpeg','.webp']]
 extras=[row['path'] for row in inventory['rccs']['core']['files'] if any(part in row['path'] for part in ['/bonus/flower_good.svg','/bonus/smiley_good.svg','bar_help.svg','bar_home.svg','bar_reload.svg'])]
 args.output.mkdir(parents=True)
 for activity in ACTIVITIES:
  paths=images(activity)
  if activity in ['watercycle','renewable_energy']:paths+=[':/gcompris/src/activities/chess/resource/background-wood.svg']
  if activity=='renewable_energy':paths+=images('watercycle')
  paths=list(dict.fromkeys([*paths,*extras]));result[activity]=paths
  (args.output/(activity+'.qml')).write_text((ROOT/'resources.qml').read_text().replace('__IMAGES__',json.dumps(paths)))
 (args.output/'images.json').write_text(json.dumps(result,indent=2)+'\n')
if __name__=='__main__':main()
