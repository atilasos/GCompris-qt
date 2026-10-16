#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Freeze exact Git source blobs and the sealed snapshot identity for fraction QA."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess

ROOT=Path(__file__).resolve().parents[2]
PATHS=['CMakeLists.txt','src/core','src/activities/fractions_create','src/activities/fractions_find',
       'src/activities/magic-hat-minus/resource/background.svg','poqm/pt/gcompris_qt.po',
       'tools/run-native-qml-case.py','tools/native_qml_resources.py','tests/functional_fractions']


def sha(data):return hashlib.sha256(data).hexdigest()


def verify(directory):
    manifest=json.loads((directory/'manifest.json').read_text())
    assert manifest['version']==1 and len(manifest['source_commit'])==40 and manifest['files']
    expected=set(manifest['files'])|{'snapshot-manifest.json'}
    actual={path.relative_to(directory/'files').as_posix() for path in (directory/'files').rglob('*') if path.is_file()}
    assert actual==set(manifest['files'])
    for relative,identity in manifest['files'].items():
        path=directory/'files'/relative
        assert not path.is_symlink() and path.is_file()
        assert sha(path.read_bytes())==identity['sha256'],relative
    snapshot=(directory/'snapshot-manifest.json').read_bytes()
    assert sha(snapshot)==manifest['snapshot_manifest_sha256']
    assert len(json.loads(snapshot)['files'])==269
    return manifest


def freeze(commit,snapshot,directory):
    assert not directory.exists()
    commit=subprocess.check_output(['git','rev-parse',commit],cwd=ROOT,text=True).strip()
    names=subprocess.check_output(['git','ls-tree','-r','--name-only',commit,'--',*PATHS],cwd=ROOT,text=True).splitlines()
    assert names
    directory.mkdir(parents=True)
    files={}
    for name in names:
        data=subprocess.check_output(['git','show',commit+':'+name],cwd=ROOT)
        assert data==(ROOT/name).read_bytes(),('Source differs from frozen commit',name)
        path=directory/'files'/name;path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(data)
        files[name]={'sha256':sha(data),'bytes':len(data)}
    data=(snapshot/'manifest.json').read_bytes();assert len(json.loads(data)['files'])==269
    (directory/'snapshot-manifest.json').write_bytes(data)
    manifest={'version':1,'source_commit':commit,'files':files,'snapshot_manifest_sha256':sha(data)}
    (directory/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    verify(directory)
    return manifest


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--commit',default='HEAD');parser.add_argument('--snapshot',type=Path,required=True);parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args();report=freeze(args.commit,args.snapshot,args.output)
    print(json.dumps({'source_commit':report['source_commit'],'files':len(report['files']),'snapshot_files':269}))
