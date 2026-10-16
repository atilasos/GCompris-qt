# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from oracle import at_tick,tick_for
class VisibleGraduations(unittest.TestCase):
 def test_decimal_comma_uses_exact_rational_steps(self):
  self.assertEqual(at_tick('0','4',41,17),'1,7')
  self.assertEqual(tick_for('0','4',41,'1,7'),17)
 def test_offset_and_grouped_million_bounds(self):
  self.assertEqual(at_tick('120','200',9,3),'150')
  self.assertEqual(at_tick('0','1\u00a0000\u00a0000',11,7),'700000')
 def test_extremes_and_signed_values(self):
  self.assertEqual(at_tick('-2','2',9,0),'-2')
  self.assertEqual(at_tick('-2','2',9,8),'2')
 def test_nonexistent_or_out_of_bounds_tick_is_rejected(self):
  for value in ['0,11','-1','5']:
   with self.assertRaises(ValueError):tick_for('0','4',41,value)
if __name__=='__main__':unittest.main()
