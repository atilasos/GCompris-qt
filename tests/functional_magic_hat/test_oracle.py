# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from oracle import result_vector, representation


class VisibleStarsArithmetic(unittest.TestCase):
    def test_weighted_addition_uses_drawn_coefficients(self):
        self.assertEqual(result_vector([{'group':'1','count':3,'weight':20}],[{'group':'1','count':2,'weight':10}],'plus'),{'1':80})

    def test_subtraction_preserves_each_visible_star_group(self):
        self.assertEqual(result_vector([{'group':'1','count':7,'weight':1},{'group':'2','count':4,'weight':1}],[{'group':'1','count':3,'weight':1},{'group':'2','count':4,'weight':1}],'minus'),{'1':4,'2':0})

    def test_bounded_answer_is_not_decimal_digits(self):
        rows=[{'group':'1','weight':1},{'group':'1','weight':5},{'group':'1','weight':10}]
        self.assertEqual(representation({'1':16},rows),(1,1,1))
        self.assertEqual(representation({'1':160},rows),(10,10,10))
        self.assertIsNone(representation({'1':161},rows))

    def test_coefficient_scaling_and_color_constraints(self):
        self.assertEqual(representation({'1':16000},[{'group':'1','weight':100},{'group':'1','weight':500},{'group':'1','weight':1000}]),(10,10,10))
        self.assertEqual(representation({'1':3,'2':2},[{'group':'1','weight':1},{'group':'2','weight':1},None]),(3,2,0))
