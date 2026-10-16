#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Verify the nine explicit final native erase cases, bytes and rendered masks."""
import hashlib
import json
from pathlib import Path
from PIL import Image, ImageChops
from catalogue_compatibility import verify as verify_catalogue

ROOT = Path(__file__).resolve().parents[2]
HERE = ROOT / '.scratch/pt-pt/functional-erase'
ACTIVITIES = {'erase':'erase', 'erase_clic':'click', 'erase_2clic':'double_click'}


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def receipt(directory, activity, case):
    result = json.loads((directory / 'result.json').read_text())
    assert result['passed'] and result['exit_code'] == 0 and not result['timeout']
    assert result['qml_errors'] == [] and result['activity'] == activity
    assert result['network'] == 'docker-none' and result['locale'] == 'pt_PT'
    assert result['private_file_ownership_verified'] and len(result['resource_files_sha256']) == 269
    assert result['case_sha256'] == sha(case)
    assert result['source_sha256'] == sha(ROOT / 'src/activities/erase/Erase.qml')
    assert result['runner_sha256'] == sha(ROOT / 'tools/run-native-qml-case.py')
    assert result['portuguese_catalogue_sha256'] == verify_catalogue()['recorded_catalogue_sha256']
    assert result['case_result']['failures'] == 0 and result['case_result']['passes'] == 2
    for screenshot in result['screenshots']:
        assert sha(directory / screenshot['file']) == screenshot['sha256']
    return result


def mask_pixels(directory, level):
    with Image.open(directory / f'level-{level}-masked.png') as image:
        before = image.convert('RGB')
    with Image.open(directory / f'level-{level}-revealed.png') as image:
        after = image.convert('RGB')
    assert before.size == after.size
    # The top 65% is inside the mask for both grid sizes, away from Score and Bar.
    region = (0, 0, before.width, int(before.height * 0.65))
    difference = ImageChops.difference(before.crop(region), after.crop(region)).convert('L')
    changed = 1 - sum(difference.histogram()[:9]) / (difference.width*difference.height)
    assert changed > 0.5, (directory.name, level, changed)
    return {'level':level, 'region':region, 'changed_fraction_above_8':changed}


def audit():
    data = json.loads((HERE / 'data.json').read_text())
    for name, digest in data['source_files_sha256'].items():
        assert sha(ROOT / name) == digest
    images = set(data['image_names'])
    masks = set(data['mask_sha256'])
    assert len(images) == 33 and len(masks) == 3
    template = (ROOT / 'tests/functional_erase/gameplay.qml.in').read_text()
    cases, snapshots, files, gameplay_gestures = [], set(), {}, 0
    for activity, kind in ACTIVITIES.items():
        for mode in (1, 2):
            name = activity + ('-automatic' if mode == 1 else '-manual')
            directory = HERE / 'full' / name
            case = HERE / 'full' / (name+'.qml')
            assert case.read_text() == template.replace('__MODE__',str(mode)).replace('__LEVELS__','6')
            result = receipt(directory, activity, case)
            process = json.loads((HERE / 'full' / (name+'.process.json')).read_text())
            assert process['launcher_exit'] == process['native_exit'] == 0 and process['native_passed']
            record = result['case_result']
            assert record['type'] == kind and record['mode'] == mode and record['levelLimit'] == 6
            assert len(record['completed']) == 36 and record['wins'] == 6 and record['gestures'] == 1602
            assert record['wrongEvents'] == {'erase':18, 'click':24, 'double_click':30}[kind]
            assert {Path(route).name for route in record['images']} == images
            assert {Path(route).name for route in record['masks']} == masks
            for index, row in enumerate(record['completed']):
                level, sub = index//6+1, index%6+1
                assert row['level'] == level and row['sublevel'] == sub
                assert row['tiles'] == (25 if level%2 else 64) and row['visibleAfter'] == 0
                assert row['score'] == f'{sub}/6'
                assert Path(row['image']).name in images and Path(row['mask']).name in masks
            expected_sound_routes = ['qrc:/gcompris/src/activities/erase/resource/eraser1.wav',
                                     'qrc:/gcompris/src/activities/erase/resource/eraser2.wav',
                                     'qrc:/gcompris/src/core/resource/sounds/completetask.wav']
            assert [sound['source'] for sound in record['soundEffects']] == expected_sound_routes
            pixel_checks = [mask_pixels(directory, level) for level in range(1, 7)]
            cases.append({'activity':activity, 'mode':mode, 'images':36, 'wins':6,
                          'gestures':record['gestures'], 'pixel_checks':pixel_checks,
                          'process':process, 'sound_effect_observations':record['soundEffects']})
            snapshots.add(result['resource_manifest_sha256'])
            gameplay_gestures += record['gestures']
            for path in directory.iterdir():
                if path.is_file():files[str(path.relative_to(HERE))] = sha(path)
            for suffix in ('.qml','.process.json','.launcher.log'):
                path = HERE / 'full' / (name+suffix);files[str(path.relative_to(HERE))] = sha(path)
        directory = HERE / 'controls-final' / activity
        result = receipt(directory, activity, ROOT / 'tests/functional_erase/controls.qml')
        process = json.loads((HERE / 'controls-final' / (activity+'.process.json')).read_text())
        assert process['launcher_exit'] == process['native_exit'] == 0 and process['native_passed']
        evidence = result['case_result']['evidence']
        assert all(evidence[field] for field in ('restartClearedPartial','previousNext','inputAfterHelp','menu'))
        assert evidence['exit'] == ('Escape' if kind == 'click' else 'Home')
        snapshots.add(result['resource_manifest_sha256'])
        for path in directory.iterdir():
            if path.is_file():files[str(path.relative_to(HERE))] = sha(path)
        for suffix in ('.process.json','.launcher.log'):
            path = HERE / 'controls-final' / (activity+suffix);files[str(path.relative_to(HERE))] = sha(path)
    exported = HERE / 'full/erase-automatic'
    for resource in data['decoded_resources']:
        assert sha(exported / Path(resource['file']).name) == resource['sha256']
    for name, digest in data['mask_sha256'].items():
        assert sha(exported / name) == digest
    assert len(cases) == 6 and len(snapshots) == 1 and gameplay_gestures == 9612
    return {'scope':'Linux native offline; 6 gameplay plus 3 controls. Windows, physical touch/audio and teacher pending.',
            'cases':cases, 'completed_level_routes':36, 'completed_images':216,
            'gameplay_gestures':gameplay_gestures, 'wrong_events':144,
            'snapshot_manifest_sha256':next(iter(snapshots)), 'resource_count':269,
            'original_exported_resources':39, 'artifact_sha256':files}


if __name__ == '__main__':
    index = audit()
    (HERE / 'index.json').write_text(json.dumps(index, ensure_ascii=False, indent=2)+'\n')
    print(json.dumps({key:index[key] for key in ('completed_level_routes','completed_images',
                                              'gameplay_gestures','wrong_events','original_exported_resources')}))
