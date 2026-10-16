# SPDX-License-Identifier: GPL-3.0-or-later
"""Money arithmetic from displayed Portuguese prices and finite denominations."""
import re

DENOMINATIONS = {'c1c.svg': 1, 'c2c.svg': 2, 'c5c.svg': 5, 'c10c.svg': 10, 'c20c.svg': 20, 'c50c.svg': 50,
                 'c1e.svg': 100, 'c2e.svg': 200, 'n5e.svg': 500, 'n10e.svg': 1000, 'n20e.svg': 2000,
                 'n50e.svg': 5000, 'n100e.svg': 10000, 'n200e.svg': 20000, 'n500e.svg': 50000}


def cents(text):
    value = re.sub(r'[\s.€]', '', text)
    match = re.fullmatch(r'(\d+)(?:,(\d{2}))?', value)
    assert match, text
    return int(match[1])*100+int(match[2] or 0)


def subset(values, wanted):
    found = {0: []}
    for index, value in enumerate(values):
        for total, selected in list(found.items()):
            result = total+value
            if result <= wanted and result not in found:
                found[result] = selected+[index]
        if wanted in found:
            return found[wanted]
    return found.get(wanted)
