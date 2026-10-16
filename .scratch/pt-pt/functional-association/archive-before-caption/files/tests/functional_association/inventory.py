#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Inventory authored resources while deliberately omitting solution coordinates."""
import json
from pathlib import Path
import re
import subprocess
ROOT=Path(__file__).resolve().parents[2]
NAMES=('babymatch','babyshapes','imagename')


def collect(root=ROOT):
    boards=[]
    for activity in NAMES:
        for path in sorted((root/'src/activities'/activity/'resource/board').glob('board*.qml')):
            text=re.sub(r'/\*.*?\*/','',path.read_text(),flags=re.S)
            expression=text[text.index('[',text.index('property var levels')):text.rindex(']')+1]
            command="const vm=require('vm');process.stdout.write(JSON.stringify(vm.runInNewContext(process.argv[1],{qsTr:s=>s})));"
            values=json.loads(subprocess.check_output(['node','-e',command,expression],text=True))
            level,sub=map(int,re.search(r'board(\d+)_(\d+)',path.stem).groups())
            assert all(entry.get('type') in (None,'SHAPE_BACKGROUND','DisplayText','SHAPE_BACKGROUND_IMAGE') for entry in values)
            boards.append({'activity':activity,'level':level,'sublevel':sub,'source':str(path.relative_to(root)),
                           'glow':not bool(re.search(r'property bool glow\s*:\s*false',text)),
                           'parts':[{key:value for key,value in entry.items() if key in ('pixmapfile','text','type')} for entry in values]})
    assert {name:sum(b['activity']==name for b in boards) for name in NAMES}=={'babymatch':7,'babyshapes':11,'imagename':7}
    return boards


if __name__=='__main__':print(json.dumps(collect(),ensure_ascii=False,indent=2))
