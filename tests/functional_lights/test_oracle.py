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
