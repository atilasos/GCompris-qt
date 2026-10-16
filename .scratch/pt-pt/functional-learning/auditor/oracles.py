# SPDX-License-Identifier: GPL-3.0-or-later
"""Interpret visible numerals and arithmetic without invoking the game engine."""
import re


def quantity(text):
    if re.fullmatch(r'[0-9]',text):return int(text)
    match=re.fullmatch(r'([0-9]) ([+-]) ([0-9])',text)
    if not match:raise ValueError(text)
    left,operation,right=match.groups()
    return int(left)+int(right) if operation=='+' else int(left)-int(right)
