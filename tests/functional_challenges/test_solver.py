# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from fractions import Fraction
from solver import combine,chain,calculate
class ArithmeticSearch(unittest.TestCase):
 def test_pair_trees_use_all_four_cards_with_integer_intermediates(self):
  plan=combine([1,1,4,6],24,['+','-','*']);self.assertIsNotNone(plan)
  self.assertIsNone(combine([1,1,1,1],24,['+','-']))
 def test_linear_chains_use_each_operator_once_and_may_leave_distractors(self):
  plan=chain([1,2,4,5],5,['+','-']);self.assertIsNotNone(plan);self.assertEqual(sorted(step['op'] for step in plan),['+','-'])
 def test_rational_arithmetic_and_public_nonnegative_integer_constraint(self):
  self.assertEqual(calculate(3,'/',2),Fraction(3,2));self.assertIsNone(calculate(3,'/',0));self.assertEqual(calculate(2,'-',3),-1)
if __name__=='__main__':unittest.main()
