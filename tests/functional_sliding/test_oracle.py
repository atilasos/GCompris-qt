# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from oracle import slide, rotate, solved

class VisibleBoardTransitions(unittest.TestCase):
    def test_fifteen_moves_only_adjacent_tile_into_blank(self):
        board=list(range(1,15))+[0,15]
        self.assertEqual(slide(board,15),list(range(1,16))+[0])
        with self.assertRaises(ValueError):slide(board,0)
        self.assertEqual(board[-2:],[0,15])

    def test_sixteen_row_and_column_wrap_with_visible_arrow_direction(self):
        board=list(range(1,17))
        self.assertEqual(rotate(board,'L',0)[:4],[2,3,4,1])
        self.assertEqual(rotate(board,'T',2),[1,2,7,4,5,6,11,8,9,10,15,12,13,14,3,16])
        self.assertEqual(rotate(rotate(board,'R',3),'L',3),board)

    def test_final_order_checks_every_square(self):
        self.assertTrue(solved(list(range(1,16))+[0],'fifteen'))
        self.assertTrue(solved(list(range(1,17)),'sixteen'))
        self.assertFalse(solved([2,1]+list(range(3,17)),'sixteen'))

if __name__=='__main__':unittest.main()
