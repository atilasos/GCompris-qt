#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Describe source datasets and visible assets independently of game matching code."""
import hashlib
import json
from pathlib import Path
import re
from oracle import dice_pips

ROOT = Path(__file__).resolve().parents[2]


def inventory():
    result = {'activities': {}, 'dice': {}, 'source_files': {}}
    for activity in ['enumerate', 'smallnumbers', 'smallnumbers2']:
        resource = ROOT / 'src/activities' / activity / 'resource'
        levels = []
        paths = sorted(resource.glob('*/Data.qml'), key=lambda path: int(path.parent.name))
        for path in paths:
            text = path.read_text()
            if activity == 'enumerate':
                rows = [json.loads('{"subLevels"' + row + '}') for row in re.findall(r'\{\s*"subLevels"(.*?)\}', text, re.S)]
            else:
                rows = [{'subLevels': int(total), 'allowed_digits': [int(value) for value in re.findall(r'"([0-9])"', words)]}
                        for total, words in re.findall(r'"sublevels"\s*:\s*"(\d+)".*?"words"\s*:\s*\[(.*?)\]', text, re.S)]
            assert rows, path
            levels.extend({'dataset': path.parent.name, **row} for row in rows)
        result['activities'][activity] = {'datasets': [path.parent.name for path in paths], 'levels': levels,
                                         'questions': sum(row['subLevels'] for row in levels)}
        for path in sorted(resource.rglob('*')):
            if path.is_file():
                result['source_files'][str(path.relative_to(ROOT))] = hashlib.sha256(path.read_bytes()).hexdigest()
    for path in sorted((ROOT / 'src/activities/smallnumbers/resource').glob('dice*.svg')):
        result['dice'][path.name] = {'visible_top_pips': dice_pips(path), 'sha256': hashlib.sha256(path.read_bytes()).hexdigest()}
    assert [row['visible_top_pips'] for row in result['dice'].values()] == list(range(10))
    for activity, expected in [('enumerate', (4, 14, 64)), ('smallnumbers', (8, 9, 144)), ('smallnumbers2', (8, 9, 144))]:
        data = result['activities'][activity]
        assert (len(data['datasets']), len(data['levels']), data['questions']) == expected
    return result


if __name__ == '__main__':
    print(json.dumps(inventory(), indent=2))
