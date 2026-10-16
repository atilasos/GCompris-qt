# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from oracle import cents, subset


class MoneyArithmetic(unittest.TestCase):
    def test_portuguese_prices_are_exact_integer_cents(self):
        self.assertEqual(cents('1 234,56 €'), 123456)
        self.assertEqual(cents('0,10\u00a0€'), 10)
        self.assertEqual(cents('2 €'), 200)

    def test_finite_wallet_finds_a_non_greedy_exact_payment(self):
        self.assertEqual(subset([400, 300, 300], 600), [1, 2])
        self.assertIsNone(subset([200, 200], 300))
