#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Compare real upstream/completed RCC resources and the two displayed labels."""
import argparse
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'tools/pt-pt-audio'))
import complete_voices as voices


def verify(directory, inventory_tool, lang_rcc):
    manifest = json.loads((ROOT / 'resources/pt-pt-voices/manifest.json').read_text())
    original = directory / manifest['source_rcc']
    completed = directory / voices.OUTPUT
    if voices.digest(original) != manifest['source_rcc_sha256']:
        raise ValueError('Original upstream RCC changed')
    lock = json.loads((ROOT / 'tools/windows/assets-lock.json').read_text())['pt_voice_completion']
    metadata = json.loads((directory / 'completion.json').read_text())
    if any(metadata.get(key) != value for key, value in lock.items()):
        raise ValueError('Completion differs from fixed distribution policy')
    for row in lock['files'] + lock['provenance_files']:
        path = directory / row['path']
        if path.stat().st_size != row['bytes'] or voices.digest(path) != row['sha256']:
            raise ValueError('Physical distribution resource changed: ' + row['path'])
    old = {row['path']: row['sha256'] for row in voices.inventory(inventory_tool, original)}
    new = {row['path']: row['sha256'] for row in voices.inventory(inventory_tool, completed)}
    expected = dict(old)
    for row in manifest['recordings']:
        expected[voices.PREFIX + row['file']] = row['sha256']
    for row in voices.approved_replacements(ROOT / 'resources/pt-pt-voices', old):
        expected[voices.PREFIX + row['file']] = row['sha256']
    if len(old) != 1578 or len(new) != 1610 or new != expected:
        raise ValueError('Resource set differs from 1576 intact originals + 32 additions + 2 substitutions')
    changed = sorted(key for key in old if new.get(key) != old[key])
    if changed != sorted(voices.PREFIX + name for name in voices.APPROVED_LEGACY):
        raise ValueError('Unexpected original substitutions')
    rows = {row['path']: row['sha256'] for row in voices.inventory(inventory_tool, lang_rcc)}
    key = ':/gcompris/src/activities/lang/resource/content-pt.json'
    source = ROOT / 'src/activities/lang/resource/content-pt.json'
    if rows.get(key) != voices.digest(source):
        raise ValueError('Packaged Portuguese labels differ from source')
    labels = json.loads(source.read_text())
    if labels['fawn.ogg'] != 'cervato' or labels['tick.ogg'] != 'carraça':
        raise ValueError('Approved Portuguese labels missing')
    return {'passed': True, 'original_files': len(old), 'total_files': len(new),
            'intact_originals': len(old) - len(changed), 'added_files': len(new) - len(old),
            'changed_originals': changed, 'rcc_sha256': voices.digest(completed),
            'lang_rcc_sha256': voices.digest(lang_rcc),
            'scope': 'Physical resources and exact labels; no pronunciation or Windows execution claim'}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--voices-dir', type=Path, required=True)
    parser.add_argument('--inventory-tool', type=Path, required=True)
    parser.add_argument('--lang-rcc', type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps(verify(args.voices_dir, args.inventory_tool, args.lang_rcc), ensure_ascii=False, indent=2))
