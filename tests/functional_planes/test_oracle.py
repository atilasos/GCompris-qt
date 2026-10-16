# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from oracle import sequence


class VisibleSequenceOrder(unittest.TestCase):
    def test_numbers_include_both_range_endpoints_without_hidden_prompt(self):
        self.assertEqual(sequence('planegame',1), ['0','1','2','3','4','5','6','7','8','9','10'])
        self.assertEqual(sequence('planegame',4), ['10','11','12','13','14','15','16','17','18','19','20'])

    def test_parity_is_independent_integer_arithmetic(self):
        self.assertEqual(sequence('numbers-odd-even',3), ['0','2','4','6','8','10','12','14','16','18','20'])
        self.assertEqual(sequence('numbers-odd-even',2), ['1','3','5','7','9','11','13','15','17','19'])

    def test_portuguese_alphabet_has_26_letters_including_k_w_y(self):
        self.assertEqual(''.join(sequence('alphabet-sequence',1)), 'abcdefghijklmnopqrstuvwxyz')
        self.assertEqual(''.join(sequence('alphabet-sequence',4)), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')
