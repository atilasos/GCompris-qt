#!/usr/bin/env python3
# SPDX-FileCopyrightText: NONE
# SPDX-License-Identifier: CC0-1.0
"""Inspect actual NSIS bytes and Qt resources; this does not execute Windows."""
import argparse
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
GAMES = ('dominorio', 'gatos_caes', 'faisca', 'quelhas', 'atari_go', 'produto', 'y', 'nex')
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--installer', type=Path, required=True)
parser.add_argument('--metadata', type=Path, required=True)
parser.add_argument('--output', type=Path, required=True)
parser.add_argument('--inventory', type=Path, required=True)
parser.add_argument('--sevenzip', type=Path, required=True)
args = parser.parse_args()
metadata = json.loads(args.metadata.read_text())
source = metadata['source']
if not re.fullmatch(r'[a-f0-9]{40}', source):
    raise ValueError('Invalid source revision')
with args.installer.open('rb') as stream:
    digest = hashlib.file_digest(stream, 'sha256').hexdigest()
if digest != metadata['sha256'] or args.installer.stat().st_size != metadata['bytes']:
    raise ValueError('Installer bytes differ from release metadata')
args.output.mkdir(parents=True, exist_ok=False)

def source_bytes(path):
    return subprocess.check_output(['git', 'show', source + ':' + path], cwd=ROOT)

manifest = [line.strip() for line in source_bytes('src/activities/activities.txt').decode().splitlines()
            if line.strip() and not line.lstrip().startswith('#')]
listing = subprocess.check_output([str(args.sevenzip), 'l', '-slt', str(args.installer)], text=True)
(args.output / 'archive-list.txt').write_text(listing)
paths = [line[7:] for line in listing.splitlines() if line.startswith('Path = ')]
missing = [name for name in manifest if 'share/GCompris/rcc/' + name + '.rcc' not in paths]
if missing or len(manifest) != metadata['activities']:
    raise ValueError('Actual installer activity inventory differs: ' + repr(missing))
selected = ['source-commit.txt', 'share/GCompris/rcc/core.rcc']
selected += ['share/GCompris/rcc/' + name + '.rcc' for name in GAMES + ('grammar_classes', 'grammar_analysis')]
with (args.output / 'extraction.log').open('w') as log:
    subprocess.run([str(args.sevenzip), 'x', '-y', '-o' + str(args.output / 'extracted'),
                    str(args.installer), *selected], check=True, stdout=log, stderr=subprocess.STDOUT)
extracted = args.output / 'extracted'
if (extracted / 'source-commit.txt').read_text(encoding='utf-8-sig').strip() != source:
    raise ValueError('Packaged source-commit.txt differs')
exports = args.output / 'exports'
verified = []
for activity in ('core',) + GAMES + ('grammar_classes', 'grammar_analysis'):
    destination = exports / activity
    raw = subprocess.check_output([str(args.inventory), str(extracted / 'share/GCompris/rcc' / (activity + '.rcc')), str(destination)])
    (args.output / (activity + '-inventory.json')).write_bytes(raw)
    if activity == 'core':
        files = ['src/core/' + name + '.qml' for name in ('BoardGameLayout', 'BoardGameButton', 'BoardGameText')]
    else:
        files = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', source, '--', 'src/activities/' + activity], cwd=ROOT, text=True).splitlines()
        files = [file for file in files if Path(file).suffix in ('.qml', '.mjs', '.js', '.svg')]
        if activity.startswith('grammar_'):
            files.append('src/activities/' + activity + '/resource/' + activity + '-pt.json')
    for file in files:
        actual = (destination / 'gcompris' / file).read_bytes()
        expected = source_bytes(file)
        if file.endswith('.json'):
            equal = json.loads(actual) == json.loads(expected)
        else:
            equal = actual.replace(b'\r\n', b'\n') == expected.replace(b'\r\n', b'\n')
        if not equal:
            raise ValueError('Actual packaged resource differs from source: ' + file)
        verified.append(file)
levels = {}
for activity in ('grammar_classes', 'grammar_analysis'):
    resource = exports / activity / 'gcompris/src/activities' / activity / 'resource' / (activity + '-pt.json')
    levels[activity] = len(json.loads(resource.read_text())['levels'])
result = {'passed': True, 'run': metadata['run'], 'source': source, 'sha256': digest,
          'activities_present': len(manifest), 'verified_source_resources': verified,
          'grammar_levels': levels,
          'scope': 'Actual NSIS extraction and Qt resource comparison on Linux; Windows execution is separate CI evidence'}
(args.output / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result, indent=2))
