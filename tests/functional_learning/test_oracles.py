# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from oracles import quantity


class VisibleIntegers(unittest.TestCase):
    def test_known_visible_examples(self):
        for text,expected in [('0',0),('9',9),('1 + 2',3),('4 + 4',8),('7 - 7',0),('9 - 2',7)]:
            with self.subTest(text=text):self.assertEqual(quantity(text),expected)

    def test_unexpected_notation_rejected(self):
        for text in ('1/2','one','1 + 2 + 3','1,2','', '__import__("os")'):
            with self.subTest(text=text),self.assertRaises(ValueError):quantity(text)
