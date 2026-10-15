# SPDX-License-Identifier: GPL-3.0-or-later
"""Negative controls for the independent audit of native puzzle observations."""
import importlib.util
from pathlib import Path
import unittest

SPEC = importlib.util.spec_from_file_location('tens_audit', Path(__file__).parent / 'functional_tens/run.py')
audit_module = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(audit_module)


class TensMathAuditTests(unittest.TestCase):
    def test_finds_a_wrong_addition_even_when_the_game_reports_completion(self):
        result = {'activity': 'tens_complement_find', 'solved': 40, 'rejected': 8,
                  'equations': [{'a': 4, 'b': 6, 'result': 10}] * 120}
        self.assertEqual(audit_module.audit(result)['equations'], 120)
        result['equations'][71] = {'a': 4, 'b': 5, 'result': 10}
        with self.assertRaises(AssertionError):
            audit_module.audit(result)

    def test_a_matching_total_does_not_allow_invalid_pairs_or_substituted_cards(self):
        good = {'numbers': [2, 3, 8, 7], 'ordered': [2, 8, 3, 7], 'result': 20}
        result = {'activity': 'tens_complement_swap', 'solved': 12, 'rejected': 12,
                  'equations': [good] * 45}
        self.assertEqual(audit_module.audit(result)['equations'], 45)
        for ordered in [[2, 3, 8, 7], [1, 9, 4, 6]]:
            with self.subTest(ordered=ordered):
                result['equations'][7] = dict(good, ordered=ordered)
                with self.assertRaises(AssertionError):
                    audit_module.audit(result)

    def test_a_correct_total_does_not_allow_a_wrong_decomposition(self):
        good = {'a': 7, 'b': 12, 'parts': [7, 3, 9], 'result': 19}
        result = {'activity': 'tens_complement_use', 'solved': 30, 'rejected': 6,
                  'equations': [good] * 60}
        self.assertEqual(audit_module.audit(result)['equations'], 60)
        result['equations'][17] = dict(good, parts=[7, 4, 8])
        with self.assertRaises(AssertionError):
            audit_module.audit(result)


if __name__ == '__main__':
    unittest.main()
