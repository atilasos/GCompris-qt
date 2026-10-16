#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Audit source datasets, denomination identities and bounded attainability."""
from decimal import Decimal
import hashlib
import json
from pathlib import Path
import re
from oracle import DENOMINATIONS

ROOT = Path(__file__).resolve().parents[2]
ACTIVITIES = ['money', 'money_cents', 'money_back', 'money_back_cents']


def inventory(source=ROOT):
    constants = (source/'src/activities/money/moneyConstants.js').read_text()
    coins = {}
    for name, image, value in re.findall(r'(MONEY_\w+):\s*\{\s*img:\s*"([^"]+)",\s*val:\s*([0-9.]+)', constants):
        filename = image.split('/')[-1]
        cents = int(Decimal(value)*100)
        assert cents == DENOMINATIONS[filename]
        coins[name] = {'image': image, 'cents': cents}
    assert len(coins) == len(DENOMINATIONS) == 15
    report = {'activities': {}, 'source_files': {}, 'denominations': DENOMINATIONS}
    for activity in ACTIVITIES:
        levels = []
        paths = sorted((source/'src/activities'/activity/'resource').glob('*/Data.qml'), key=lambda path: int(path.parent.name))
        for path in paths:
            raw = re.search(r'\bdata:\s*(\[.*\])\s*\}', path.read_text(), re.S)[1]
            raw = re.sub(r'moneyItems\.(\w+)', lambda match: json.dumps(coins[match[1]]), raw)
            rows = json.loads(re.sub(r',\s*([\]}])', r'\1', raw))
            for row in rows:
                values = [coin['cents'] for coin in row['pocket']]
                step = 1 if 'cents' in activity else 100
                assert all(value % step == 0 for value in values)
                ceiling = int(row['paid']*100) if 'back' in activity else int(row['maxPrice']*100)-(0 if step == 1 else 100)
                bits = 1
                for value in values:
                    bits |= bits << (value//step)
                lower = max(1, max(row['minPrice'], row['numberOfItem'])*100-99*row['numberOfItem']) if activity == 'money_cents' else 0
                required = ((1 << (ceiling//step+1))-1) ^ ((1 << (lower//step))-1)
                assert bits & required == required, (activity, path.parent.name, len(levels)+1, ceiling)
                levels.append({'dataset': path.parent.name, **row, 'reachable_min_cents': lower, 'reachable_max_cents': ceiling, 'step_cents': step})
        report['activities'][activity] = {'datasets': [path.parent.name for path in paths], 'levels': levels}
    assert [len(report['activities'][name]['levels']) for name in ACTIVITIES] == [23, 23, 29, 28]
    for activity in ACTIVITIES+['core']:
        folder = source/'src/core' if activity == 'core' else source/'src/activities'/activity
        for path in sorted(folder.rglob('*')):
            if path.is_file():
                report['source_files'][str(path.relative_to(source))] = hashlib.sha256(path.read_bytes()).hexdigest()
    return report


if __name__ == '__main__':
    print(json.dumps(inventory(), ensure_ascii=False, indent=2))
