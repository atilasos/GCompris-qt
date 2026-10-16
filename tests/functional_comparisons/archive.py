#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Freeze comparison sources from immutable Git blobs, without runtime paths."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess

ROOT=Path(__file__).resolve().parents[2]
SOURCE='e38441ab1'
RED='d76b8408a'
COMPARATOR='7e334d5ee'
BASE='.scratch/pt-pt/functional-comparisons'
CASES=['comparator-complete','adjacent-automatic-complete','adjacent-manual-complete','comparator-controls','adjacent-controls','comparator-resources','adjacent_numbers-resources','adjacent-level-contract']
PATHS=['CMakeLists.txt','src/core','src/activities/comparator','src/activities/adjacent_numbers',
       'src/activities/chess/resource/background-wood.svg','src/activities/path_encoding/resource/arrow.svg',
       'poqm/pt/gcompris_qt.po','tools/run-native-qml-case.py','tools/run-native-qml-supervised.py',
       'tools/native_qml_resources.py','tests/functional_comparisons',BASE+'/resource-snapshot.json']+[BASE+'/'+name+'.qml' for name in CASES]


def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()


def git(*args):return subprocess.check_output(['git',*args],cwd=ROOT)


def freeze(output):
    if output.exists():raise ValueError('Use a new output directory')
    commit=git('rev-parse',SOURCE).decode().strip();red=git('rev-parse',RED).decode().strip()
    names=git('ls-tree','-r','--name-only',commit,'--',*PATHS).decode().splitlines();assert names
    output.mkdir(parents=True);files={}
    for name in names:
        data=git('show',commit+':'+name);path=output/'files'/name;path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(data)
        files[name]={'sha256':sha(path),'bytes':len(data)}
    relative='src/activities/adjacent_numbers/Adjacent_numbers.qml';path=output/'red'/relative;path.parent.mkdir(parents=True);path.write_bytes(git('show',red+':'+relative))
    assert git('show',commit+':src/activities/comparator/Comparator.qml')==git('show',COMPARATOR+':src/activities/comparator/Comparator.qml')
    manifest={'version':1,'source_commit':commit,'red_commit':red,'files':files,'red':{relative:{'sha256':sha(path),'bytes':path.stat().st_size}}}
    (output/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');verify(output);return manifest


def verify(output):
    manifest=json.loads((output/'manifest.json').read_text());assert manifest['version']==1
    for directory,key in [('files','files'),('red','red')]:
        actual={path.relative_to(output/directory).as_posix() for path in (output/directory).rglob('*') if path.is_file()}
        assert actual==set(manifest[key])
        for relative,identity in manifest[key].items():
            path=output/directory/relative;assert path.is_file() and not path.is_symlink() and sha(path)==identity['sha256'] and path.stat().st_size==identity['bytes']
    return manifest


SELECTED=['comparator-complete','adjacent-automatic-complete','adjacent-manual-complete-rerun',
          'comparator-controls','adjacent-controls','comparator-resources','adjacent_numbers-resources',
          'adjacent-contract-red','adjacent-contract-green2']


def capture(commit,output):
    if output.exists():raise ValueError('Use a new capture manifest')
    commit=git('rev-parse',commit).decode().strip()
    paths=[BASE+'/'+name for name in SELECTED]+[BASE+'/audio-decode.json']
    names=git('ls-tree','-r','--name-only',commit,'--',*paths).decode().splitlines()
    files={}
    for name in names:
        relative=name.removeprefix(BASE+'/');data=git('show',commit+':'+name)
        assert (output.parent/relative).read_bytes()==data,relative
        files[relative]={'sha256':hashlib.sha256(data).hexdigest(),'bytes':len(data)}
    assert 'audio-decode.json' in files
    assert all(name+'/result.json' in files and name+'/launcher-status.json' in files and name+'/tool-status.json' in files for name in SELECTED)
    output.write_text(json.dumps({'version':1,'capture_commit':commit,'files':files},indent=2)+'\n')
    return {'capture_commit':commit,'files':len(files),'sha256':sha(output)}


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True);parser.add_argument('--capture');args=parser.parse_args()
    if args.capture:
        print(json.dumps(capture(args.capture,args.output)));raise SystemExit(0)
    value=freeze(args.output);print(json.dumps({'source':value['source_commit'],'files':len(value['files']),'manifest_sha256':sha(args.output/'manifest.json')}))
