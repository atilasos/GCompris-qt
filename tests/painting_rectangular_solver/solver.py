# SPDX-License-Identifier: GPL-3.0-or-later
"""Bounded RGB-strip inference for opaque, unrotated rectangular grid pieces."""
import itertools
import math


class UnsupportedPuzzle(ValueError):
    """The public geometry or pixels lie outside this solver's narrow domain."""


class AmbiguousPuzzle(ValueError):
    """Pixel minima tie or disagree across strip widths."""


class SearchLimit(ValueError):
    """The explicit arrangement budget cannot certify the finite search."""


def solve(images_by_id, slots, canvas_size, *, max_permutations=40320):
    """Return opaque ID -> supplied slot index only if all strip minima agree.

    Slots and canvas use native image pixels, derived from public widget sizes.
    IDs are labels only. No rotation, alpha puzzle, missing cell, or >8 pieces.
    """
    if (not isinstance(max_permutations, int) or isinstance(max_permutations, bool)
            or not 1 <= max_permutations <= 40320):
        raise UnsupportedPuzzle('Permutation budget must be an integer from 1 to 40320')
    count = len(images_by_id)
    if not 2 <= count <= 8 or len(slots) != count:
        raise UnsupportedPuzzle('Expected 2 to 8 pieces and equally many visible slots')
    if len(canvas_size) != 2 or not all(math.isfinite(v) and v > 0 for v in canvas_size):
        raise UnsupportedPuzzle('Positive finite canvas required')
    if any(len(p) != 2 or not all(math.isfinite(v) for v in p) for p in slots):
        raise UnsupportedPuzzle('Finite visible slot pairs required')
    xs = sorted(set(p[0] for p in slots))
    ys = sorted(set(p[1] for p in slots))
    if len(xs) * len(ys) != count or len(set(map(tuple, slots))) != count:
        raise UnsupportedPuzzle('Visible slots must form a complete rectangular grid')
    for values in (xs, ys):
        if len(values) > 2:
            steps = [b-a for a, b in zip(values, values[1:])]
            if max(steps)-min(steps) > max(2, min(steps)*.02):
                raise UnsupportedPuzzle('Visible grid spacing is not regular')
    ids = list(images_by_id)
    images = [images_by_id[key].convert('RGBA') for key in ids]
    widths, heights = [im.width for im in images], [im.height for im in images]
    if min(widths + heights) < 16 or max(widths)-min(widths) > 2 or max(heights)-min(heights) > 2:
        raise UnsupportedPuzzle('Comparable rectangular dimensions of at least 16 pixels required')
    if any(im.getchannel('A').getextrema() != (255, 255) for im in images):
        raise UnsupportedPuzzle('Only fully opaque rectangular pieces are supported')
    for values, sizes in [(xs, widths), (ys, heights)]:
        if len(values) > 1 and any(abs((b-a)-sum(sizes)/count) > max(3, min(sizes)*.02)
                                   for a, b in zip(values, values[1:])):
            raise UnsupportedPuzzle('Image dimensions do not match visible grid pitch')
    if any(x-min(widths)/2 < -2 or y-min(heights)/2 < -2
           or x+max(widths)/2 > canvas_size[0]+2
           or y+max(heights)/2 > canvas_size[1]+2 for x, y in slots):
        raise UnsupportedPuzzle('Visible placements fall outside the canvas')
    total = math.factorial(count)
    if total > max_permutations:
        raise SearchLimit(f'{total} arrangements exceed budget {max_permutations}')
    position = {tuple(p): i for i, p in enumerate(slots)}
    grid = [[position[(x, y)] for x in xs] for y in ys]
    neighbors = [(row[c], row[c+1], 'horizontal') for row in grid for c in range(len(xs)-1)]
    neighbors += [(grid[r][c], grid[r+1][c], 'vertical')
                  for r in range(len(ys)-1) for c in range(len(xs))]
    diagnostics = []
    agreed = None
    for strip in (2, 4, 8):
        edge = {}
        for i, im in enumerate(images):
            pixels = im.load()
            for side in ('left', 'right', 'top', 'bottom'):
                if side in ('left', 'right'):
                    xx = range(strip) if side == 'left' else range(im.width-strip, im.width)
                    edge[i, side] = [[sum(pixels[x, y][k] for x in xx)/strip for k in range(3)]
                                     for y in range(im.height)]
                else:
                    yy = range(strip) if side == 'top' else range(im.height-strip, im.height)
                    edge[i, side] = [[sum(pixels[x, y][k] for y in yy)/strip for k in range(3)]
                                     for x in range(im.width)]
        costs = {}
        for i, j in itertools.permutations(range(count), 2):
            for axis, first, second in [('horizontal', 'right', 'left'), ('vertical', 'bottom', 'top')]:
                u, v = edge[i, first], edge[j, second]
                costs[i, j, axis] = sum((a[k]-b[k])**2 for a, b in zip(u, v)
                                       for k in range(3))/(min(len(u), len(v))*3)
        ranked = sorted((sum(costs[order[a], order[b], axis] for a, b, axis in neighbors), order)
                        for order in itertools.permutations(range(count)))
        best, order = ranked[0]
        runner_up = ranked[1][0]
        if math.isclose(best, runner_up, rel_tol=1e-12, abs_tol=1e-9):
            raise AmbiguousPuzzle(f'Tied minimum for {strip}-pixel strips')
        if agreed is not None and order != agreed:
            raise AmbiguousPuzzle('Strip minima disagree')
        agreed = order
        diagnostics.append({'width': strip, 'cost': best, 'runner_up_cost': runner_up})
    return {'mapping': {ids[piece]: slot for slot, piece in enumerate(agreed)},
            'diagnostics': {'method': 'unanimous RGB edge-strip minima', 'strips': diagnostics,
                            'permutations_per_strip': total, 'max_permutations': max_permutations,
                            'adjacencies': len(neighbors), 'grid': [len(xs), len(ys)]}}


def solve_observed(images_by_source, board, calibration, **params):
    """Convert only public frame/centres and neutral size calibration to pixels."""
    if board['level'] != calibration['level']:
        raise UnsupportedPuzzle('Calibration belongs to another visible board')
    frame = board['frame']
    if any(not math.isfinite(frame[k]) or abs(frame[k]-calibration['frame'][k]) > 1e-6
           for k in ('x', 'y', 'width', 'height')):
        raise UnsupportedPuzzle('Visible frames differ or are nonfinite')
    expected = {piece['source'] for page in board['pages'] for piece in page}
    if set(images_by_source) != expected:
        raise UnsupportedPuzzle('Image set differs from publicly exposed pieces')
    placed = calibration['placed']
    if placed['source'] not in images_by_source:
        raise UnsupportedPuzzle('Calibration image is not exposed')
    image = images_by_source[placed['source']]
    scale = placed['width']/image.width
    vertical = placed['height']/image.height
    if not math.isfinite(scale) or scale <= 0 or not math.isfinite(vertical) or abs(scale-vertical) > scale*1e-6:
        raise UnsupportedPuzzle('Neutral size calibration is not a uniform positive scale')
    canvas = (frame['width']/scale, frame['height']/scale)
    left, top = frame['x']-frame['width']/2, frame['y']-frame['height']/2
    slots = [((circle['x']-left)/scale, (circle['y']-top)/scale)
             for circle in board['drawnCircles']]
    result = solve(images_by_source, slots, canvas, **params)
    result['geometry'] = {'scale': scale, 'canvas_size': list(canvas),
                          'visible_slots_in_canvas_pixels': slots,
                          'position_semantics': 'public centres; calibration destination unused'}
    return result
