#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Build complete offline PT voices with exactly allowlisted approved substitutions.

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
OUTPUT = 'voices-pt-2026-10-16-00-00-00.rcc'
APPROVAL_SHA256 = '7aaa494997f32a01661e5b6607d305dce353990bb7f4862166c60dc78ff4ad9c'
APPROVED_ADDITIONS_SHA256 = 'd9da8879db769243664228f918539e35d0964c1b1e24b9b828faadb0028d1321'
DERIVED_OGG_SHA256 = {
    'words/fawn.ogg': '4b501ba589d7ef3d564adc7df51b033bf124264442bd4ef5af98414b97ab7f6e',
    'words/tick.ogg': 'a90060398f8048ed9bdbd7cf8382711981c1769ff8d9736466507e381147d749',
}
APPROVED_LEGACY = {'words/fawn.ogg': {'text': 'cervato',
                    'wav': 'fawn-proposta.wav',
                    'wav_sha256': '914085d774ef2b235b8cd9655681af98bab1842efff73014bbde80a741882134',
                    'original_sha256': '1e8bc6b3d4cc6d6052f0ce6c9b4ff0084ceb9d227fd2e49d32cde570e8d954b3'},
 'words/tick.ogg': {'text': 'carraça',
                    'wav': 'tick-proposta.wav',
                    'wav_sha256': '8beea8067c7dc6a6aa52baf2b015da882deb68a05f5960fa0f7f0e08c6f7587e',
                    'original_sha256': 'c23c4f3b00f736f4158e073de583a089eac46750ddb6a748f62a2fb4c0cce19b'}}


def digest(path, algorithm='sha256'):
    return hashlib.new(algorithm, path.read_bytes()).hexdigest()


def recording_review_status(manifest, recording=None):
    approved = manifest.get('teacher_review', {}).get('recordings', {})
    def status(row):
        reviewed = approved.get(row['file'])
        return 'approved' if reviewed == {'text': row.get('text'), 'sha256': row['sha256']} else 'pending'
    if recording is not None:
        return status(recording)
    statuses = [status(row) for row in manifest['recordings']]
    if statuses and all(value == 'approved' for value in statuses):
        return 'approved'
    return 'partial' if 'approved' in statuses else 'pending'


def inventory(utility, rcc, export=None):
    command = [str(utility), str(rcc)]
    if export is not None:
        command.append(str(export))
    return json.loads(subprocess.check_output(command, text=True))


