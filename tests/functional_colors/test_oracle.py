# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from oracle import light_steps, pigment_steps

class VisibleMixing(unittest.TestCase):
    def test_red_light_uses_only_red_and_cyan_paint_uses_only_cyan(self):
        self.assertEqual(light_steps([1, 0, 0], 6), [6, 0, 0])
        self.assertEqual(pigment_steps([0, 1, 1], 6), [0, 0, 6])

    def test_quantized_displayed_channels_recover_discrete_controls(self):
        self.assertEqual(light_steps([85/255, 170/255, 1], 6), [2, 4, 6])
        self.assertEqual(pigment_steps([85/255, 170/255, 1], 6), [2, 0, 4])
