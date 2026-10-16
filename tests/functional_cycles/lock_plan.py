# SPDX-License-Identifier: GPL-3.0-or-later
"""Independent chamber rules: equal water height at an open gate."""
from collections import deque
from dataclasses import dataclass,replace

@dataclass(frozen=True)
class State:
 boat:int=0
 water:int=0
 left_gate:bool=False
 right_gate:bool=False
 left_valve:bool=False
 right_valve:bool=False

ACTIONS=('gate-left','gate-right','valve-left','valve-right','boat')

def step(state,action):
 if action=='gate-left':
  if not state.left_gate and state.water!=0:raise ValueError('Different left water height')
  return replace(state,left_gate=not state.left_gate)
 if action=='gate-right':
  if not state.right_gate and state.water!=1:raise ValueError('Different right water height')
  return replace(state,right_gate=not state.right_gate)
 if action=='valve-left':
  if not state.left_valve and (state.right_gate or state.right_valve):raise ValueError('Connected opposite water')
  return replace(state,left_valve=not state.left_valve,water=0 if not state.left_valve else state.water)
 if action=='valve-right':
  if not state.right_valve and (state.left_gate or state.left_valve):raise ValueError('Connected opposite water')
  return replace(state,right_valve=not state.right_valve,water=1 if not state.right_valve else state.water)
 if action=='boat':
  if state.boat==0 and state.left_gate:return replace(state,boat=1)
  if state.boat==2 and state.right_gate:return replace(state,boat=1)
  if state.boat==1:
   if state.water==0 and state.left_gate:return replace(state,boat=0)
   if state.water==1 and state.right_gate:return replace(state,boat=2)
  raise ValueError('No open gate at boat water height')
 raise ValueError('Unknown physical action')

def plan(initial,target):
 if target not in (0,2):raise ValueError('An exterior destination is required')
 queue=deque([(initial,[])]);seen={initial}
 while queue:
  state,actions=queue.popleft()
  if state.boat==target:return actions
  for action in ACTIONS:
   try:next_state=step(state,action)
   except ValueError:continue
   if next_state not in seen:
    seen.add(next_state);queue.append((next_state,[*actions,action]))
 raise ValueError('No physical route')
