#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Check only the six completed final native ordering receipts and their bytes."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
HERE = ROOT / '.scratch/pt-pt/functional-ordering'
GAMEPLAY = {
    'ordering_numbers': ('final-numbers/ordering_numbers-gameplay', 8),
    'ordering_alphabets': ('alphabets', 8),
    'ordering_sentences': ('sentences', 20),
}


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def verify_receipt(activity, directory, case):
    receipt = json.loads((directory / 'result.json').read_text())
    assert receipt['passed'] and receipt['exit_code'] == 0 and not receipt['timeout']
    assert receipt['qml_errors'] == [] and receipt['activity'] == activity
    assert receipt['network'] == 'docker-none' and receipt['locale'] == 'pt_PT'
    assert receipt['private_file_ownership_verified']
    assert receipt['case_result']['passes'] == 2 and receipt['case_result']['failures'] == 0
    assert receipt['case_sha256'] == sha(ROOT / f'tests/functional_ordering/{case}.qml')
    assert receipt['source_sha256'] == sha(ROOT / 'src/activities/ordering_numbers/Ordering.qml')
    assert receipt['runner_sha256'] == sha(ROOT / 'tools/run-native-qml-case.py')
    assert receipt['portuguese_catalogue_sha256'] == sha(ROOT / 'poqm/pt/gcompris_qt.po')
    assert len(receipt['resource_files_sha256']) == 269
    for screenshot in receipt['screenshots']:
        assert screenshot['sha256'] == sha(directory / screenshot['file'])
    return receipt


def audit():
    receipts, records, manifests = [], {}, set()
    for activity, (relative, total) in GAMEPLAY.items():
        directory = HERE / relative
        receipt = verify_receipt(activity, directory, 'gameplay')
        record = receipt['case_result']
        assert len(record['completed']) == record['rejected'] == total
        assert record['reordered'] == 1
        assert [row['level'] for row in record['completed']] == list(range(1, total+1))
        for index, row in enumerate(record['completed']):
            labels, ordered, wrong = row['visible'], row['ordered'], row['rejected']
            assert sorted(labels) == sorted(ordered) == sorted(wrong)
            assert wrong[0:2] == ordered[1::-1] and wrong[2:] == ordered[2:]
            if activity == 'ordering_numbers':
                low = [1,1,2,2,8,8,2,2][index]
                high = [5,5,10,10,20,20,30,30][index]
                assert len(labels) == (8 if index >= 6 else 5) == len(set(labels))
                assert all(low <= int(label) <= high for label in labels)
                assert ordered == sorted(labels, key=int, reverse=bool(index % 2))
            elif activity == 'ordering_alphabets':
                assert len(labels) == (8 if index >= 6 else 5) == len(set(labels))
                assert all(len(label) == 1 and label in 'abcdefghijklmnopqrstuvwxyz' for label in labels)
                assert ordered == sorted(labels, reverse=index in (2,3,5,7))
            else:
                words = ' '.join(ordered).split()
                assert (3 <= len(words) <= 5) if index < 10 else (6 <= len(words) <= 10)
        expected_drags = 3 * sum(len(row['visible']) for row in record['completed']) + 1
        assert record['drags'] == expected_drags
        records[activity] = record
        manifests.add(receipt['resource_manifest_sha256'])
        receipts.append(relative)
        controls = 'verified-controls/' + activity + '-controls'
        receipt = verify_receipt(activity, HERE / controls, 'controls')
        evidence = receipt['case_result']['evidence']
        assert all(evidence[field] for field in ('configurationSaved', 'restartClearedPartial', 'help', 'navigation', 'menu'))
        assert evidence['persistentIgnoredDatasets'] == ['1']
        assert evidence['allLevels'] == total
        assert evidence['reducedLevels'] == {'ordering_numbers':7, 'ordering_alphabets':6, 'ordering_sentences':10}[activity]
        background = evidence['background']
        assert background['status'] == 1
        assert background['url'] == 'qrc:/gcompris/src/activities/braille_fun/resource/hillside.svg'
        assert background['svg'].encode() == (ROOT / 'src/activities/braille_fun/resource/hillside.svg').read_bytes()
        manifests.add(receipt['resource_manifest_sha256'])
        receipts.append(controls)
    assert len(receipts) == 6 and len(manifests) == 1
    data = json.loads((HERE / 'data-green.json').read_text())
    for relative, digest in data['source_files_sha256'].items():
        assert sha(ROOT / relative) == digest
    assert len(data['sentences']) == 20 and len(data['alphabet_levels']) == len(data['number_levels']) == 8
    artifacts = {str(path.relative_to(HERE)): sha(path)
                 for relative in receipts for path in sorted((HERE / relative).iterdir()) if path.is_file()}
    return {'scope': 'Linux native offline; six explicitly completed cases; Windows/physical audio/touch/teacher pending',
            'cases': receipts, 'levels': 36, 'wrong_submissions': 36,
            'drags': sum(record['drags'] for record in records.values()),
            'snapshot_manifest_sha256': next(iter(manifests)),
            'resource_count': 269, 'records': records, 'artifact_sha256': artifacts}


if __name__ == '__main__':
    index = audit()
    (HERE / 'index.json').write_text(json.dumps(index, ensure_ascii=False, indent=2) + '\n')
    print(json.dumps({field:index[field] for field in ('cases','levels','wrong_submissions','drags','resource_count')}))
