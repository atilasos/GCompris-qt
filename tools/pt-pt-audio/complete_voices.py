#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Build a complete offline PT voices RCC without replacing original recordings.

Uses the pinned upstream RCC plus checked-in additions. Requires a Qt inventory
executable built from rcc_inventory.cpp and Qt's rcc tool. No synthesis/network.
"""
import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import shutil
import subprocess
import tempfile
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]
PREFIX = ':/gcompris/data/voices-ogg/pt/'
OUTPUT = 'voices-pt-2026-10-15-00-00-00.rcc'


def digest(path, algorithm='sha256'):
    return hashlib.new(algorithm, path.read_bytes()).hexdigest()


def inventory(utility, rcc, export=None):
    command = [str(utility), str(rcc)]
    if export is not None:
        command.append(str(export))
    return json.loads(subprocess.check_output(command, text=True))


def complete(voices_dir, additions, utility, rcc_tool):
    manifest = json.loads((additions / 'manifest.json').read_text(encoding='utf-8'))
    original = voices_dir / manifest['source_rcc']
    if digest(original) != manifest['source_rcc_sha256']:
        raise ValueError('Original voices RCC differs from pinned source; refusing to replace recordings')
    contents = voices_dir / 'Contents'
    original_contents = contents.read_text(encoding='utf-8')
    with tempfile.TemporaryDirectory(prefix='complete-pt-voices-', dir=voices_dir) as directory:
        temporary = Path(directory)
        exported = temporary / 'original'
        source = inventory(utility, original, exported)
        if len(source) != manifest['source_files']:
            raise ValueError('Original resource count differs from pinned source')
        expected = {row['path']: row['sha256'] for row in source}
        inputs = {row['path']: exported / row['path'][2:] for row in source}
        for row in manifest['recordings']:
            name = PurePosixPath(row['file'])
            if name.is_absolute() or '..' in name.parts or name.suffix != '.ogg':
                raise ValueError(f'Invalid voice resource path: {name}')
            path = additions / name
            key = PREFIX + name.as_posix()
            if key in expected:
                raise ValueError(f'Addition would overwrite original recording: {key}')
            if path.stat().st_size != row['bytes'] or digest(path) != row['sha256'] or not path.read_bytes().startswith(b'OggS'):
                raise ValueError(f'Addition recording is missing, damaged or changed: {name}')
            inputs[key] = path.resolve()
            expected[key] = row['sha256']
        qrc = ET.Element('RCC')
        resource = ET.SubElement(qrc, 'qresource', prefix='/')
        for name, path in sorted(inputs.items()):
            ET.SubElement(resource, 'file', alias=name[2:]).text = str(path)
        ET.ElementTree(qrc).write(temporary / 'voices.qrc', encoding='utf-8', xml_declaration=True)
        completed = temporary / OUTPUT
        # Version 1 avoids filesystem timestamps in the RCC, making retries stable.
        subprocess.run([str(rcc_tool), '--binary', '--no-compress', '--format-version', '1',
                        str(temporary / 'voices.qrc'), '-o', str(completed)], check=True)
        actual = {row['path']: row['sha256'] for row in inventory(utility, completed)}
        if actual != expected:
            raise ValueError('Compiled RCC changes an original recording or misses an addition')
        # Replace only the pt Contents line. Other languages remain selectable.
        lines = [line for line in original_contents.splitlines()
                 if not (len(line.split()) == 2 and line.split()[1].startswith('voices-pt-'))]
        lines.append(f'{digest(completed, "md5")}  {OUTPUT}')
        (temporary / 'Contents').write_text('\n'.join(lines) + '\n', encoding='utf-8')
        # Publish the RCC first, then its index. A retry always starts from the
        # pinned original and converges to the same bytes and registration entry.
        completed.replace(voices_dir / OUTPUT)
        (temporary / 'Contents').replace(contents)
    result = {'format': 1, 'source_rcc': original.name, 'source_rcc_sha256': digest(original),
              'original_files': len(source), 'added_files': len(manifest['recordings']),
              'total_files': len(expected), 'original_bytes_preserved': True,
              'pronunciation': 'pending-final-teacher-review', 'files': [
                  {'path': name, 'bytes': (voices_dir / name).stat().st_size,
                   'sha256': digest(voices_dir / name)} for name in (OUTPUT, 'Contents')]}
    shutil.copyfile(additions / 'manifest.json', voices_dir / 'additions-manifest.json')
    notice = additions / 'NOTICE.md'
    if notice.is_file():
        shutil.copyfile(notice, voices_dir / 'pt-pt-additions-NOTICE.md')
    (voices_dir / 'completion.json').write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--voices-dir', type=Path, required=True)
    parser.add_argument('--additions', type=Path, default=ROOT / 'resources/pt-pt-voices')
    parser.add_argument('--inventory-tool', type=Path, required=True)
    parser.add_argument('--rcc-tool', type=Path, required=True)
    parser.add_argument('--if-present', action='store_true', help='skip if upstream PT assets have not been downloaded')
    args = parser.parse_args()
    manifest = json.loads((args.additions / 'manifest.json').read_text(encoding='utf-8'))
    if args.if_present and not (args.voices_dir / manifest['source_rcc']).is_file():
        print('PT voice completion skipped: upstream assets have not been downloaded.')
        return
    result = complete(args.voices_dir.resolve(), args.additions.resolve(), args.inventory_tool.resolve(), args.rcc_tool.resolve())
    print(json.dumps(result, ensure_ascii=False))


if __name__ == '__main__':
    main()
