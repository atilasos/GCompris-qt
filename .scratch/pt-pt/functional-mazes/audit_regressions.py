#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Check the unchanged native cases that reproduced three maze regressions."""
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
PAIRS = [('pilot', 'pilot-green', 'pilot.qml'),
         ('direct-18-baseline', 'direct-18-green', 'direct-18.qml'),
         ('map-pause-baseline', 'map-pause-green', 'map-pause.qml')]


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def observation(name):
    text = (HERE / name / 'native.log').read_text()
    return json.loads(next(line.split('MAP_PAUSE_OBSERVATION ', 1)[1]
                           for line in text.splitlines() if 'MAP_PAUSE_OBSERVATION ' in line))


def audit():
    artifacts = {}
    for red, green, case in PAIRS:
        before = json.loads((HERE / red / 'result.json').read_text())
        after = json.loads((HERE / green / 'result.json').read_text())
        assert before['passed'] is False and before['case_result']['failures'] == 1
        assert after['passed'] is True and after['case_result']['failures'] == 0
        assert before['case_sha256'] == after['case_sha256'] == sha(HERE / case)
        for name, receipt in [(red, before), (green, after)]:
            assert receipt['network'] == 'docker-none' and receipt['locale'] == 'pt_PT'
            assert not receipt['timeout'] and not receipt['qml_errors']
            for file in sorted((HERE / name).iterdir()):
                if file.is_file(): artifacts[str(file.relative_to(HERE))] = sha(file)
        artifacts[case] = sha(HERE / case)
    old = json.loads((HERE / 'direct-18-baseline/result.json').read_text())['case_result']
    new = json.loads((HERE / 'direct-18-green/result.json').read_text())['case_result']
    assert old['level'] == new['level'] == 18 and old['rows'] == 0
    assert new['rows'] == 16 and new['columns'] == 18
    old, new = observation('map-pause-baseline'), observation('map-pause-green')
    assert old['mapVisible'] and new['mapVisible']
    assert old['actual'] != old['expected'] and new['actual'] == new['expected']
    return {'passed': True, 'pairs': PAIRS, 'artifact_sha256': artifacts}


if __name__ == '__main__':
    result = audit()
    (HERE / 'regressions.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({'passed': True, 'pairs': len(PAIRS)}))
