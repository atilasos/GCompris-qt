#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Capture actual Qt RCC identities and compare copied audio resources."""
import argparse
import hashlib
import json
from pathlib import Path
import shlex
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[2]


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def capture(snapshot, evidence):
    executable = ROOT/'build/functional-colors/rcc-inventory'
    executable.parent.mkdir(parents=True, exist_ok=True)
    flags = shlex.split(subprocess.check_output(['pkg-config', '--cflags', '--libs', 'Qt6Core'], text=True))
    subprocess.run(['g++', str(ROOT/'tools/pt-pt-audio/rcc_inventory.cpp'), '-o', str(executable), *flags], check=True)
    identity = {}
    for name in ['core', 'colors', 'advanced_colors', 'color_mix', 'color_mix_light']:
        resource = snapshot/'share/gcompris-qt/rcc'/(name+'.rcc')
        rows = json.loads(subprocess.check_output([str(executable), str(resource)], text=True))
        for row in rows:
            assert row['sha256'] == sha(ROOT/row['path'].removeprefix(':/gcompris/')), row['path']
        identity[name] = {'rcc_sha256': sha(resource), 'files': rows}
    (evidence/'source-identity.json').write_text(json.dumps(identity, indent=2)+'\n')
    voices = {}
    for resource in sorted((snapshot/'share/gcompris-qt/rcc/data3/voices-ogg').glob('voices-pt-*.rcc')):
        rows = json.loads(subprocess.check_output([str(executable), str(resource)], text=True))
        voices.update({row['path']: row for row in rows})
    copied = {}
    for result in sorted(evidence.glob('*/result.json')):
        value = json.loads(result.read_text())
        if not value['passed']:
            continue
        for route, name in value['case_result'].get('copiedRoutes', {}).items():
            row = voices[route.removeprefix('qrc')]
            assert row['ogg'] and sha(result.parent/name) == row['sha256']
            copied[route] = {'sha256': row['sha256'], 'bytes': row['bytes']}
    (evidence/'audio-identity.json').write_text(json.dumps(copied, indent=2)+'\n')
    shutil.copyfile(snapshot/'manifest.json', evidence/'captured-resource-manifest.json')
    return {'source_files': sum(len(value['files']) for value in identity.values()), 'copied_voice_routes': len(copied)}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--snapshot', type=Path, required=True)
    parser.add_argument('--evidence', type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps(capture(args.snapshot.resolve(), args.evidence.resolve())))
