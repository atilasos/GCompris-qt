# SPDX-License-Identifier: GPL-3.0-or-later
from pathlib import Path
import sys
import unittest
from PIL import Image
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from painting_rectangular_solver import solve, solve_observed, AmbiguousPuzzle, UnsupportedPuzzle, SearchLimit


def framed_pair():
    # Literal RGB columns: true interior join is green; external frames are black.
    black, red, green, blue = (0, 0, 0), (220, 20, 20), (20, 180, 20), (20, 20, 220)
    left_columns = [black] + [red] * 7 + [green] * 8
    right_columns = [green] * 8 + [blue] * 7 + [black]
    result = {}
    for key, columns in [('opaque-Z', right_columns), ('opaque-A', left_columns)]:
        image = Image.new('RGB', (16, 16))
        image.putdata(columns * 16)
        result[key] = image
    return result


class RectangularPixels(unittest.TestCase):
    def test_dark_frame_does_not_win_over_interior_continuity(self):
        result = solve(framed_pair(), [(8, 8), (24, 8)], (32, 16))
        self.assertEqual(result['mapping'], {'opaque-A': 0, 'opaque-Z': 1})
        self.assertEqual([row['width'] for row in result['diagnostics']['strips']], [2, 4, 8])

    def test_renamed_reordered_ids_and_slot_order_do_not_supply_answers(self):
        pair = framed_pair()
        renamed = {77: pair['opaque-A'], -99: pair['opaque-Z']}
        self.assertEqual(solve(renamed, [(24, 8), (8, 8)], (32, 16))['mapping'],
                         {77: 1, -99: 0})

    def test_tied_pixels_are_refused(self):
        image = Image.new('RGB', (16, 16), 'white')
        with self.assertRaises(AmbiguousPuzzle):
            solve({'one': image, 'two': image}, [(8, 8), (24, 8)], (32, 16))

    def test_inconsistent_strip_minima_are_refused(self):
        images = {}
        for key, columns in [('a', [0, 0, 255, 255, 255, 255, 255, 255]+[100]*8),
                             ('b', [110]*8+[0]*8)]:
            im = Image.new('RGB', (16, 16))
            im.putdata([(v, v, v) for v in columns]*16)
            images[key] = im
        with self.assertRaisesRegex(AmbiguousPuzzle, 'minima disagree'):
            solve(images, [(8, 8), (24, 8)], (32, 16))

    def test_outside_domain_and_budget_are_refused(self):
        pair = framed_pair()
        transparent = {k: v.convert('RGBA') for k, v in pair.items()}
        transparent['opaque-A'].putpixel((0, 0), (0, 0, 0, 254))
        cases = [(transparent, [(8, 8), (24, 8)], (32, 16), {}),
                 (pair, [(8, 8), (8, 8)], (32, 16), {}),
                 (pair, [(8, 8), (80, 8)], (96, 16), {}),
                 (pair, [(8, 8), (24, 8)], (15, 16), {}),
                 (pair, [(8, 8), (float('nan'), 8)], (32, 16), {}),
                 ({i: Image.new('RGB', (16, 16)) for i in range(9)},
                  [(i*16+8, 8) for i in range(9)], (144, 16), {}),
                 (pair, [(8, 8), (24, 8)], (32, 16), {'max_permutations': True})]
        for images, slots, canvas, params in cases:
            with self.subTest(slots=slots, params=params), self.assertRaises(UnsupportedPuzzle):
                solve(images, slots, canvas, **params)
        with self.assertRaises(SearchLimit):
            solve(pair, [(8, 8), (24, 8)], (32, 16), max_permutations=1)

    def test_public_calibration_and_image_set_are_checked(self):
        pair = framed_pair()
        frame = {'x': 116, 'y': 108, 'width': 32, 'height': 16}
        board = {'level': 20, 'frame': frame, 'pages': [[{'source': k} for k in pair]],
                 'drawnCircles': [{'x': 108, 'y': 108}, {'x': 124, 'y': 108}]}
        cal = {'level': 20, 'frame': dict(frame),
               'placed': {'source': 'opaque-Z', 'width': 16, 'height': 16}}
        self.assertEqual(solve_observed(pair, board, cal)['mapping'],
                         {'opaque-A': 0, 'opaque-Z': 1})
        for changed in [dict(cal, level=21), dict(cal, frame=dict(frame, width=33)),
                        dict(cal, placed=dict(cal['placed'], height=17))]:
            with self.subTest(changed=changed), self.assertRaises(UnsupportedPuzzle):
                solve_observed(pair, board, changed)
        with self.assertRaises(UnsupportedPuzzle):
            solve_observed({'opaque-A': pair['opaque-A']}, board, cal)


if __name__ == '__main__':
    unittest.main()
