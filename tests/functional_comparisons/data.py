#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Inventory every authored data object, independently of the game engines."""
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT=Path(__file__).resolve().parents[2]
ACTIVITIES=['comparator','adjacent_numbers']


def extract(text):
    text=re.sub(r'/\*.*?\*/','',text,flags=re.S)
    text=re.sub(r'//[^\n]*','',text)
    match=re.search(r'\bdata\s*:\s*\[',text);assert match
    start=match.end()-1;depth=0
    for end in range(start,len(text)):
        depth+=(text[end]=='[')-(text[end]==']')
        if depth==0:break
    code="const vm=require('vm');process.stdout.write(JSON.stringify(vm.runInNewContext(process.argv[1])));"
    return json.loads(subprocess.check_output(['node','-e',code,text[start:end+1]],text=True))


def inventory():
    result={}
    for activity in ACTIVITIES:
        levels=[]
        files=sorted((ROOT/'src/activities'/activity/'resource').glob('*/Data.qml'),key=lambda p:int(p.parent.name))
        for file in files:
            data=extract(file.read_text())
            for entry in data:
                if activity=='comparator':
                    assert entry['random'] is True
                    assert entry['numberOfSublevels']>0 and entry['numberOfEquations']>0 and entry['minValue']<entry['maxValue']
                    assert entry.get('precision',1) in [1,0.1,0.01,0.001]
                    puzzles=entry['numberOfSublevels']
                else:
                    assert entry['step']==1 and entry['numberShown']>=2
                    assert entry['lowerBound']<entry['upperBound']
                    assert 0<len(entry['indicesToGuess'])<entry['numberShown']
                    assert len(set(entry['indicesToGuess']))==len(entry['indicesToGuess']) and all(0<=i<entry['numberShown'] for i in entry['indicesToGuess'])
                    assert entry['numberPropositions']>=len(entry['indicesToGuess'])
                    puzzles=entry['numberRandomLevel'] if entry['randomSubLevels'] else len(entry['fixedLevels'])
                levels.append({'level':len(levels)+1,'source':str(file.relative_to(ROOT)),'source_sha256':hashlib.sha256(file.read_bytes()).hexdigest(),'configuration':entry,'puzzles':puzzles})
        result[activity]={'datasets':len(files),'levels':levels,'puzzles':sum(level['puzzles'] for level in levels)}
    return result


if __name__=='__main__':print(json.dumps(inventory(),indent=2))
