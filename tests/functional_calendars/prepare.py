#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
import argparse
import json
from pathlib import Path
from data import inventory,ACTIVITIES

if __name__=='__main__':
 p=argparse.ArgumentParser()
 p.add_argument('activity',choices=ACTIVITIES)
 p.add_argument('--first',type=int,default=1)
 p.add_argument('--count',type=int,default=1)
 p.add_argument('--output',type=Path,required=True)
 a=p.parse_args()
 levels=inventory()[a.activity]['levels']
 assert a.first>=1 and a.count>=1 and a.first+a.count-1<=len(levels)
 source=Path(__file__).with_name('gameplay.qml.in').read_text().replace('__DATA__',json.dumps(levels,ensure_ascii=False)).replace('__FIRST__',str(a.first)).replace('__COUNT__',str(a.count))
 with a.output.open('x') as stream:stream.write(source)
