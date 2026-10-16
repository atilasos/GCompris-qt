#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Inventory source levels and actual SVG fills separately from UI solving."""
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]


def fills(path):
    tree = ET.parse(path)
    result = []
    for node in tree.iter():
        fill = node.get('fill')
        if fill:
            result.append(fill)
        match = re.search(r'(?:^|;)fill:([^;]+)', node.get('style', ''))
        if match:
            result.append(match[1])
    return dict(Counter(result))


def inventory():
    report = {'levels': {}, 'assets': {}, 'source_files': {}}
    for activity, filename in [('colors', 'colors.js'), ('advanced_colors', 'advanced_colors.js')]:
        source = (ROOT/'src/activities'/activity/filename).read_text()
        blocks = re.split(r'\[ // Level \d+[^\n]*', source)[1:]
        levels = []
        for block in blocks:
            paths = re.findall(r'"image": "qrc:/gcompris/([^"]+)"', block)
            levels.append(paths)
            for path in paths:
                report['assets'][path] = {'sha256': hashlib.sha256((ROOT/path).read_bytes()).hexdigest(), 'svg_fills': fills(ROOT/path)}
        report['levels'][activity] = levels
        if activity == 'advanced_colors':
            for path, color in re.findall(r'"image": "qrc:/gcompris/([^"]+)".*?//: Color (#[0-9A-Fa-f]{6})', source, re.S):
                report['assets'][path]['historical_comment_hex'] = color
    assert [len(row) for row in report['levels']['colors']] == [6, 8, 8]
    assert len(report['levels']['advanced_colors']) == 20 and all(len(row) == 8 for row in report['levels']['advanced_colors'])
    report['fawn_affected_levels'] = [index+1 for index, paths in enumerate(report['levels']['advanced_colors']) if any(path.endswith('/fawn_butterfly.svg') for path in paths)]
    assert report['fawn_affected_levels'] == [5, 12, 15, 16]
    report['mixing'] = {'levels': 6, 'questions_per_level': 6, 'representations': ['subtractive CMY', 'additive RGB']}
    for activity in ['colors', 'advanced_colors', 'color_mix', 'color_mix_light', 'core']:
        source = ROOT/'src/core' if activity == 'core' else ROOT/'src/activities'/activity
        for path in sorted(source.rglob('*')):
            if path.is_file():
                report['source_files'][str(path.relative_to(ROOT))] = hashlib.sha256(path.read_bytes()).hexdigest()
    report['scope'] = 'SVG fills are recorded as drawn, without certifying perceptual fidelity to historical hex comments or teacher approval.'
    return report


if __name__ == '__main__':
    print(json.dumps(inventory(), ensure_ascii=False, indent=2))
