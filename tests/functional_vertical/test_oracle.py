# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from oracle import columns

class VerticalArithmetic(unittest.TestCase):
 def test_addition_with_several_carries(self):
  self.assertEqual(columns([987,876,765,654], '+', 'regrouping'),
                   {'result':3282,'adjustments':[[0,1,2],[0,2,2],[0,3,3]]})
 def test_borrow_across_zero_columns(self):
  self.assertEqual(columns([1000,1], '-', 'regrouping'),
                   {'result':999,'adjustments':[[0,0,10],[0,1,-1],[0,1,10],[0,2,-1],[0,2,10],[0,3,-1]]})
 def test_compensation_moves_debt_to_bottom_operand(self):
  self.assertEqual(columns([1000,1], '-', 'compensation'),
                   {'result':999,'adjustments':[[0,0,10],[1,1,1],[0,1,10],[1,2,1],[0,2,10],[1,3,1]]})
if __name__=='__main__':unittest.main()
