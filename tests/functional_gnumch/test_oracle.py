# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from oracle import answer

class VisibleArithmetic(unittest.TestCase):
 def test_uses_visible_expression_and_goal(self):
  self.assertTrue(answer('equality','2 + 4','Igual a 6'))
  self.assertFalse(answer('inequality','9 - 3','Diferente de 6'))
  self.assertTrue(answer('equality','15 / 3','Igual a 5'))
  self.assertFalse(answer('equality','4 * 3','Igual a 13'))
 def test_divisors_and_multiples_are_opposite_relations(self):
  self.assertTrue(answer('factors','4','Factor de 12'))
  self.assertFalse(answer('factors','5','Factor de 12'))
  self.assertTrue(answer('multiples','12','Múltiplo de 4'))
  self.assertFalse(answer('multiples','4','Múltiplo de 12'))
 def test_prime_uses_trial_division_and_visible_bound(self):
  self.assertTrue(answer('primes','23','Primos inferiores a 24'))
  for value in ('1','4','9','23'):
   self.assertFalse(answer('primes',value,'Primos inferiores a 23'))
if __name__=='__main__':unittest.main()
