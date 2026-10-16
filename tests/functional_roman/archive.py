#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Preserve the three actual application phases in one physical source capsule."""
import hashlib
import io
import json
from pathlib import Path
import subprocess
import zipfile
ROOT=Path(__file__).resolve().parents[2]
PHASES={'baseline':'7a93fa86e','range-reset':'31121a829','final':'5425ec71e'}
EXTRA=['CMakeLists.txt','poqm/pt/gcompris_qt.po','tools/run-native-qml-case.py','tools/run-native-qml-supervised.py','tools/native_qml_resources.py','tools/native_qml_supervision.py']
QML='src/activities/roman_numerals/RomanNumerals.qml'


def blob(revision,path):return subprocess.check_output(['git','show',revision+':'+path],cwd=ROOT)


def create(destination):
    files=sorted(set(subprocess.check_output(['git','ls-tree','-r','--name-only',PHASES['final'],'--','src/core','src/activities/roman_numerals'],cwd=ROOT,text=True).splitlines())|set(EXTRA))
    contents={'final/'+name:blob(PHASES['final'],name) for name in files}
    for phase in ['baseline','range-reset']:contents[phase+'/'+QML]=blob(PHASES[phase],QML)
    for phase in PHASES:
        for name in files:
            if name!=QML:assert blob(PHASES[phase],name)==contents['final/'+name],(phase,name)
    output=io.BytesIO()
    with zipfile.ZipFile(output,'w',compression=zipfile.ZIP_DEFLATED) as archive:
        for name,data in sorted(contents.items()):
            info=zipfile.ZipInfo(name,(1980,1,1,0,0,0));info.compress_type=zipfile.ZIP_DEFLATED;info.external_attr=0o100644<<16;archive.writestr(info,data)
    manifest={'format':1,'phases':PHASES,'files':{name:hashlib.sha256(data).hexdigest() for name,data in sorted(contents.items())},'zip_sha256':hashlib.sha256(output.getvalue()).hexdigest()}
    with (destination/'source-tree.zip').open('xb') as stream:stream.write(output.getvalue())
    with (destination/'source-manifest.json').open('x') as stream:stream.write(json.dumps(manifest,indent=2)+'\n')
    print(len(contents),'source files',manifest['zip_sha256'])


if __name__=='__main__':create(ROOT/'.scratch/pt-pt/functional-roman')
