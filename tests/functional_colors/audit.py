#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Check archived native colors receipts without depending on old build paths."""
import argparse
import hashlib
import json
from pathlib import Path
from oracle import light_steps, pigment_steps


def validate_mix(row, light):
    assert 1 <= row['level'] <= 6
    target = row['displayedTarget']
    assert len(target) == 3 and all(0 <= channel <= 1 for channel in target)
    expected = light_steps(target, row['level']) if light else pigment_steps(target, row['level'])
    assert row['steps'] == expected
    assert len(row['result']) == 3 and all(abs(a-b) < 0.006 for a, b in zip(target, row['result']))


def validate_name(row, vocabulary):
    assert row['text'] in vocabulary
    assert row['source'].startswith('qrc:/gcompris/src/activities/')
    assert row['source'].split('/')[-1] == vocabulary[row['text']]


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def receipt(base, name):
    folder = base/name
    d = json.loads((folder/'result.json').read_text())
    assert d['passed'] and d['exit_code'] == 0 and not d['timeout'] and not d['qml_errors'], name
    assert d['network'] == 'docker-none' and d['locale'] == 'pt_PT'
    assert d['case_result']['failures'] == 0
    assert d['private_file_ownership_verified'] and not d['deployment_retained']
    assert d['case_sha256'] == sha(folder/'case.qml')
    for screenshot in d['screenshots']:
        assert sha(folder/screenshot['file']) == screenshot['sha256']
    return d


def audit(base):
    vocabulary = json.loads((base/'vocabulary.json').read_text())
    data = json.loads((base/'inventory.json').read_text())
    affected = data['fawn_affected_levels']
    records = {}
    cases = ['basic-complete', 'advanced-complete', 'paint-final', 'light-final']
    cases += [f'fulva-level{level}-green' for level in affected]
    cases += ['basic-controls-home', 'advanced-controls-escape', 'paint-controls-escape', 'light-controls-home',
              'sliders-green', 'slider-ranges-green', 'slider-ranges-paint-green', 'garnet-green',
              'repeat-tab-tracer', 'paint-feedback-tracer', 'light-feedback-tracer']
    parsed = {name: receipt(base, name) for name in cases}
    basic = parsed['basic-complete']['case_result']['observations']
    advanced = [row for row in parsed['advanced-complete']['case_result']['observations'] if row['level'] not in affected]
    for level in affected:
        rows = parsed[f'fulva-level{level}-green']['case_result']['observations']
        assert len(rows) == 8 and {row['level'] for row in rows} == {level}
        assert any(row['text'] == 'Descobrir a borboleta fulva' for row in rows)
        advanced.extend(rows)
    for activity, rows in [('colors', basic), ('advanced_colors', advanced)]:
        expected = {(level+1, question+1) for level, images in enumerate(data['levels'][activity]) for question in range(len(images))}
        assert len(rows) == len(expected) and {(row['level'], row['question']) for row in rows} == expected
        for row in rows:
            validate_name(row, vocabulary[activity])
            assert row['source'].removeprefix('qrc:/gcompris/') in data['levels'][activity][row['level']-1]
        for level, images in enumerate(data['levels'][activity], 1):
            observed = [row['source'].removeprefix('qrc:/gcompris/') for row in rows if row['level'] == level]
            assert sorted(observed) == sorted(images)
        records[activity] = {'questions': len(rows), 'levels': len(data['levels'][activity])}
    for name, activity, light in [('paint-final', 'color_mix', False), ('light-final', 'color_mix_light', True)]:
        value = parsed[name]['case_result']; rows = value['observations']
        assert len(rows) == 36 and value['wins'] == 6
        assert {(row['level'], row['question']) for row in rows} == {(level, question) for level in range(1, 7) for question in range(1, 7)}
        for row in rows:
            validate_mix(row, light)
            assert row['rejection'] and row['route'] in ['buttons', 'drag']
        records[activity] = {'questions': len(rows), 'levels': 6}
    for name in ['basic-controls-home', 'advanced-controls-escape', 'paint-controls-escape', 'light-controls-home']:
        assert all(value is True for key, value in parsed[name]['case_result']['evidence'].items() if key not in ['title', 'exit'])
    for name in ['slider-ranges-green', 'slider-ranges-paint-green']:
        rows = parsed[name]['case_result']['observations']
        assert len(rows) == 18 and {(row['level'], row['control']) for row in rows} == {(level, control) for level in range(1, 7) for control in range(3)}
        assert all(all(abs(a-b) < 0.006 for a,b in zip(row['actual'],row['expected'])) for row in rows)
    sounds = parsed['basic-complete']['case_result']
    assert not sounds['audioErrors']
    heard = {row['route'] for row in sounds['progressed'] if row['position'] > 0 and row['duration'] > 0 and row['playbackState'] == 1}
    expected = {'qrc:/gcompris/data/voices-ogg/pt/colors/'+image.replace('_duck.svg','.ogg') for image in vocabulary['colors'].values()}
    assert expected <= heard and len(expected) == 11
    for name in ['paint-feedback-tracer', 'light-feedback-tracer', 'repeat-tab-tracer']:
        assert len(parsed[name]['case_result']['observations']) == 6
        assert parsed[name]['case_result']['wins'] == 1
    result = {'scope': 'Linux native offline; perceptual fidelity, pronunciation, physical audition/devices, Windows and teacher review remain pending.',
              'records': records, 'main_questions': sum(row['questions'] for row in records.values()), 'color_voice_routes_playing': sorted(expected),
              'advanced_composition': {'baseline_levels': [level for level in range(1,21) if level not in affected], 'replacement_levels': affected},
              'cases': {name: {'result_sha256': sha(base/name/'result.json'), 'case_sha256': parsed[name]['case_sha256']} for name in cases}}
    assert result['main_questions'] == 254
    source_identity = json.loads((base/'source-identity.json').read_text())
    result['qt_exposed_source_files'] = sum(len(value['files']) for value in source_identity.values())
    assert result['qt_exposed_source_files'] == 330
    audio_identity = json.loads((base/'audio-identity.json').read_text())
    for name, value in parsed.items():
        for route, filename in value['case_result'].get('copiedRoutes', {}).items():
            assert sha(base/name/filename) == audio_identity[route]['sha256']
    result['artifact_sha256'] = {str(path.relative_to(base)): sha(path) for path in sorted(base.rglob('*'))
                                 if path.is_file() and path.name != 'index.json'
                                 and not any(part.startswith('.native-qml-') for part in path.parts)}
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--evidence', required=True, type=Path)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    result = audit(args.evidence)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2)+'\n')
    print(json.dumps({'main_questions': result['main_questions'], 'final_cases': len(result['cases']), 'voices': len(result['color_voice_routes_playing'])}))
