# SPDX-License-Identifier: GPL-3.0-or-later
from fractions import Fraction
import unittest
from oracles import instruction_fraction


class VisibleQuantityOracle(unittest.TestCase):
    def test_exact_quantities_from_different_written_forms(self):
        cases = [('Seleciona dois terços da tarte.', 3, Fraction(2,3)),
                 ('Seleciona uma tarte e um quarto de tarte.', 4, Fraction(5,4)),
                 ('Seleciona 1,4 da tarte.', 5, Fraction(7,5)),
                 ('Seleciona 170% da tarte.', 10, Fraction(17,10)),
                 ('Seleciona o máximo de partes sem levar mais de metade do quadrado.', 7, Fraction(3,7))]
        for text, denominator, expected in cases:
            with self.subTest(text=text):
                self.assertEqual(instruction_fraction(text,denominator),expected)

    def test_rejects_inappropriate_fraction_name_hyphen(self):
        with self.assertRaises(ValueError):
            instruction_fraction('Seleciona dois-terços da tarte.',3)
