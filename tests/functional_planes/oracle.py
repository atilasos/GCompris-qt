# SPDX-License-Identifier: GPL-3.0-or-later
"""Order from arithmetic and the Portuguese alphabet, independent of game data."""
ALPHABET='abcdefghijklmnopqrstuvwxyz'


def sequence(activity,level):
    assert level in range(1,5)
    if activity=='planegame':
        start=0 if level%2 else 10
        return [str(number) for number in range(start,start+11)]
    if activity=='numbers-odd-even':
        return [str(number) for number in range(0 if level%2 else 1,21,2)]
    assert activity=='alphabet-sequence'
    return list(ALPHABET if level%2 else ALPHABET.upper())
