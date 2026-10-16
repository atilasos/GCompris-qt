#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Audit the fixed native maze evidence, without rerunning the game."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[2]
TESTED_REVISION = '8d9492256b0b49c5a67a8703914739b4e72316fc'
DIMENSIONS = [(4,4),(5,4),(5,5),(6,5),(6,6),(6,7),(7,7),(8,7),(8,8),
              (9,8),(9,9),(10,9),(10,10),(8,16),(14,14),(16,15),(17,16),
              (18,16),(19,18),(19,19),(20,19),(20,20),(19,21),(23,21),(23,23)]
ACTIVITIES = ['maze', 'mazeinvisible', 'mazerelative']


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def source_bytes(path):
    return subprocess.check_output(['git', '-C', str(ROOT), 'show', TESTED_REVISION + ':' + path])


def audit(evidence):
    evidence = Path(evidence)
    source_identity = json.loads((evidence / 'full-settled/source-identity.json').read_text())
    for path, digest in source_identity.items():
        assert hashlib.sha256(source_bytes(path)).hexdigest() == digest, path
    snapshot_file = evidence / 'resource-snapshot.json'
    snapshot = json.loads(snapshot_file.read_text())
    assert len(snapshot['files']) == 269
    for group in ['full-settled', 'pointer']:
        summary = json.loads((evidence / group / 'summary.json').read_text())
        assert summary['passed'] and all(row['passed'] for row in summary['cases'])
    assert json.loads((evidence / 'full-settled/summary.json').read_text())['sources_unchanged']
    cases, artifacts = [], {}

    def receipt(directory, case):
        path = evidence / directory / 'result.json'
        result = json.loads(path.read_text())
        assert result['passed'] and result['exit_code'] == 0
        assert not result['timeout'] and not result['qml_errors']
        assert result['locale'] == 'pt_PT' and result['network'] == 'docker-none'
        assert result['runtime_uid'] == result['runtime_gid'] == 1000
        assert result['private_file_ownership_verified'] and not result['deployment_retained']
        assert result['case_result']['failures'] == 0 and result['case_result']['passes'] == 2
        assert result['case_sha256'] == sha(evidence / case)
        assert result['resource_manifest_sha256'] == sha(snapshot_file)
        assert result['source_sha256'] == source_identity['src/activities/maze/Maze.qml']
        assert result['runner_sha256'] == source_identity['tools/run-native-qml-case.py']
        assert result['portuguese_catalogue_sha256'] == source_identity['poqm/pt/gcompris_qt.po']
        expected_resources = dict(snapshot['files'])
        expected_resources['share/gcompris-qt/rcc/maze.rcc'] = result['private_rcc_sha256']
        expected_resources['share/gcompris-qt/translations/gcompris_qt_pt.qm'] = result['private_qm_sha256']
        assert result['resource_files_sha256'] == expected_resources
        for screenshot in result['screenshots']:
            assert sha(evidence / directory / screenshot['file']) == screenshot['sha256']
        for file in sorted((evidence / directory).iterdir()):
            if file.is_file(): artifacts[str(file.relative_to(evidence))] = sha(file)
        artifacts[case] = sha(evidence / case)
        row = {'directory': directory, 'case': case, 'activity': result['activity'],
               'result_sha256': sha(path), 'case_sha256': result['case_sha256'],
               'observations': result['case_result']}
        cases.append(row)
        return result['case_result']

    def routes(record, activity, fast, levels):
        completed = record['completed']
        assert [row['level'] for row in completed] == levels
        assert record['collisions'] == len(levels)
        for row in completed:
            cols, rows = DIMENSIONS[row['level'] - 1]
            assert (row['columns'], row['rows']) == (cols, rows)
            assert 1 <= row['pathCells'] <= cols * rows
            assert row['inputs'] >= 0
            assert row['fast'] == fast
            assert row['relative'] == (activity == 'mazerelative')
            assert row['invisible'] == (activity == 'mazeinvisible')
        assert record['attempts'] >= record['collisions']
        if activity != 'mazerelative': assert record['rotations'] == 0

    for activity in ACTIVITIES:
        for fast in [False, True]:
            name = activity + ('-fast' if fast else '-normal')
            routes(receipt('full-settled/' + name, 'full-settled/' + name + '.qml'),
                   activity, fast, list(range(1, 26)))
            for level in [1, 14, 25]:
                name = f'{activity}-{level}-' + ('fast' if fast else 'normal')
                routes(receipt('pointer/' + name, 'pointer/' + name + '.qml'), activity, fast, [level])
        record = receipt('controls-' + activity, 'controls-case.qml')['controls']
        assert record['activity'] == activity and record['levels'] == 25
        for key in ['navigation', 'fastToggle', 'helpEscape', 'focusAfterHelp']: assert record[key]
        assert record['mapToggle'] == (activity == 'mazeinvisible')
        assert len(record['resources']) == 8
        for resource in record['resources']:
            path = resource.removeprefix('qrc:/gcompris/')
            copied = evidence / ('controls-' + activity) / Path(path).name
            assert hashlib.sha256(source_bytes(path)).hexdigest() == sha(copied)
    assert len(cases) == 27
    return {'passed': True, 'tested_source_revision': TESTED_REVISION,
            'main_level_completions': 150, 'pointer_tracer_completions': 18,
            'controls': 3, 'cases': cases, 'artifact_sha256': artifacts}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--evidence', type=Path, default=ROOT / '.scratch/pt-pt/functional-mazes')
    args = parser.parse_args()
    result = audit(args.evidence)
    (args.evidence / 'index.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({key: result[key] for key in ['passed', 'main_level_completions', 'pointer_tracer_completions', 'controls']}))
