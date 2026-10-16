#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Freeze exact Git inputs before native creation games cases; no current-source reads."""
import argparse
import hashlib
import io
import json
from pathlib import Path, PurePosixPath
import subprocess
import tarfile
import tempfile
import os

ROOT = Path(__file__).resolve().parents[2]
ACTIVITIES = ['simplepaint','sketch','drawing_wheels']


def verify_source(destination):
    assert not (destination/'source-manifest.json').is_symlink()
    recorded=json.loads((destination/'source-manifest.json').read_text())
    for relative in recorded['files']:
        path=PurePosixPath(relative)
        assert not path.is_absolute() and '..' not in path.parts and str(path)==relative
    actual={path.relative_to(destination).as_posix() for path in destination.rglob('*') if path.is_file() and path!=destination/'source-manifest.json'}
    assert actual==set(recorded['files']),'Unrecorded or missing frozen input'
    for relative,digest in recorded['files'].items():
        path=destination/relative
        assert not path.is_symlink() and hashlib.sha256(path.read_bytes()).hexdigest()==digest
    return recorded


def freeze(revision):
    revision = subprocess.check_output(['git', '-C', str(ROOT), 'rev-parse', revision+'^{commit}'], text=True).strip()
    destination = ROOT/'build/creation-sources'/revision
    if not destination.exists():
        paths = ['CMakeLists.txt', 'poqm/pt/gcompris_qt.po', 'tools/run-native-qml-case.py', 'tools/native_qml_resources.py', 'tools/run-native-qml-supervised.py', 'tools/pt-pt-audio/rcc_inventory.cpp', 'tools/native_qml_headless.py', 'src/core']
        paths += ['src/activities/'+name for name in ACTIVITIES]
        archive = subprocess.check_output(['git', '-C', str(ROOT), 'archive', revision, '--', *paths])
        destination.parent.mkdir(parents=True,exist_ok=True)
        with tempfile.TemporaryDirectory(prefix='creation source staging ',dir=destination.parent) as temporary:
            stage=Path(temporary)/'source';stage.mkdir()
            with tarfile.open(fileobj=io.BytesIO(archive)) as tree:tree.extractall(stage,filter='data')
            manifest={path.relative_to(stage).as_posix():hashlib.sha256(path.read_bytes()).hexdigest() for path in sorted(stage.rglob('*')) if path.is_file()}
            (stage/'source-manifest.json').write_text(json.dumps({'revision':revision,'files':manifest},indent=2)+'\n')
            verify_source(stage);os.rename(stage,destination)
    recorded=verify_source(destination)
    assert recorded['revision']==revision
    return destination


if __name__ == '__main__':
    if not __debug__:raise SystemExit('Creation validation requires assertions; Python -O is rejected')
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--revision', required=True)
    args = parser.parse_args()
    print(freeze(args.revision))
