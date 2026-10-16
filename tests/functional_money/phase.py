#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Freeze exact Git inputs before native money cases; no current-source reads."""
import argparse
import hashlib
import io
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[2]
ACTIVITIES = ['money', 'money_cents', 'money_back', 'money_back_cents']


def freeze(revision):
    revision = subprocess.check_output(['git', '-C', str(ROOT), 'rev-parse', revision+'^{commit}'], text=True).strip()
    destination = ROOT/'build/functional-money/sources'/revision
    if not destination.exists():
        paths = ['CMakeLists.txt', 'poqm/pt/gcompris_qt.po', 'tools/run-native-qml-case.py', 'tools/native_qml_resources.py', 'src/core']
        paths += ['src/activities/'+name for name in ACTIVITIES]
        archive = subprocess.check_output(['git', '-C', str(ROOT), 'archive', revision, '--', *paths])
        destination.mkdir(parents=True)
        with tarfile.open(fileobj=io.BytesIO(archive)) as tree:
            tree.extractall(destination, filter='data')
        manifest = {str(path.relative_to(destination)): hashlib.sha256(path.read_bytes()).hexdigest()
                    for path in sorted(destination.rglob('*')) if path.is_file()}
        (destination/'source-manifest.json').write_text(json.dumps({'revision': revision, 'files': manifest}, indent=2)+'\n')
    recorded = json.loads((destination/'source-manifest.json').read_text())
    assert recorded['revision'] == revision
    assert all(hashlib.sha256((destination/path).read_bytes()).hexdigest() == digest for path, digest in recorded['files'].items())
    return destination


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--revision', required=True)
    args = parser.parse_args()
    print(freeze(args.revision))
