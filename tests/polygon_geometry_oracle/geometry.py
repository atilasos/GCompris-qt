# SPDX-License-Identifier: GPL-3.0-or-later
"""Exact facts about ordered observed vertices; no instruction or game model."""
from fractions import Fraction


class InvalidPolygon(ValueError):
    """Vertices do not describe a simple, nondegenerate polygon."""


PROPERTIES = frozenset({'polygon', 'triangle', 'right_triangle', 'isosceles_triangle',
                        'quadrilateral', 'parallelogram', 'rectangle', 'square',
                        'rhombus', 'nonrectangular_parallelogram', 'nonsquare_rhombus'})


def _subtract(a, b):
    return a[0]-b[0], a[1]-b[1]


def _cross(a, b):
    return a[0]*b[1]-a[1]*b[0]


def _dot(a, b):
    return a[0]*b[0]+a[1]*b[1]


def _on_segment(a, b, p):
    return (_cross(_subtract(b, a), _subtract(p, a)) == 0
            and min(a[0], b[0]) <= p[0] <= max(a[0], b[0])
            and min(a[1], b[1]) <= p[1] <= max(a[1], b[1]))


def _intersects(a, b, c, d):
    ab, cd = _subtract(b, a), _subtract(d, c)
    first, second = _cross(ab, _subtract(c, a)), _cross(ab, _subtract(d, a))
    third, fourth = _cross(cd, _subtract(a, c)), _cross(cd, _subtract(b, c))
    return (first*second < 0 and third*fourth < 0
            or any(_on_segment(*edge, p) for edge, p in
                   [((a, b), c), ((a, b), d), ((c, d), a), ((c, d), b)]))


def classify(vertices):
    """Classify a boundary in its observed traversal order, closing implicitly.

    Coordinates must be integers or fractions, not booleans or floats. Convert
    observed snapped grid points to that exact grid before calling. Cyclic shifts
    and reversal preserve properties; arbitrary permutations can cross edges.
    """
    points = []
    for p in vertices:
        if (not isinstance(p, (tuple, list)) or len(p) != 2
                or any(isinstance(v, bool) or not isinstance(v, (int, Fraction)) for v in p)):
            raise InvalidPolygon('Expected exact integer or Fraction vertex pairs')
        points.append(tuple(p))
    n = len(points)
    if n < 3 or len(set(points)) != n:
        raise InvalidPolygon('At least three distinct vertices; do not repeat the closing vertex')
    edges = [_subtract(points[(i+1) % n], points[i]) for i in range(n)]
    if any(_cross(edges[i], edges[(i+1) % n]) == 0 for i in range(n)):
        raise InvalidPolygon('Consecutive collinear edges are degenerate')
    for i in range(n):
        for j in range(i+1, n):
            if j == i+1 or (i == 0 and j == n-1):
                continue
            if _intersects(points[i], points[(i+1) % n], points[j], points[(j+1) % n]):
                raise InvalidPolygon('Nonadjacent edges intersect or touch')
    signed_area2 = sum(_cross(points[i], points[(i+1) % n]) for i in range(n))
    if signed_area2 == 0:
        raise InvalidPolygon('Zero area')
    lengths = [_dot(edge, edge) for edge in edges]
    dots = [_dot(edges[i], edges[(i+1) % n]) for i in range(n)]
    parallel = [_cross(edges[i], edges[i+2]) == 0 for i in range(2)] if n == 4 else []
    properties = {'polygon'}
    if n == 3:
        properties.add('triangle')
        if 0 in dots:
            properties.add('right_triangle')
        if len(set(lengths)) <= 2:
            properties.add('isosceles_triangle')
    if n == 4:
        properties.add('quadrilateral')
        if all(parallel):
            properties.add('parallelogram')
        if all(value == 0 for value in dots):
            properties.add('rectangle')
        if len(set(lengths)) == 1:
            properties.add('rhombus')
        if 'rectangle' in properties and 'rhombus' in properties:
            properties.add('square')
        if 'parallelogram' in properties and 'rectangle' not in properties:
            properties.add('nonrectangular_parallelogram')
        if 'rhombus' in properties and 'square' not in properties:
            properties.add('nonsquare_rhombus')
    return {'properties': sorted(properties), 'vertex_count': n,
            'signed_area2': signed_area2, 'area2': abs(signed_area2),
            'simple': True, 'consecutive_collinear': False,
            'side_lengths_squared': lengths, 'adjacent_dot_products': dots,
            'opposite_parallel': parallel}


def satisfies(vertices, property_name):
    """Check an explicit geometric property, independently of Portuguese text."""
    if property_name not in PROPERTIES:
        raise ValueError('Unknown geometric property: '+str(property_name))
    return property_name in classify(vertices)['properties']
