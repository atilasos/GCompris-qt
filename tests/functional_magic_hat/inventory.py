#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Separate source dataset inventory, never an input to the native solver."""
import argparse
import json
from pathlib import Path
import re

ROOT=Path(__file__).resolve().parents[2]


def inventory(source):
    reachable=1
    for weight in [1,5,10]:
        expanded=0
        for count in range(11):expanded|=reachable<<(count*weight)
        reachable=expanded
    assert reachable==(1<<161)-1
    report={}
    for activity in ['magic-hat-plus','magic-hat-minus']:
        rows=[];datasets=[]
        for path in sorted((source/'src/activities'/activity/'resource').glob('*/Data.qml'),key=lambda path:int(path.parent.name)):
            content=re.sub(r'/\*.*?\*/|//[^\n]*','',path.read_text(),flags=re.S)
            raw=re.search(r'\bdata:\s*(\[.*\])\s*}',content,re.S)[1]
            levels=json.loads(re.sub(r',\s*([\]}])',r'\1',raw))
            for level in levels:
                if level.get('useCoefficients'):
                    assert level['multiplier'] in [1,10,100] and len(level['rowCoefficients'])==3 and sum(level['rowCoefficients'])<=10
                else:
                    assert len(level['minStars'])==len(level['maxStars'])==3 and 1<=level['maxResultPerRow']<=10
                rows.append({'level':len(rows)+1,'dataset':path.parent.name,**level})
            datasets.append({'id':path.parent.name,'count':len(levels)})
        assert len(datasets)==9
        report[activity]={'datasets':datasets,'levels':rows,'representability':{'slots_per_row':10,'answer_base_weights':[1,5,10],'reachable_integer_interval':[0,160],'max_weighted_target_base':100,'colored_result_max_per_row':10}}
    return report


if __name__=='__main__':
    if not __debug__:raise SystemExit('Magic hat validation requires assertions; Python -O is rejected')
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--source-root',type=Path,default=ROOT);args=parser.parse_args();print(json.dumps(inventory(args.source_root),indent=2))
