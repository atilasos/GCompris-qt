# SPDX-License-Identifier: GPL-3.0-or-later
"""Separate source audit. Never supplies the native movement solver with answers."""
import re


def catalogue_alphabet(catalogue):
    pattern=r'msgctxt "AlphabetSequence\|"\nmsgid "a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z"\nmsgstr "([^"]+)"'
    matches=re.findall(pattern,catalogue.read_text())
    assert len(matches)==1
    return matches[0].replace('/','')
