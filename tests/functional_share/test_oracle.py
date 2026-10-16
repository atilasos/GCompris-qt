# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from oracle import share
class VisibleCandyDivision(unittest.TestCase):
 def test_exact_and_remainder(self):
  self.assertEqual(share(2, 2), (1,0));self.assertEqual(share(3,14), (4,2));self.assertEqual(share(5,26), (5,1));self.assertEqual(share(6,36),(6,0))
 def test_non_counts_and_impossible_layout_are_rejected(self):
  for children,candies in [(0,4),(1,2),(7,4),(2,-1),(2,37),(2,14),(2,2.5),(True,2)]:
   with self.subTest(children=children,candies=candies), self.assertRaises(ValueError):share(children,candies)
if __name__=='__main__':unittest.main()
