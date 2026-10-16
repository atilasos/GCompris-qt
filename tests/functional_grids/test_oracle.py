# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from oracle import solve,valid,cage_ok
class VisibleGridRules(unittest.TestCase):
 def test_three_symbols_use_rows_and_columns_without_boxes(self):
  puzzle={'n':3,'givens':[1,0,3,0,3,1,3,1,0],'regions':[],'cages':[]};self.assertEqual(solve(puzzle),[1,2,3,2,3,1,3,1,2]);self.assertTrue(valid(puzzle,[1,2,3,2,3,1,3,1,2]))
 def test_four_by_four_uses_four_two_by_two_regions(self):
  regions=[[0,1,4,5],[2,3,6,7],[8,9,12,13],[10,11,14,15]];p={'n':4,'givens':[1,0,0,4,0,4,1,0,2,0,4,0,0,3,0,1],'regions':regions,'cages':[]};self.assertEqual(solve(p),[1,2,3,4,3,4,1,2,2,1,4,3,4,3,2,1])
 def test_five_by_five_without_regions_does_not_invent_boxes(self):
  p={'n':5,'givens':[1,2,3,4,0,2,3,4,0,1,3,4,0,1,2,4,0,1,2,3,0,1,2,3,4],'regions':[],'cages':[]};self.assertTrue(valid(p,solve(p)))
 def test_nine_by_nine_worked_puzzle(self):
  rows=['530070000','600195000','098000060','800060003','400803001','700020006','060000280','000419005','000080079'];p={'n':9,'givens':[int(v) for row in rows for v in row],'regions':[[((br*3+r)*9+bc*3+c) for r in range(3) for c in range(3)] for br in range(3) for bc in range(3)],'cages':[]};result=solve(p);self.assertEqual(result[:9],[5,3,4,6,7,8,9,1,2]);self.assertTrue(valid(p,result))
 def test_calcudoku_two_cell_difference_division_and_larger_sum_product(self):
  self.assertTrue(cage_ok([2,5],3,'−'));self.assertTrue(cage_ok([5,2],3,'−'));self.assertTrue(cage_ok([4,2],2,'∕'));self.assertTrue(cage_ok([2,4],2,'∕'));self.assertFalse(cage_ok([5,2],2,'∕'));self.assertTrue(cage_ok([1,2,3],6,'+'));self.assertTrue(cage_ok([1,2,3],6,'×'))
  with self.assertRaises(ValueError):cage_ok([1,2,3],0,'−')
 def test_worked_calcudoku_cages_can_be_solved_without_hidden_grid(self):
  p={'n':3,'givens':[0]*9,'regions':[],'cages':[{'cells':[0,1],'target':3,'op':'+'},{'cells':[2,5],'target':3,'op':'∕'},{'cells':[3,6],'target':1,'op':'−'},{'cells':[4,7,8],'target':6,'op':'×'}]};self.assertTrue(valid(p,solve(p)));self.assertFalse(valid(p,[1]*9))
if __name__=='__main__':unittest.main()
