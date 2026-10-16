# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from lock_plan import State,plan,step
class PhysicalLock(unittest.TestCase):
 def test_complete_return_trip(self):
  state=State();outward=plan(state,2)
  for action in outward:state=step(state,action)
  self.assertEqual(state.boat,2)
  inward=plan(state,0)
  for action in inward:state=step(state,action)
  self.assertEqual(state.boat,0)
  self.assertGreater(len(outward),3);self.assertGreater(len(inward),3)
 def test_boat_does_not_cross_closed_gate(self):
  with self.assertRaises(ValueError):step(State(),'boat')
 def test_wrong_height_gate_stays_closed(self):
  with self.assertRaises(ValueError):step(State(),'gate-right')
 def test_open_valves_interlock(self):
  low=step(State(),'valve-left')
  with self.assertRaises(ValueError):step(low,'valve-right')
