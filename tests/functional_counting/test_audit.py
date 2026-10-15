# SPDX-License-Identifier: GPL-3.0-or-later
from pathlib import Path
import unittest
from audit import validate_visual, validate_fruit

ROOT = Path(__file__).resolve().parents[2]


class CountingReceipts(unittest.TestCase):
    def test_visible_die_is_checked_from_svg_not_its_filename_number(self):
        row = {'source': 'qrc:/gcompris/src/activities/smallnumbers/resource/dice6.svg', 'count': 6}
        self.assertEqual(validate_visual(row, ROOT), 6)
        row['count'] = 5
        with self.assertRaises(AssertionError):
            validate_visual(row, ROOT)

    def test_roman_sides_and_total_are_independently_parsed(self):
        row = {'parts': [{'label': 'IV', 'count': 4}, {'label': 'II', 'count': 2}], 'count': 6}
        self.assertEqual(validate_visual(row, ROOT), 6)
        row['count'] = 5
        with self.assertRaises(AssertionError):
            validate_visual(row, ROOT)

    def test_a_claimed_domino_side_cannot_disagree_with_its_visible_label(self):
        row = {'parts': [{'label': '3', 'count': 4}, {'dots': 2}], 'count': 6}
        with self.assertRaises(AssertionError):
            validate_visual(row, ROOT)

    def test_drawn_objects_are_counted_again_for_each_answer(self):
        row = {'pictures': ['apple', 'pear', 'apple'], 'answers': [{'source': 'apple', 'count': 2}, {'source': 'pear', 'count': 1}]}
        self.assertEqual(validate_fruit(row), 3)
        row['answers'][0]['count'] = 3
        with self.assertRaises(AssertionError):
            validate_fruit(row)
