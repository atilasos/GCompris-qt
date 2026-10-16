# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from patterns import complete


class VisibleAssociation(unittest.TestCase):
    def test_worked_four_fruit_substitution(self):
        self.assertEqual(complete(['apple','banana','lemon','pear','banana','apple','apple','banana'],['plum','cherries','orange','pineapple']),['cherries','plum','plum','cherries'])

    def test_ambiguous_visible_prefix_is_rejected(self):
        with self.assertRaises(ValueError):complete([0,0,1,1,2,0,1,2],['apple','apple','pear','pear'])


if __name__=='__main__':unittest.main()
