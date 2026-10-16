# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from oracle import solve, press
class LightRules(unittest.TestCase):
 def test_worked_cross(self):
  board=[0,1,0,1,1,1,0,1,0]
  self.assertEqual(press(board,3,4),[0]*9)
  result=solve(board,3)
  for cell in result:board=press(board,3,cell)
  self.assertEqual(board,[0]*9)
 def test_fixed_authored_boards_without_supplied_solutions(self):
  from inventory import inventory
  observed=0
  for dataset in inventory():
   for row in dataset['boards']:
    if row.get('dynamic'):continue
    board=row['level']
    self.assertTrue(any(board))
    for cell in solve(board,row['size']):board=press(board,row['size'],cell)
    self.assertEqual(board,[0]*len(board));observed+=1
  self.assertEqual(observed,57)
 def test_independent_corner_example(self):
  board=[1,1,0,1,1,1,0,0,0,1,0,0,0,0,0,1,0,0,0,1,1,1,0,1,1]
  literal=board[:]
  for cell in [0,4,20,24]:literal=press(literal,5,cell)
  self.assertEqual(literal,[0]*25)
  for cell in solve(board,5):board=press(board,5,cell)
  self.assertEqual(board,[0]*25)
