# SPDX-License-Identifier: GPL-3.0-or-later
"""Locate a visible image detail using only its opaque pixels and the picture."""
from PIL import Image, ImageChops, ImageMath


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
