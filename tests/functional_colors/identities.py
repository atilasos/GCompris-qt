# SPDX-License-Identifier: GPL-3.0-or-later
"""Bind historical colors receipts to Git blobs and captured snapshot manifests."""
from functools import cache
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[2]
TESTED_REVISION = '53c2fe61ea46e950e58752a9e6ef0a71b5e80c31'
EVIDENCE = '.scratch/pt-pt/functional-colors/'
CURRENT = {'sliders-green', 'garnet-green'}
FIXED = {'basic-complete', 'advanced-complete', 'basic-controls-home', 'advanced-controls-escape',
         'slider-ranges-green', 'slider-ranges-paint-green'}
FULVA = {'fulva-level5-green', 'fulva-level12-green', 'fulva-level15-green', 'fulva-level16-green',
         'repeat-tab-tracer', 'paint-feedback-tracer', 'light-feedback-tracer'}


@cache
def tested_bytes(relative):
    return subprocess.check_output(['git', '-C', str(ROOT), 'show', TESTED_REVISION+':'+relative])


def digest(content):
    return hashlib.sha256(content).hexdigest()


def tested_json(relative):
    return json.loads(tested_bytes(EVIDENCE+relative))


def catalogue_bytes(fulva):
    content = tested_bytes('poqm/pt/gcompris_qt.po')
    if not fulva:
        final = b'msgid "Find the fawn butterfly"\nmsgstr "Descobrir a borboleta fulva"'
        previous = b'msgid "Find the fawn butterfly"\nmsgstr "Descobrir a borboleta cor de fauno"'
        assert content.count(final) == 1
        content = content.replace(final, previous)
    return content


def verify_identities(base):
    # These captured maps are inputs, never a newly computed approval baseline.
    for filename in ['inventory.json', 'vocabulary.json', 'audio-identity.json']:
        assert json.loads((base/filename).read_text()) == tested_json(filename), filename
    original = tested_json('index.json')
    manifests = {}
    for name, expected in original['cases'].items():
        raw = (base/name/'result.json').read_bytes()
        assert digest(raw) == expected['result_sha256'], 'Historical receipt changed: '+name
        result = json.loads(raw)
        assert digest((base/name/'case.qml').read_bytes()) == expected['case_sha256'] == result['case_sha256']
        assert result['source_sha256'] == digest(tested_bytes('src/activities/'+result['qml_file']))
        assert result['runner_sha256'] == digest(tested_bytes('tools/run-native-qml-case.py'))
        assert result['portuguese_catalogue_sha256'] == digest(catalogue_bytes(name in FULVA))
        captured = tested_json(name+'/result.json')
        for field in ['activity', 'qml_file', 'private_rcc_sha256', 'private_qm_sha256', 'binary_sha256',
                      'resource_manifest_sha256', 'resource_files_sha256', 'offline_image_id']:
            assert result[field] == captured[field], field
        stage = 'colors-current' if name in CURRENT else 'colors-fixed' if name in FIXED else 'colors-final'
        manifest_raw = (base/(stage+'-manifest.json')).read_bytes()
        assert digest(manifest_raw) == result['resource_manifest_sha256'], stage
        manifest = json.loads(manifest_raw)
        effective = dict(manifest['files'])
        source_activity = result['qml_file'].split('/')[0]
        effective['share/gcompris-qt/rcc/'+source_activity+'.rcc'] = result['private_rcc_sha256']
        effective['share/gcompris-qt/translations/gcompris_qt_pt.qm'] = result['private_qm_sha256']
        assert effective == result['resource_files_sha256']
        assert manifest['files']['bin/gcompris-qt'] == result['binary_sha256']
        manifests[stage] = manifest
    assert set(manifests) == {'colors-current', 'colors-fixed', 'colors-final'}
    # The final canonical RCC capture exposes every file in these Git subtrees.
    identity = json.loads((base/'source-identity.json').read_text())
    assert identity == tested_json('source-identity.json'), 'Captured RCC identity changed'
    assert set(identity) == {'core', 'colors', 'advanced_colors', 'color_mix', 'color_mix_light'}
    total = 0
    source_map = {}
    for name, value in identity.items():
        prefix = 'src/core' if name == 'core' else 'src/activities/'+name
        paths = set(subprocess.check_output(['git', '-C', str(ROOT), 'ls-tree', '-r', '--name-only',
                                            TESTED_REVISION, '--', prefix], text=True).splitlines())
        rows = value['files']
        assert len(rows) == len(paths)
        assert {row['path'] for row in rows} == {':/gcompris/'+path for path in paths}
        for row in rows:
            relative = row['path'].removeprefix(':/gcompris/')
            content = tested_bytes(relative)
            assert row['sha256'] == digest(content), relative
            assert row['bytes'] == len(content) and row['ogg'] == content.startswith(b'OggS')
            source_map[relative] = row['sha256']
        resource = 'share/gcompris-qt/rcc/'+name+'.rcc'
        assert value['rcc_sha256'] == manifests['colors-final']['files'][resource]
        total += len(rows)
    assert source_map == tested_json('inventory.json')['source_files']
    assert total == 330
    for filename in ['colors-origin-manifest.json', 'captured-resource-manifest.json']:
        assert (base/filename).read_bytes() == tested_bytes(EVIDENCE+filename)
    return {'tested_revision': TESTED_REVISION, 'source_files': total,
            'snapshot_stages': sorted(manifests), 'catalogue_stages': ['grená/fauno', 'grená/fulva']}
