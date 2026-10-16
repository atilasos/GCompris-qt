# SPDX-License-Identifier: GPL-3.0-or-later
"""Clock geometry from the Portuguese instruction, independent of the game."""
from fractions import Fraction
import re


def parse(text):
    match=re.fullmatch(r'Acertar o relógio para as:\s+(\d+)\s+horas?\s+(\d+)\s+minutos?(?:\s+(\d+)\s+segundos?)?',text)
    if not match:raise ValueError('Unrecognised Portuguese clock instruction')
    h,m,s=(int(value or 0) for value in match.groups())
    if not (0<=h<24 and 0<=m<60 and 0<=s<60):raise ValueError('Clock field outside its range')
    return h,m,s


def angles(time):
    h,m,s=time
    return Fraction(h%12*30)+Fraction(m,2),Fraction(m*6)+Fraction(s,10),Fraction(s*6)
