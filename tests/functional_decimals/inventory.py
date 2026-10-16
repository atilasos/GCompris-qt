#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Inspect checked-in decimal/quantity datasets without the activity generator."""
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
ACTIVITIES = ['learn_decimals', 'learn_decimals_additions', 'learn_decimals_subtractions', 'learn_quantities']


def inventory():
    result = {}
    for activity in ACTIVITIES:
        datasets = []
        for path in sorted((ROOT / 'src/activities' / activity / 'resource').glob('*/Data.qml'), key=lambda p: int(p.parent.name)):
            source = re.sub(r'/\*.*?\*/|//[^\n]*', '', path.read_text(), flags=re.S)
            start = re.search(r'\bdata\s*:\s*\[', source).end() - 1
            depth, end = 1, start + 1
            while depth:
                if source[end] == '[': depth += 1
                elif source[end] == ']': depth -= 1
                end += 1
            levels = json.loads(re.sub(r',\s*([}\]])', r'\1', source[start:end]))
            datasets.append({'id': path.parent.name, 'levels': levels, 'sublevels': sum(len(level['subLevels']) for level in levels)})
        result[activity] = datasets
    return result


if __name__ == '__main__':
    print(json.dumps(inventory(), indent=2))
