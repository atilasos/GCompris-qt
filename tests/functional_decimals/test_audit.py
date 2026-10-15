# SPDX-License-Identifier: GPL-3.0-or-later
"""The independent question auditor must handle shuffled overlapping ranges."""
import unittest
from audit import compatible, match_all


class QuestionAuditTest(unittest.TestCase):
    def test_pt_comma_is_a_decimal_separator(self):
        self.assertTrue(compatible('learn_decimals', 'Mostrar o número: 1,5', {'inputType':'range','minValue':1,'maxValue':2}))
        self.assertFalse(compatible('learn_decimals', 'Mostrar o número: 15', {'inputType':'range','minValue':1,'maxValue':2}))

    def test_addition_respects_total_not_only_operands(self):
        rule = {'inputType':'range','minValue':0.1,'maxValue':1}
        self.assertFalse(compatible('learn_decimals_additions','Mostrar o resultado de: 0,7 + 0,8',rule))
        self.assertTrue(compatible('learn_decimals_additions','Mostrar o resultado de: 0,7 + 0,2',rule))

    def test_shuffled_constraints_require_backtracking(self):
        rules = [{'inputType':'range','minValue':0.1,'maxValue':1}, {'inputType':'range','minValue':0.1,'maxValue':0.6}]
        self.assertTrue(match_all('learn_decimals',['0,5','0,9'],rules))
        self.assertFalse(match_all('learn_decimals',['0,8','0,9'],rules))

    def test_subtraction_order_must_avoid_negative_result(self):
        rule = {'inputType':'range','minValue':0.1,'maxValue':1}
        self.assertFalse(compatible('learn_decimals_subtractions','0,2 - 0,7',rule))
        self.assertTrue(compatible('learn_decimals_subtractions','0,7 - 0,2',rule))


if __name__=='__main__':
    unittest.main()
