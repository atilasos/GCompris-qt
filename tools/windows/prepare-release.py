#!/usr/bin/env python3
# SPDX-FileCopyrightText: NONE
# SPDX-License-Identifier: CC0-1.0
"""Publish metadata only for the exact CI source and verified installer bytes."""
import hashlib
import json
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path


def prepare(folder):
    root = Path(__file__).resolve().parents[2]
    artifacts = folder / 'artifacts'
    source = os.environ['GITHUB_SHA']
    run = os.environ['GITHUB_RUN_ID']
    actual = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=root, text=True).strip()
    if source != actual:
        raise ValueError('Checkout does not match the workflow source')
    names = [line.strip() for line in (root / 'src/activities/activities.txt').read_text().splitlines()
             if line.strip() and not line.lstrip().startswith('#')]
    for name in ('package-check.json', 'installer-check.json'):
        report = json.loads((artifacts / name).read_text())
        if not report['passed'] or not report['native_list_checked'] or report['expected_activities'] != len(names):
            raise ValueError(f'Package acceptance failed: {name}')
    checksums = dict((line.split()[1], line.split()[0].lower()) for line in
                     (artifacts / 'SHA256SUMS.txt').read_text(encoding='utf-8-sig').splitlines() if line.strip())
    installer_name = 'GCompris-PT-PT-Windows-x64-candidate.exe'
    for name in (installer_name, 'GCompris-PT-PT-Windows-x64-portable.zip'):
        with (artifacts / name).open('rb') as stream:
            digest = hashlib.file_digest(stream, 'sha256').hexdigest()
        if checksums.get(name) != digest:
            raise ValueError(f'Checksum mismatch: {name}')
    metadata = {'date': datetime.now(timezone.utc).date().isoformat(), 'run': run, 'source': source,
                'sha256': checksums[installer_name], 'bytes': (artifacts / installer_name).stat().st_size,
                'activities': len(names),
                'url': f'https://github.com/atilasos/GCompris-qt/releases/download/windows-{run}/{installer_name}'}
    (artifacts / 'release.json').write_text(json.dumps(metadata, indent=2) + '\n')
    notes = f'''Candidato de teste Windows x64 com {len(names)} atividades e recursos offline.

Inclui todo o código do commit `{source}`, incluindo as atividades e recursos presentes no manifesto dessa revisão.

Compilação, instalação e arranque offline verificados em Windows Server 2022. A validação no Windows 10 da escola, a audição física e a revisão pedagógica permanecem pendentes.

SHA-256 do instalador: `{metadata['sha256']}`

<!-- gcompris-release: {json.dumps(metadata)} -->
'''
    (folder / 'release-notes.md').write_text(notes)
    print(json.dumps(metadata))


if __name__ == '__main__':
    prepare(Path(sys.argv[1]))
