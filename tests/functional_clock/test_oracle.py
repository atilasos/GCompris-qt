# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from fractions import Fraction
from oracle import parse,angles


class ClockFromPortuguese(unittest.TestCase):
    def test_full_time_with_nonbreaking_spaces(self):
        self.assertEqual(parse('Acertar o relógio para as: 15\u00a0horas 45\u00a0minutos 30\u00a0segundos'),(15,45,30))
        self.assertEqual(angles((15,45,30)),(Fraction(225,2),Fraction(273),Fraction(180)))

    def test_singular_hour_without_seconds(self):
        self.assertEqual(parse('Acertar o relógio para as: 1 hora 1 minuto'),(1,1,0))
        self.assertEqual(angles((1,1,0)),(Fraction(61,2),Fraction(6),Fraction(0)))

    def test_invalid_time_is_rejected(self):
        for text in ['Acertar o relógio para as: 24 horas 0 minutos','Set the watch to: 1 hour 2 minutes','Acertar o relógio para as: 1 hora 60 minutos']:
            with self.assertRaises(ValueError):parse(text)
