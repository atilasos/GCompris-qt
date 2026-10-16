#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Check every authored path grid independently of the activity engine."""
import ast
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
ACTIVITIES = ['path_encoding', 'path_encoding_relative', 'path_decoding', 'path_decoding_relative']


def matrices(text):
    result = []
    for match in re.finditer(r'\bpath\s*:\s*\[', text):
        start = match.end() - 1
        depth = 0
        for end in range(start, len(text)):
            depth += (text[end] == '[') - (text[end] == ']')
            if depth == 0:
                result.append(ast.literal_eval(text[start:end + 1]))
                break
        else:
            raise ValueError('Unclosed path matrix')
    if not result: raise ValueError('No authored path matrices')
    return result


def validate(matrix):
    rows = len(matrix)
    assert rows > 0
    cols = len(matrix[0])
    assert cols > 0 and all(len(row) == cols for row in matrix)
    allowed = set('.*SEIRTBGW')
    assert all(isinstance(cell, str) and len(cell) == 1 and cell.upper() in allowed
               for row in matrix for cell in row)
    starts = [(x, y) for y, row in enumerate(matrix) for x, c in enumerate(row) if c.upper() == 'S']
    ends = [(x, y) for y, row in enumerate(matrix) for x, c in enumerate(row) if c.upper() == 'E']
    assert len(starts) == len(ends) == 1
    path = {(x, y) for y, row in enumerate(matrix) for x, c in enumerate(row) if c.upper() in '*SE'}
    graph = {}
    for cell in path:
        x, y = cell
        neighbors = [(x+dx, y+dy) for dx, dy in [(0,-1),(1,0),(0,1),(-1,0)] if (x+dx, y+dy) in path]
        assert len(neighbors) == (1 if cell in starts + ends else 2), 'Path must have no forks or dead ends'
        graph[cell] = neighbors
    seen, queue = {starts[0]}, [starts[0]]
    for cell in queue:
        for neighbor in graph[cell]:
            if neighbor not in seen: seen.add(neighbor); queue.append(neighbor)
    assert seen == path, 'All path cells belong to the unique start-to-flag route'
    return {'rows': rows, 'columns': cols, 'cells': len(path), 'moves': len(path) - 1}


def inventory():
    activities = {}
    for activity in ACTIVITIES:
        files = sorted((ROOT / 'src/activities' / activity / 'resource').glob('*/Data.qml'))
        assert len(files) == 4
        levels = []
        for file in files:
            text = file.read_text()
            dimensions = [int(x) for x in re.findall(r'\.arg\((\d+)\)', text)]
            assert len(dimensions) == 2
            for matrix in matrices(text):
                row = validate(matrix)
                assert [row['columns'], row['rows']] == dimensions
                levels.append(dict(row, source=str(file.relative_to(ROOT)), source_sha256=hashlib.sha256(file.read_bytes()).hexdigest()))
        assert len(levels) == 7
        activities[activity] = levels
    return {'passed': True, 'activities': activities, 'levels': sum(map(len, activities.values()))}


if __name__ == '__main__':
    print(json.dumps(inventory(), indent=2))