def approved_replacements(additions, original):
    path = additions / 'replacements.json'
    if not path.is_file():
        raise ValueError('Approved legacy replacement manifest missing')
    manifest = json.loads(path.read_text(encoding='utf-8'))
    if (manifest.get('human_approval_sha256') != APPROVAL_SHA256 or
            manifest.get('review_archive_sha256') != 'fe3563da247ebe91a149b32b7c7849795534284dba06c91f79677f400c81c179' or
            manifest.get('source_wav_review') != 'approved' or
            manifest.get('derived_ogg_human_review') != 'not-performed'):
        raise ValueError('Legacy approval scope or identity changed')
    rows = manifest.get('recordings', [])
    if len(rows) != 2 or {row['file'] for row in rows} != set(APPROVED_LEGACY):
        raise ValueError('Only the two allowlisted legacy substitutions are approved')
    for row in rows:
        approved = APPROVED_LEGACY[row['file']]
        if row.get('sha256') != DERIVED_OGG_SHA256[row['file']] or any(row.get(key) != value for key, value in approved.items()):
            raise ValueError('Legacy substitution differs from exact approved WAV/text')
        if original.get(PREFIX + row['file']) != approved['original_sha256']:
            raise ValueError('Legacy source recording differs from captured original')
        recording = additions / row['file']
        if (not recording.is_file() or recording.stat().st_size != row['bytes'] or
                digest(recording) != row['sha256'] or not recording.read_bytes().startswith(b'OggS')):
            raise ValueError('Approved replacement recording is missing, damaged or changed: ' + row['file'])
    return rows


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
            if not path.is_file() or path.stat().st_size != row['bytes'] or digest(path) != row['sha256'] or not path.read_bytes().startswith(b'OggS'):
                raise ValueError(f'Addition recording is missing, damaged or changed: {name}')
            inputs[key] = path.resolve()
            expected[key] = row['sha256']
        substitutions = []
        if (additions / 'replacements.json').is_file() or manifest['source_rcc_sha256'] == '522d05bcf421e3cee2fdebf7ba9469ff294a69b61d629464283855297e006b8f':
            recorded = [row['file'] for row in manifest['recordings']]
            approved = manifest.get('teacher_review', {}).get('recordings', {})
            if (len(recorded) != 32 or set(recorded) != set(approved) or
                    hashlib.sha256(json.dumps(approved, sort_keys=True, ensure_ascii=False).encode()).hexdigest() != APPROVED_ADDITIONS_SHA256):
                raise ValueError('The exact 32 approved additions are required')
        if (additions / 'replacements.json').is_file() or manifest['source_rcc_sha256'] == '522d05bcf421e3cee2fdebf7ba9469ff294a69b61d629464283855297e006b8f':
            substitutions = approved_replacements(additions, expected)
            if recording_review_status(manifest) != 'approved':
                raise ValueError('The 32 approved additions must retain their approved identities')
            for row in substitutions:
                key = PREFIX + row['file']
                inputs[key] = (additions / row['file']).resolve()
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
            raise ValueError('Compiled RCC differs from preserved originals, additions or approved substitutions')
        # Replace only the pt Contents line. Other languages remain selectable.
        lines = [line for line in original_contents.splitlines()
                 if not (len(line.split()) == 2 and line.split()[1].startswith('voices-pt-'))]
        lines.append(f'{digest(completed, "md5")}  {OUTPUT}')
        (temporary / 'Contents').write_text('\n'.join(lines) + '\n', encoding='utf-8')
        # Publish the RCC first, then its index. A retry always starts from the
        # pinned original and converges to the same bytes and registration entry.
        completed.replace(voices_dir / OUTPUT)
        (temporary / 'Contents').replace(contents)
    result = {'format': 2 if substitutions else 1, 'source_rcc': original.name, 'source_rcc_sha256': digest(original),
              'original_files': len(source), 'added_files': len(manifest['recordings']),
              'total_files': len(expected), 'original_bytes_preserved': not bool(substitutions),
              'source_rcc_bytes_preserved': True,
              'preserved_original_files': len(source) - len(substitutions),
              'replaced_files': len(substitutions),
              'substitutions': [{key: row[key] for key in ('file','text','original_sha256','sha256','wav','wav_sha256')} for row in substitutions],
              'replacement_source_wav_review': 'approved' if substitutions else 'not-applicable',
              'replacement_ogg_human_review': 'not-performed' if substitutions else 'not-applicable',
              'pronunciation': ('bounded-32-additions-and-two-source-wav-approvals' if substitutions else 'approved-new-recordings' if recording_review_status(manifest) == 'approved'
                                else 'pending-final-teacher-review'),
              'new_recordings_review': recording_review_status(manifest), 'files': [
                  {'path': name, 'bytes': (voices_dir / name).stat().st_size,
                   'sha256': digest(voices_dir / name)} for name in (OUTPUT, 'Contents')]}
    shutil.copyfile(additions / 'manifest.json', voices_dir / 'additions-manifest.json')
    if substitutions:
        shutil.copyfile(additions / 'replacements.json', voices_dir / 'replacements-manifest.json')
    notice = additions / 'NOTICE.md'
    if notice.is_file():
        shutil.copyfile(notice, voices_dir / 'pt-pt-additions-NOTICE.md')
    if substitutions:
        result['human_approval_sha256'] = APPROVAL_SHA256
        result['provenance_files'] = [{'path': name, 'bytes': (voices_dir / name).stat().st_size,
                                      'sha256': digest(voices_dir / name)}
                                     for name in ('additions-manifest.json', 'replacements-manifest.json', 'pt-pt-additions-NOTICE.md')]
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
