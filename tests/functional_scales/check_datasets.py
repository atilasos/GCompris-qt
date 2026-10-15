#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Check content feasibility; never imported by the visible-information UI solver."""
from decimal import Decimal
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
EXPECTED = {'scalesboard': (8, 52, 223), 'scalesboard_weight': (6, 45, 222),
            'scalesboard_weight_avoirdupois': (6, 45, 221)}


def audit(root=ROOT):
    report = {}
    for activity, expected in EXPECTED.items():
        files = sorted((root / 'src/activities' / activity / 'resource').glob('*/Data.qml'))
        levels = puzzles = 0
        for path in files:
            source = path.read_text()
            rows = re.findall(r'"masses"\s*:(.*?)(?=\n\s*\})', source, re.S)
            assert len(rows) == source.count('"masses"'), path
            for index, row in enumerate(rows, 1):
                mass_text, rest = re.split(r'"targets"\s*:', row, maxsplit=1)
                target_text, rest = re.split(r'"rightDrop"\s*:', rest, maxsplit=1) if '"rightDrop"' in rest else (rest, '')
                # A message may precede rightDrop; only the first array is parsed.
                target_text = target_text.split('\n', 1)[0]
                numbers = lambda text: [Decimal(value) for value in re.findall(r'\[\s*(\d+(?:\.\d+)?)\s*,', text)]
                masses, targets = numbers(mass_text), numbers(target_text)
                match = re.search(r'"rightDrop"\s*:\s*(true|false)', row)
                assert masses and targets and match, (path, index)
                sides = (-1, 0, 1) if match[1] == 'true' else (0, 1)
                reachable = {Decimal(0)}
                for value in masses:
                    reachable = {previous + side * value for previous in reachable for side in sides}
                missing = sorted(set(targets) - reachable)
                assert not missing, f'{path.relative_to(root)} row {index}: unreachable {missing}; masses={masses}'
                levels += 1
                puzzles += len(targets)
        assert (len(files), levels, puzzles) == expected, (activity, len(files), levels, puzzles)
        report[activity] = {'datasets': len(files), 'levels': levels, 'targets_reachable': puzzles}
    return report


if __name__ == '__main__':
    print(json.dumps(audit(), indent=2))
