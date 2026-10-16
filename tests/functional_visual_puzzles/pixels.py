# SPDX-License-Identifier: GPL-3.0-or-later
"""Locate a visible image detail using only its opaque pixels and the picture."""
from PIL import Image, ImageChops, ImageMath


def difference_points(left, right, threshold=25):
    if left.size != right.size:
        raise ValueError('Visible pictures must have matching dimensions')
    difference = ImageChops.difference(left.convert('RGB'), right.convert('RGB'))
    pixels = difference.load()
    remaining = {(x, y) for y in range(left.height) for x in range(left.width)
                 if max(pixels[x, y]) > threshold}
    regions = []
    while remaining:
        first = min(remaining, key=lambda point: (point[1], point[0]))
        remaining.remove(first)
        pending = [first]
        component = []
        while pending:
            x, y = pending.pop()
            component.append((x, y))
            for dx, dy in [(-1, -1), (0, -1), (1, -1), (-1, 0),
                           (1, 0), (-1, 1), (0, 1), (1, 1)]:
                neighbour = (x + dx, y + dy)
                if neighbour in remaining:
                    remaining.remove(neighbour)
                    pending.append(neighbour)
        xs, ys = zip(*component)
        center = (sum(xs) / len(xs), sum(ys) / len(ys))
        strongest = max(max(pixels[x, y]) for x, y in component)
        point = min((p for p in component if max(pixels[p]) == strongest),
                    key=lambda p: ((p[0] - center[0]) ** 2 + (p[1] - center[1]) ** 2, p[1], p[0]))
        regions.append({'box': [min(xs), min(ys), max(xs) + 1, max(ys) + 1],
                        'pixel': list(point), 'pixels': len(component),
                        'peak_difference': strongest, 'threshold': threshold})
    return regions


def locate_detail(piece, background):
    piece = piece.convert('RGBA')
    background = background.convert('RGB')
    width = background.width - piece.width + 1
    height = background.height - piece.height + 1
    if min(width, height) <= 0:
        raise ValueError('Detail must fit inside the visible picture')
    samples = [(x, y, piece.getpixel((x, y))[:3])
               for y in range(0, piece.height, max(1, piece.height // 7))
               for x in range(0, piece.width, max(1, piece.width // 7))
               if piece.getpixel((x, y))[3] >= 240]
    if not samples:
        raise ValueError('No opaque detail pixels')
    errors = Image.new('I', (width, height), 0)
    for x, y, color in samples:
        field = background.crop((x, y, x + width, y + height))
        difference = ImageChops.difference(field, Image.new('RGB', field.size, color)).convert('L')
        errors = ImageMath.lambda_eval(lambda values: values['sum'] + values['next'],
                                      sum=errors, next=difference.convert('I'))
    minimum = errors.getextrema()[0]
    candidates = [(x, y) for y in range(height) for x in range(width)
                  if errors.getpixel((x, y)) == minimum]
    if len(candidates) != 1:
        raise ValueError('Visible detail has multiple equally good locations')
    x, y = candidates[0]
    return {'top_left': [x, y], 'pixel_box': [x, y, x + piece.width, y + piece.height],
            'mean_sample_error': minimum / len(samples), 'sample_count': len(samples),
            'equal_minima': len(candidates)}
