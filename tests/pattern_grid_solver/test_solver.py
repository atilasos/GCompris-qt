# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from pattern_grid_solver import plan


def cell(x, y, signature, width=10, height=10):
    return {'frame': {'x': x, 'y': y, 'width': width, 'height': height},
            'signature': signature}


def target(x, y, width=20, height=20):
    return {'frame': {'x': x, 'y': y, 'width': width, 'height': height}}


class VisibleGridPlanning(unittest.TestCase):
    def test_translated_scaled_grid_matches_opaque_painted_palette(self):
        question = [cell(5, 5, '#33ffffff'), cell(15, 5, 'blue'),
                    cell(5, 15, 'blue'), cell(15, 15, '#33ffffff')]
        answer = [target(110, 60), target(130, 60),
                  target(110, 80), target(130, 80)]
        palette = [{'id': 'paint-b', 'signature': 'blue'},
                   {'id': 'paint-a', 'signature': '#33ffffff'}]
        result = plan(question, answer, palette)
        self.assertEqual((result['rows'], result['columns']), (2, 2))
        self.assertEqual([(p['target_frame']['x'], p['target_frame']['y'],
                           p['palette_id']) for p in result['placements']],
                         [(110, 60, 'paint-a'), (130, 60, 'paint-b'),
                          (110, 80, 'paint-b'), (130, 80, 'paint-a')])
        self.assertEqual(result['placements'][0]['signature'], '#33ffffff')


    def test_mirror_flips_only_columns_with_regular_margins_and_permuted_lists(self):
        question = [cell(3, 7, 'a', 8, 6), cell(14, 7, 'b', 8, 6),
                    cell(25, 7, 'c', 8, 6), cell(3, 16, 'c', 8, 6),
                    cell(14, 16, 'a', 8, 6), cell(25, 16, 'b', 8, 6)]
        answer = [target(110, 40, 18, 12), target(135, 40, 18, 12),
                  target(160, 40, 18, 12), target(110, 57, 18, 12),
                  target(135, 57, 18, 12), target(160, 57, 18, 12)]
        palette = [{'id': 90, 'signature': 'c'}, {'id': 17, 'signature': 'a'},
                   {'id': 4, 'signature': 'b'}]
        result = plan(question, answer, palette, mirror=True)
        self.assertEqual([(p['target_frame']['x'], p['target_frame']['y'],
                           p['palette_id']) for p in result['placements']],
                         [(160, 40, 17), (135, 40, 4), (110, 40, 90),
                          (160, 57, 90), (135, 57, 17), (110, 57, 4)])
        self.assertEqual(plan([question[i] for i in [4, 2, 5, 0, 3, 1]],
                              [answer[i] for i in [3, 0, 5, 1, 4, 2]],
                              list(reversed(palette)), mirror=True), result)


    def test_paint_requires_one_unambiguous_calibrated_palette_match(self):
        question = [cell(0, 0, 'a'), cell(10, 0, 'b')]
        answer = [target(0, 0), target(20, 0)]
        invalid = [
            [{'id': 1, 'signature': 'a'}],
            [{'id': 1, 'signature': 'a'}, {'id': 2, 'signature': 'a'},
             {'id': 3, 'signature': 'b'}],
            [{'id': 1, 'signature': 'a'}, {'id': 1, 'signature': 'b'}],
        ]
        for palette in invalid:
            with self.subTest(palette=palette):
                with self.assertRaisesRegex(ValueError, 'palette'):
                    plan(question, answer, palette)


    def test_duplicate_missing_irregular_or_invalid_visible_geometry_is_refused(self):
        square = [cell(5, 5, 'a'), cell(15, 5, 'a'),
                  cell(5, 15, 'a'), cell(15, 15, 'a')]
        answer = [target(10, 10), target(30, 10),
                  target(10, 30), target(30, 30)]
        palette = [{'id': 'paint', 'signature': 'a'}]
        invalid = [
            (square + [cell(5, 5, 'a')], answer),
            (square[:3], answer),
            ([cell(0, 0, 'a'), cell(10, 0, 'a'), cell(25, 0, 'a')],
             [target(0, 0), target(20, 0), target(40, 0)]),
            (square, [target(0, 0), target(20, 0), target(40, 0), target(60, 0)]),
            ([cell(0, 0, 'a', width=0)], [target(0, 0)]),
            ([cell(float('nan'), 0, 'a')], [target(0, 0)]),
            ([cell(0, float('inf'), 'a')], [target(0, 0)]),
            ([cell(0, 0, 'a'), cell(5, 0, 'a')], [target(0, 0), target(20, 0)]),
            ([cell(0, 0, 'a'), cell(10, 0, 'a', width=9)],
             [target(0, 0), target(20, 0)]),
            ([], []),
        ]
        for question, edit in invalid:
            with self.subTest(question=question, edit=edit):
                with self.assertRaises(ValueError):
                    plan(question, edit, palette)


    def test_wrong_alternatives_list_all_distinct_visible_paints_without_guessing(self):
        from pattern_grid_solver import wrong_alternatives
        palette = [{'id': 'white', 'signature': '#33ffffff'},
                   {'id': 'red', 'signature': '#ffff0000'},
                   {'id': 'blue', 'signature': '#ff0000ff'}]
        placement = {'signature': '#33ffffff', 'palette_id': 'white'}
        self.assertEqual(set(wrong_alternatives(placement, palette)), {'red', 'blue'})
        self.assertEqual(set(wrong_alternatives(placement, list(reversed(palette)))),
                         {'red', 'blue'})
        with self.assertRaisesRegex(ValueError, 'alternative'):
            wrong_alternatives(placement, palette[:1])


    def test_boundary_requires_nested_frames_finite_json_and_explicit_mirror(self):
        question = [cell(0, 0, 'a')]
        answer = [target(20, 30)]
        palette = [{'id': 'paint', 'signature': 'a'}]
        cases = [
            lambda: plan(question, answer, palette, mirror=1),
            lambda: plan(question, answer, palette, mirror='false'),
            lambda: plan(question, answer, None),
            lambda: plan(question, answer, [{'id': 1}]),
            lambda: plan([{'frame': question[0]['frame']}], answer, palette),
            lambda: plan([{'x': 0, 'y': 0, 'width': 10, 'height': 10,
                           'signature': 'a'}], answer, palette),
            lambda: plan([cell(0, 0, (1, 2, 3))], answer,
                         [{'id': 'paint', 'signature': (1, 2, 3)}]),
        ]
        for operation in cases:
            with self.subTest(operation=operation):
                with self.assertRaises(ValueError):
                    operation()

    def test_json_signature_types_and_nested_values_are_preserved_without_mutation(self):
        import copy
        question = [cell(0, 0, True), cell(10, 0, 1),
                    cell(20, 0, {'rgb': [7, 8, 9], 'alpha': None})]
        answer = [target(30, 40), target(50, 40), target(70, 40)]
        palette = [{'id': 'bool', 'signature': True},
                   {'id': 'number', 'signature': 1},
                   {'id': ['opaque', 77], 'signature': {'alpha': None, 'rgb': [7, 8, 9]}}]
        original = copy.deepcopy((question, answer, palette))
        result = plan(question, answer, palette)
        self.assertEqual([p['palette_id'] for p in result['placements']],
                         ['bool', 'number', ['opaque', 77]])
        result['placements'][2]['signature']['rgb'][0] = 999
        result['placements'][2]['palette_id'][0] = 'changed'
        self.assertEqual((question, answer, palette), original)


if __name__ == '__main__':
    unittest.main()
