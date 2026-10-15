#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Read real PT RCC bytes with Qt and cross-check audio resource references.

This verifies distribution coverage and optionally local decoding. It does not
certify pronunciation, an activity's audio routing or Windows playback.
"""
import argparse
from collections import Counter
import concurrent.futures
import hashlib
import json
from pathlib import Path
import re
import shlex
import shutil
import string
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
PREFIX = ':/gcompris/data/voices-ogg/pt/'
LITERAL = re.compile(r'voices-\$CA/\$LOCALE/([\w/-]+\.\$CA)')


def sound(character):
    return 'alphabet/' + ''.join(f'U{ord(c):04X}' for c in character.lower()) + '.ogg'


def references(root, words_manifest=None):
    activity_list = (root / 'src/activities/activities.txt').read_text()
    activities = [line.split('#', 1)[0].strip() for line in activity_list.splitlines()]
    activities = [name for name in activities if name]
    expected = {
        'introductions': {f'intro/{name}.ogg' for name in activities},
        'alphabet': {sound(c) for c in string.ascii_lowercase},
        'digits_and_numbers': {sound(c) for c in string.digits} | {f'alphabet/{n}.ogg' for n in range(10, 21)},
        'portuguese_keyboard': {sound(c) for c in 'àáâãéêíóôõúç'},
        'literal_references': set(),
    }
    consumers = {}
    for path in sorted((root / 'src/activities').rglob('*')):
        if path.suffix not in ('.js', '.qml', '.json'):
            continue
        content = path.read_text(encoding='utf-8')
        matches = set(LITERAL.findall(content))
        if 'voices-' in content or 'audioVoices' in content:
            consumers[str(path.relative_to(root))] = sorted(m.replace('$CA', 'ogg') for m in matches)
        expected['literal_references'].update(m.replace('$CA', 'ogg') for m in matches)
    translations = json.loads((root / 'src/activities/lang/resource/content-pt.json').read_text())
    manifest_voices = set()
    words_manifest = words_manifest or root / 'src/activities/lang/resource/words.json'
    if words_manifest:
        def walk(value):
            if isinstance(value, dict):
                voice = value.get('voice', '')
                if isinstance(voice, str) and voice.startswith('voices-$CA/$LOCALE/'):
                    manifest_voices.add(voice.removeprefix('voices-$CA/$LOCALE/').replace('$CA', 'ogg'))
                for child in value.values():
                    walk(child)
            elif isinstance(value, list):
                for child in value:
                    walk(child)
        walk(json.loads(words_manifest.read_text()))
        # lang_api.js filters entries without translated text before playback.
        expected['active_wordset'] = {name for name in manifest_voices if translations.get(name.rsplit('/', 1)[-1])}
    return expected, consumers


def decode_file(path):
    try:
        result = subprocess.run(['gst-launch-1.0', '-q', 'filesrc', f'location={path}',
                                 '!', 'decodebin', '!', 'audioconvert', '!', 'fakesink'],
                                capture_output=True, text=True, timeout=20)
        return None if result.returncode == 0 else result.stderr.strip()
    except subprocess.TimeoutExpired:
        return 'decoder timeout after 20 seconds'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--rcc', type=Path, required=True, help='actual voices-pt-*.rcc to inspect')
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--root', type=Path, default=ROOT)
    parser.add_argument('--export-dir', type=Path, help='optional directory for exported RCC assets')
    parser.add_argument('--words-manifest', type=Path, help='words.json exported from the distributed words RCC')
    parser.add_argument('--decode', action='store_true', help='decode every exported voice offline with GStreamer')
    args = parser.parse_args()
    if args.decode and not shutil.which('gst-launch-1.0'):
        parser.error('--decode requires gst-launch-1.0')
    with tempfile.TemporaryDirectory(prefix='gcompris-audio-') as directory:
        temporary = Path(directory)
        utility = temporary / 'rcc-inventory'
        flags = shlex.split(subprocess.check_output(['pkg-config', '--cflags', '--libs', 'Qt6Core'], text=True))
        subprocess.run(['c++', '-std=c++17', '-fPIC', str(ROOT / 'tools/pt-pt-audio/rcc_inventory.cpp'),
                        *flags, '-o', str(utility)], check=True)
        exported = args.export_dir.resolve() if args.export_dir else temporary / 'assets'
        files = json.loads(subprocess.check_output([str(utility), str(args.rcc.resolve()), str(exported)], text=True))
        voices = {row['path'].removeprefix(PREFIX): row for row in files if row['path'].startswith(PREFIX)}
        if not voices:
            parser.error(f'RCC contains no resources under {PREFIX}')
        expected, consumers = references(args.root, args.words_manifest)
        decode = {'status': 'not-run'}
        if args.decode:
            paths = sorted(voices)
            with concurrent.futures.ThreadPoolExecutor(max_workers=4) as executor:
                errors = list(executor.map(decode_file, (exported / row['path'][2:] for name, row in sorted(voices.items()))))
            failures = {name: error for name, error in zip(paths, errors) if error}
            decode = {'status': 'failed' if failures else 'passed', 'tested': len(paths), 'failures': failures,
                      'backend': 'GStreamer decodebin/audioconvert/fakesink; no network or sound output'}
        report = {
            'rcc': args.rcc.name, 'rcc_sha256': hashlib.sha256(args.rcc.read_bytes()).hexdigest(),
            'resource_files': len(files), 'pt_voice_files': len(voices),
            'groups': dict(sorted(Counter(name.split('/')[0] for name in voices).items())),
            'invalid_ogg': sorted(name for name, row in voices.items() if not row['ogg']),
            'expected_counts': {key: len(value) for key, value in expected.items()},
            'missing': {key: sorted(value - voices.keys()) for key, value in expected.items()},
            'direct_source_consumers': consumers,
            'scope': 'Direct source references plus alphabet, Portuguese keyboard, numbers, introductions and translated word keys; dynamic geography and inherited activity routing require runtime validation.',
            'decode': decode, 'pronunciation': 'pending-human-review', 'windows_playback': 'not-tested',
            'assets': [voices[name] for name in sorted(voices)],
        }
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
        print(json.dumps({'pt_voice_files': len(voices), 'missing_counts': {key: len(value) for key, value in report['missing'].items()}, 'decode': decode}, ensure_ascii=False))


if __name__ == '__main__':
    main()
