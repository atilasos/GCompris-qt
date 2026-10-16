# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from oracle import compare,adjacent


class VisibleArithmetic(unittest.TestCase):
    def test_comparison_uses_portuguese_decimal_places(self):
        self.assertEqual(compare('0,10','0,2'),'<')
        self.assertEqual(compare('2,0','2,00'),'=')
        self.assertEqual(compare('−1,5','-1,6'),'>')

    def test_adjacent_anchors_cross_zero(self):
        self.assertEqual(adjacent([None,None,0,None]),[-2,-1,0,1])

    def test_inconsistent_visible_sequence_is_rejected(self):
        with self.assertRaises(ValueError):adjacent([2,None,5])


if __name__=='__main__':unittest.main()
