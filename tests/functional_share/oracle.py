# SPDX-License-Identifier: GPL-3.0-or-later
"""Division from visible object counts, independent of the activity's answers."""
def share(children, candies):
    if type(children) is not int or not 2 <= children <= 6:
        raise ValueError('Expected two to six painted children')
    if type(candies) is not int or not 0 <= candies <= 36:
        raise ValueError('Expected a nonnegative painted candy inventory')
    quotient, remainder = divmod(candies, children)
    if quotient > 6:
        raise ValueError('Distribution exceeds the six painted slots')
    return quotient, remainder
