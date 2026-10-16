#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Create a deterministic physical capsule from an immutable Git revision."""
import hashlib
import io
import json
from pathlib import Path
import subprocess
import zipfile
ROOT=Path(__file__).resolve().parents[2]
SOURCE='fec529d1a'
EXTRA=['CMakeLists.txt','poqm/pt/gcompris_qt.po','tools/run-native-qml-case.py','tools/run-native-qml-supervised.py','tools/native_qml_resources.py','tools/native_qml_supervision.py']


def git(path):return subprocess.check_output(['git','show',SOURCE+':'+path],cwd=ROOT)


def create(destination):
    files=sorted(set(subprocess.check_output(['git','ls-tree','-r','--name-only',SOURCE,'--','src/core','src/activities/clockgame'],cwd=ROOT,text=True).splitlines())|set(EXTRA))
    content=io.BytesIO();hashes={}
    with zipfile.ZipFile(content,'w',compression=zipfile.ZIP_DEFLATED) as archive:
        for name in files:
            data=git(name);hashes[name]=hashlib.sha256(data).hexdigest();info=zipfile.ZipInfo(name,(1980,1,1,0,0,0));info.compress_type=zipfile.ZIP_DEFLATED;info.external_attr=0o100644<<16;archive.writestr(info,data)
    manifest={'format':1,'revision':SOURCE,'files':hashes,'zip_sha256':hashlib.sha256(content.getvalue()).hexdigest()}
    with (destination/'source-tree.zip').open('xb') as stream:stream.write(content.getvalue())
    with (destination/'source-manifest.json').open('x') as stream:stream.write(json.dumps(manifest,indent=2)+'\n')
    print(len(files),'source files',manifest['zip_sha256'])


if __name__=='__main__':create(ROOT/'.scratch/pt-pt/functional-clock')
