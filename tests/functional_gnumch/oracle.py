# SPDX-License-Identifier: GPL-3.0-or-later
"""Independent arithmetic from displayed text, without loading game JavaScript."""
from fractions import Fraction
import re
PREFIX={'equality':'Igual a','inequality':'Diferente de','factors':'Factor de',
        'multiples':'Múltiplo de','primes':'Primos inferiores a'}

def answer(kind,text,prompt):
 match=re.fullmatch(re.escape(PREFIX[kind])+r' (\d+)',prompt)
 if not match:raise ValueError(prompt)
 goal=int(match[1])
 parts=re.fullmatch(r'(\d+)(?:\s*([+*/-])\s*(\d+))?',text)
 if not parts:raise ValueError(text)
 value=Fraction(parts[1])
 if parts[2]:
  right=Fraction(parts[3]);op=parts[2]
  value={'+':lambda:value+right,'-':lambda:value-right,'*':lambda:value*right,'/':lambda:value/right}[op]()
 if kind=='equality':return value==goal
 if kind=='inequality':return value!=goal
 if kind=='factors':return value>0 and Fraction(goal,value).denominator==1
 if kind=='multiples':return Fraction(value,goal).denominator==1
 number=int(value)
 return value.denominator==1 and 2<=number<goal and all(number%factor for factor in range(2,int(number**0.5)+1))
