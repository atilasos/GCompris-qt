# SPDX-License-Identifier: GPL-3.0-or-later
"""Visible geometry determines correspondence; signatures determine paint."""
from copy import deepcopy
import json
import math
from statistics import median


def _key(value):
    def valid(item):
        if item is None or type(item) in (str, bool, int):
            return True
        if type(item) is float:
            return math.isfinite(item)
        if type(item) is list:
            return all(valid(child) for child in item)
        if type(item) is dict:
            return all(type(key) is str and valid(child) for key, child in item.items())
        return False
    if not valid(value):
        raise ValueError('Opaque signature or palette id must be finite JSON')
    try:
        return json.dumps(value, sort_keys=True, separators=(',', ':'), allow_nan=False)
    except (TypeError, ValueError) as error:
        raise ValueError('Opaque signature or palette id must be finite JSON') from error


def _palette(samples):
    if not isinstance(samples, list):
        raise ValueError('Calibrated palette must be a list')
    paints = {}
    ids = set()
    for sample in samples:
        if not isinstance(sample, dict) or not {'signature', 'id'} <= sample.keys():
            raise ValueError('Every palette sample requires id and signature')
        signature = _key(sample['signature'])
        identity = _key(sample['id'])
        if signature in paints or identity in ids:
            raise ValueError('Ambiguous duplicate palette signature or id')
        paints[signature] = sample
        ids.add(identity)
    if not paints:
        raise ValueError('Empty calibrated palette')
    return paints


def _axis(values, cell_size):
    tolerance = cell_size * 1e-6
    groups = []
    for value in sorted(values):
        if not groups or value - groups[-1][0] > tolerance:
            groups.append([value])
        else:
            groups[-1].append(value)
    centers = [median(group) for group in groups]
    steps = [b - a for a, b in zip(centers, centers[1:])]
    if steps:
        step = median(steps)
        if min(steps) + tolerance < cell_size:
            raise ValueError('Overlapping visible cell geometry')
        if any(abs(value - step) > 2 * tolerance for value in steps):
            raise ValueError('Irregular visible grid geometry')
    return centers


def _grid(items):
    if not isinstance(items, list) or not items:
        raise ValueError('Visible grid must be a nonempty list')
    for item in items:
        if not isinstance(item, dict) or not isinstance(item.get('frame'), dict):
            raise ValueError('Each cell requires one nested visible frame')
        frame = item['frame']
        for key in ['x', 'y', 'width', 'height']:
            value = frame.get(key)
            if isinstance(value, bool) or not isinstance(value, (int, float)) or not math.isfinite(value):
                raise ValueError('Visible frame geometry must be finite numbers')
        if frame['width'] <= 0 or frame['height'] <= 0:
            raise ValueError('Visible frame dimensions must be positive')
    width = median(item['frame']['width'] for item in items)
    height = median(item['frame']['height'] for item in items)
    if any(abs(item['frame']['width'] - width) > width * 1e-6 or
           abs(item['frame']['height'] - height) > height * 1e-6 for item in items):
        raise ValueError('Visible grid cell dimensions are inconsistent')
    xs = _axis([item['frame']['x'] for item in items], width)
    ys = _axis([item['frame']['y'] for item in items], height)
    indexed = {}
    for item in items:
        frame = item['frame']
        columns = [i for i, x in enumerate(xs) if abs(x - frame['x']) <= width * 1e-6]
        rows = [i for i, y in enumerate(ys) if abs(y - frame['y']) <= height * 1e-6]
        if len(columns) != 1 or len(rows) != 1:
            raise ValueError('Ambiguous visible cell axis membership')
        coordinate = (rows[0], columns[0])
        if coordinate in indexed:
            raise ValueError('Duplicate visible grid cell')
        indexed[coordinate] = item
    if len(indexed) != len(xs) * len(ys):
        raise ValueError('Incomplete visible grid rectangle')
    return xs, ys, indexed


def plan(question_cells, answer_frames, palette_samples, mirror=False):
    """Return placements from public widget centers and painted signatures."""
    if type(mirror) is not bool:
        raise ValueError('Mirror must be an explicit public boolean mode')
    palette = _palette(palette_samples)
    qx, qy, question = _grid(question_cells)
    ax, ay, answer = _grid(answer_frames)
    if len(qx) != len(ax) or len(qy) != len(ay):
        raise ValueError('Question and answer visible grid dimensions differ')
    placements = []
    for row in range(len(qy)):
        for column in range(len(qx)):
            observed = question[row, column]
            if 'signature' not in observed:
                raise ValueError('Question cell has no observed signature')
            signature = _key(observed['signature'])
            if signature not in palette:
                raise ValueError('Observed signature has no calibrated palette sample')
            paint = palette[signature]
            placements.append({
                'question_frame': deepcopy(observed['frame']),
                'target_frame': deepcopy(answer[row, len(qx) - 1 - column if mirror else column]['frame']),
                'signature': deepcopy(observed['signature']),
                'palette_id': deepcopy(paint['id']),
            })
    return {'rows': len(qy), 'columns': len(qx), 'placements': placements,
            'diagnostics': {'method': 'visible regular grid and calibrated signatures'}}


def wrong_alternatives(placement, palette_samples):
    """Return every calibrated paint with a visibly different signature."""
    if not isinstance(placement, dict) or 'signature' not in placement:
        raise ValueError('Placement requires an observed signature')
    signature = _key(placement['signature'])
    palette = _palette(palette_samples)
    if signature not in palette:
        raise ValueError('Placement signature has no calibrated palette sample')
    alternatives = [deepcopy(sample['id']) for key, sample in palette.items()
                    if key != signature]
    if not alternatives:
        raise ValueError('No visibly different wrong alternative')
    return alternatives
