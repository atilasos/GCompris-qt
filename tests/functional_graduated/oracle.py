# SPDX-License-Identifier: GPL-3.0-or-later
"""Exact arithmetic on displayed labels and an integer count of equal intervals."""
from decimal import Decimal
from fractions import Fraction

def number(text):
    return Fraction(Decimal(text.replace('\u00a0','').replace('\u202f','').replace(' ','').replace(',','.').replace('−','-')))

def at_tick(left,right,count,index):
    if count<2 or not 0<=index<count:raise ValueError('Outside visible line')
    value=number(left)+(number(right)-number(left))*index/(count-1)
    denominator=value.denominator
    while denominator%2==0:denominator//=2
    while denominator%5==0:denominator//=5
    if denominator!=1:raise ValueError('The line does not have a finite decimal value')
    text=format(Decimal(value.numerator)/Decimal(value.denominator),'f')
    if '.' in text:text=text.rstrip('0').rstrip('.')
    return text.replace('.',',')

def tick_for(left,right,count,target):
    if count<2 or number(right)==number(left):raise ValueError('Invalid line')
    index=(number(target)-number(left))/(number(right)-number(left))*(count-1)
    if index.denominator!=1 or not 0<=index<count:raise ValueError('Not a visible graduation')
    return int(index)
