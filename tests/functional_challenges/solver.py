# SPDX-License-Identifier: GPL-3.0-or-later
"""Independent exact-rational searches; only public integer results are usable."""
from fractions import Fraction

def calculate(a,op,b):
 a,b=Fraction(a),Fraction(b)
 if op=='+':return a+b
 if op=='-':return a-b
 if op=='*':return a*b
 if op=='/':return a/b if b else None
 raise ValueError('Unknown arithmetic operator')
def admissible(value):return value is not None and value>=0 and value.denominator==1

def combine(numbers,target,operators):
 failed=set()
 def visit(values):
  if len(values)==1:return [] if values[0][0]==target else None
  key=tuple(sorted(value for value,_ in values))
  if key in failed:return None
  for i,(a,slot_a) in enumerate(values):
   for j,(b,slot_b) in enumerate(values):
    if i==j:continue
    for op in operators:
     if op in ['+','*'] and i>j:continue
     value=calculate(a,op,b)
     if not admissible(value):continue
     tail=visit([item for k,item in enumerate(values) if k not in [i,j]]+[(value,slot_b)])
     if tail is not None:return [{'a':slot_a,'b':slot_b,'op':op,'left':int(a),'right':int(b),'result':int(value)},*tail]
  failed.add(key);return None
 return visit([(Fraction(value),index) for index,value in enumerate(numbers)])

def chain(numbers,target,operators):
 def visit(acc,remaining,depth):
  if depth==0:return [] if acc==target else None
  for op in operators:
   for index in remaining:
    value=calculate(acc,op,numbers[index])
    if not admissible(value):continue
    tail=visit(value,[i for i in remaining if i!=index],depth-1)
    if tail is not None:return [{'b':index,'op':op,'left':int(acc),'right':numbers[index],'result':int(value)},*tail]
  return None
 for index,value in enumerate(numbers):
  steps=visit(Fraction(value),[i for i in range(len(numbers)) if i!=index],len(operators))
  if steps is not None:
   if steps:steps[0]['a']=index
   return steps
 return None
