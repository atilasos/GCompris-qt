# SPDX-License-Identifier: GPL-3.0-or-later
from pathlib import Path
import unittest
from oracle import dice_pips

ROOT = Path(__file__).resolve().parents[2]


class VisibleDiceTest(unittest.TestCase):
    def test_top_face_has_six_pips_even_with_decorative_side_faces(self):
        self.assertEqual(dice_pips(ROOT / 'src/activities/smallnumbers/resource/dice6.svg'), 6)

    def test_empty_face_and_single_pip(self):
        self.assertEqual(dice_pips(ROOT / 'src/activities/smallnumbers/resource/dice0.svg'), 0)
        self.assertEqual(dice_pips(ROOT / 'src/activities/smallnumbers/resource/dice1.svg'), 1)
