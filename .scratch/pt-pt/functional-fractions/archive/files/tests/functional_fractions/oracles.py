# SPDX-License-Identifier: GPL-3.0-or-later
"""Portuguese quantities interpreted as exact rationals, independent of game data."""
from fractions import Fraction
import re


def instruction_fraction(text, denominator):
    if re.search(r'(dois|três)-(terços|quintos|quartos)', text):
        raise ValueError('Portuguese fraction names must not use these English-style hyphens: '+text)
    text = text.lower()
    if 'máximo de partes' in text:
        return Fraction(denominator//2, denominator)
    percent = re.search(r'(\d+)%', text)
    if percent:
        return Fraction(int(percent[1]), 100)
    decimal = re.search(r'\d+,\d+', text)
    if decimal:
        return Fraction(decimal[0].replace(',', '.'))
    names = {'dois terços':Fraction(2,3), 'dois quintos':Fraction(2,5),
             'três quintos':Fraction(3,5), 'três quartos':Fraction(3,4),
             'um terço':Fraction(1,3), 'um quarto':Fraction(1,4), 'metade':Fraction(1,2)}
    for name, value in names.items():
        if name in text:
            return value + bool(re.search(r' (uma tarte|um quadrado) e ', text))
    raise ValueError('Unrecognized visible PT quantity: '+text)
