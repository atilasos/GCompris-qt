# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from oracle import play,outcome,draw_route
class IndependentAlignmentRules(unittest.TestCase):
 def test_tic_tac_toe_rows_diagonals_draw_and_occupied_cell(self):
  self.assertEqual(outcome([1,1,1,2,2,0,0,0,0],3,3,3),1)
  self.assertEqual(outcome([2,1,1,0,2,1,0,0,2],3,3,3),2)
  self.assertEqual(outcome([1,2,1,1,2,2,2,1,1],3,3,3),0)
  self.assertIsNone(outcome([1,2,0,0,0,0,0,0,0],3,3,3))
  with self.assertRaises(ValueError):play([1]+[0]*8,0,2,3,3,False)
 def test_gravity_fills_lowest_empty_square_and_full_column_is_illegal(self):
  b=[0]*42;after=play(b,2,1,7,6,True);self.assertEqual(after[37],1);self.assertEqual(sum(after),1);self.assertEqual(b,[0]*42)
  full=[0]*42
  for turn in range(6):full=play(full,0,1+turn%2,7,6,True)
  with self.assertRaises(ValueError):play(full,0,1,7,6,True)
 def test_connect_four_both_diagonal_directions_and_vertical(self):
  for cells in [[35,29,23,17],[38,30,22,14],[2,9,16,23]]:
   b=[0]*42
   for cell in cells:b[cell]=2
   self.assertEqual(outcome(b,7,6,4),2)
 def test_generated_draw_is_42_legal_alternating_moves_without_early_winner(self):
  b=[0]*42;route=draw_route();self.assertEqual(len(route),42)
  for i,column in enumerate(route):
   b=play(b,column,1+i%2,7,6,True);self.assertEqual(outcome(b,7,6,4),0 if i==41 else None)
if __name__=='__main__':unittest.main()
