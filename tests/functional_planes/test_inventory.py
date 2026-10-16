# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from pathlib import Path
from inventory import catalogue_alphabet

ROOT=Path(__file__).resolve().parents[2]


class PortugueseAlphabetCatalogue(unittest.TestCase):
    def test_translated_alphabet_contains_all_26_modern_portuguese_letters(self):
        self.assertEqual(catalogue_alphabet(ROOT/'poqm/pt/gcompris_qt.po'),'abcdefghijklmnopqrstuvwxyz')
