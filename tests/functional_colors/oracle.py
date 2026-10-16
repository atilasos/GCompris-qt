# SPDX-License-Identifier: GPL-3.0-or-later
"""Independent inverse of displayed additive RGB or complementary CMY channels."""
def light_steps(rgb, divisions):
    return [round(channel * divisions) for channel in rgb]


def pigment_steps(rgb, divisions):
    red, green, blue = rgb
    return [round((1 - green) * divisions), round((1 - blue) * divisions), round((1 - red) * divisions)]
