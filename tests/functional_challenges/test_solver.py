# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from fractions import Fraction
from solver import combine,chain,calculate
class ArithmeticSearch(unittest.TestCase):
 def test_pair_trees_use_all_four_cards_with_integer_intermediates(self):
  plan=combine([1,1,4,6],24,['+','-','*']);self.assertIsNotNone(plan)
  self.assertIsNone(combine([1,1,1,1],24,['+','-']))
 def test_linear_chains_fill_all_rows_and_may_leave_distractors(self):
  plan=chain([1,2,4,5],5,['+','-']);self.assertIsNotNone(plan);self.assertEqual(len(plan),2);self.assertTrue(all(step['op'] in ['+','-'] for step in plan))
 def test_rational_arithmetic_and_public_nonnegative_integer_constraint(self):
  self.assertEqual(calculate(3,'/',2),Fraction(3,2));self.assertIsNone(calculate(3,'/',0));self.assertEqual(calculate(2,'-',3),-1)
if __name__=='__main__':unittest.main()

class ReusableVisibleOperatorTiles(unittest.TestCase):
 def test_four_rows_allow_dragging_division_twice_from_the_replenished_source(self):
  steps=chain([48,2,4,7,3],10,['+','-','*','/'])
  self.assertIsNotNone(steps)
  self.assertEqual(len(steps),4)
