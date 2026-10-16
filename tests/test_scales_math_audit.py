# SPDX-License-Identifier: GPL-3.0-or-later
import importlib.util
from pathlib import Path
import unittest

SPEC = importlib.util.spec_from_file_location('scales_audit', Path(__file__).parent / 'functional_scales/run.py')
module = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(module)


class ScalesAuditTests(unittest.TestCase):
    def test_independent_si_and_avoirdupois_conversions(self):
        self.assertEqual(module.mass('2,2 kg'), 2200)
        self.assertEqual(module.mass('1 lb'), 16)
        self.assertEqual(module.mass('16 oz'), 16)
        with self.assertRaises(ValueError):
            module.mass('10 bananas')

    def test_a_displayed_equilibrium_must_match_the_known_visible_mass_labels(self):
        puzzle = {'labels': ['1 kg', '200 g', '2 kg', '1 kg', '500 g', '1 kg', '1 kg'],
                  'positions': [1, 1, 0, 0, 0, 0, 0], 'canonical': 1200,
                  'visibleTarget': '1,2 kg', 'both': False}
        report = {'activity': 'scalesboard_weight', 'puzzles': [puzzle],
                  'completed': [1], 'rejected': 1, 'drags': 2}
        self.assertTrue(module.audit(report, True)['passed'])
        puzzle['visibleTarget'] = '1,3 kg'
        with self.assertRaises(AssertionError):
            module.audit(report, True)

    def test_a_numerically_equal_target_from_another_unit_system_is_rejected(self):
        puzzle = {'labels': ['1 kg', '200 g', '2 kg', '1 kg', '500 g', '1 kg', '1 kg'],
                  'positions': [1, 1, 0, 0, 0, 0, 0], 'canonical': 1200,
                  'visibleTarget': '75 lb', 'both': False}
        report = {'activity': 'scalesboard_weight', 'puzzles': [puzzle],
                  'completed': [1], 'rejected': 1, 'drags': 2}
        with self.assertRaises(AssertionError):
            module.audit(report, True)

    def test_six_visible_masses_are_supported_without_inventing_a_seventh(self):
        puzzle = {'labels': ['1 lb', '8 oz', '4 oz', '2 oz', '1 oz', '1 oz'],
                  'positions': [0, 1, 0, 0, 0, 0], 'canonical': 8,
                  'visibleTarget': '8 oz', 'both': False}
        report = {'activity': 'scalesboard_weight_avoirdupois', 'puzzles': [puzzle],
                  'completed': [1], 'rejected': 1, 'drags': 1}
        self.assertTrue(module.audit(report, True)['passed'])
        puzzle['positions'].append(0)
        with self.assertRaises(AssertionError):
            module.audit(report, True)

    def test_hidden_balance_checks_the_observed_inclination_and_visible_entry_unit(self):
        puzzle = {'labels': ['1 lb', '8 oz', '4 oz', '2 oz', '1 oz', '1 oz', '1 oz'],
                  'positions': [1, 1, 0, 0, 0, 0, 0], 'canonical': 24,
                  'visibleTarget': '', 'both': False, 'prompt': 'Indica o peso do presente em onças: 24',
                  'entry': '24', 'probes': [{'sum': 16, 'tilt': 1}, {'sum': 24, 'tilt': 0}]}
        report = {'activity': 'scalesboard_weight_avoirdupois', 'puzzles': [puzzle],
                  'completed': [1], 'rejected': 1, 'drags': 2}
        self.assertTrue(module.audit(report, True)['passed'])
        puzzle['probes'][0]['tilt'] = -1
        with self.assertRaises(AssertionError):
            module.audit(report, True)
        puzzle['probes'][0]['tilt'] = 1
        puzzle['entry'] = '25'
        with self.assertRaises(AssertionError):
            module.audit(report, True)


if __name__ == '__main__':
    unittest.main()
