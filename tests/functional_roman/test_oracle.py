# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from oracle import roman,arabic


class CanonicalRomanNotation(unittest.TestCase):
    def test_worked_subtractive_examples(self):
        for number,text in [(4,'IV'),(9,'IX'),(944,'CMXLIV'),(1994,'MCMXCIV'),(3999,'MMMCMXCIX')]:
            self.assertEqual(roman(number),text);self.assertEqual(arabic(text),number)

    def test_lowercase_is_read_as_canonical_uppercase(self):
        self.assertEqual(arabic('xliv'),44)

    def test_invalid_notation_and_limits_are_rejected(self):
        for text in ['MMMM','IIII','VX','IL','', 'IIV']:
            with self.assertRaises(ValueError):arabic(text)
        for number in [0,4000,-1]:
            with self.assertRaises(ValueError):roman(number)
