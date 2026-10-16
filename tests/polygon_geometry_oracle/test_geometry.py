# SPDX-License-Identifier: GPL-3.0-or-later
import itertools
from fractions import Fraction
from pathlib import Path
import sys
import unittest
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from polygon_geometry_oracle import classify, satisfies, InvalidPolygon


class GeometricFacts(unittest.TestCase):
    def test_rotated_rectangle_uses_angles_instead_of_axis_alignment(self):
        # Adjacent vectors (3,4),(-8,6): dot0, unequal lengths25 and100.
        facts = classify([(1, 1), (4, 5), (-4, 11), (-7, 7)])
        self.assertIn('rectangle', facts['properties'])
        self.assertNotIn('square', facts['properties'])
        self.assertEqual(facts['area2'], 100)
        self.assertEqual(facts['side_lengths_squared'], [25, 100, 25, 100])
        self.assertEqual(facts['adjacent_dot_products'], [0, 0, 0, 0])
        self.assertEqual(facts['opposite_parallel'], [True, True])

    def test_literal_positive_and_negative_shape_properties(self):
        # These fixtures are independent of the proposer and any game dataset.
        fixtures = [
            ([(0, 0), (4, 0), (0, 3)], {'polygon', 'triangle', 'right_triangle'}),
            ([(0, 0), (6, 0), (3, 4)], {'polygon', 'triangle', 'isosceles_triangle'}),
            ([(0, 0), (5, 0), (2, 3)], {'polygon', 'triangle'}),
            ([(0, 0), (4, 0), (3, 2), (1, 2)], {'polygon', 'quadrilateral'}),
            ([(0, 0), (4, 0), (4, 2), (0, 2)],
             {'polygon', 'quadrilateral', 'parallelogram', 'rectangle'}),
            ([(0, 0), (3, 0), (3, 3), (0, 3)],
             {'polygon', 'quadrilateral', 'parallelogram', 'rectangle', 'rhombus', 'square'}),
            ([(0, 0), (4, 0), (6, 3), (2, 3)],
             {'polygon', 'quadrilateral', 'parallelogram', 'nonrectangular_parallelogram'}),
            ([(0, 0), (2, -3), (4, 0), (2, 3)],
             {'polygon', 'quadrilateral', 'parallelogram', 'rhombus',
              'nonrectangular_parallelogram', 'nonsquare_rhombus'}),
            ([(0, 0), (4, 0), (4, 4), (2, 1), (0, 4)], {'polygon'}),
        ]
        for vertices, expected in fixtures:
            with self.subTest(vertices=vertices):
                self.assertEqual(set(classify(vertices)['properties']), expected)
                # Test every named property, including wrong-but-valid shapes.
                for name in ['polygon', 'triangle', 'right_triangle', 'isosceles_triangle',
                             'quadrilateral', 'rectangle', 'square', 'parallelogram',
                             'rhombus', 'nonrectangular_parallelogram', 'nonsquare_rhombus']:
                    self.assertEqual(satisfies(vertices, name), name in expected)

    def test_degenerate_crossing_touching_or_inexact_input_is_refused(self):
        cases = [[], [(0, 0), (1, 1)], [(0, 0), (1, 1), (2, 2)],
                 [(0, 0), (4, 0), (4, 3), (0, 0)],
                 [(0, 0), (1, 0), (3, 0), (3, 3), (0, 3)],
                 [(0, 0), (4, 4), (0, 4), (4, 0)],
                 # Nonzero signed area does not make a crossing polygon simple.
                 [(0, 0), (4, 3), (0, 4), (3, 0)],
                 # A nonadjacent edge touches a vertex without a proper crossing.
                 [(0, 0), (4, 0), (2, 2), (2, 0), (0, 3)],
                 [(False, 0), (4, 0), (0, 3)], [(0.0, 0), (4, 0), (0, 3)],
                 [(0, 0), (float('nan'), 0), (0, 3)],
                 [(0, 0), (4,), (0, 3)]]
        for vertices in cases:
            with self.subTest(vertices=vertices), self.assertRaises(InvalidPolygon):
                classify(vertices)
        with self.assertRaises(ValueError):
            satisfies([(0, 0), (4, 0), (0, 3)], 'triangle-ish')

    def test_cyclic_reversal_translation_and_rational_scale_preserve_properties(self):
        points = [(0, 0), (3, 4), (-5, 10), (-8, 6)]
        expected = set(classify(points)['properties'])
        for reverse in (False, True):
            order = points[::-1] if reverse else points
            for start in range(4):
                reordered = order[start:]+order[:start]
                for scale in (2, -3, Fraction(1, 3)):
                    transformed = [(x*scale+17, y*scale-23) for x, y in reordered]
                    facts = classify(transformed)
                    self.assertEqual(set(facts['properties']), expected)
                    self.assertEqual(facts['area2'], 100*scale*scale)

    def test_vertex_permutations_do_not_silently_reorder_a_crossing_boundary(self):
        points = [(0, 0), (3, 0), (3, 3), (0, 3)]
        accepted = rejected = 0
        for permutation in itertools.permutations(points):
            try:
                facts = classify(permutation)
            except InvalidPolygon:
                rejected += 1
            else:
                accepted += 1
                self.assertIn('square', facts['properties'])
        self.assertEqual((accepted, rejected), (8, 16))


if __name__ == '__main__':
    unittest.main()
