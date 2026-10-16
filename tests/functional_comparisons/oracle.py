# SPDX-License-Identifier: GPL-3.0-or-later
"""Arithmetic expectations from Portuguese glyphs and visible sequence anchors."""
from decimal import Decimal
import re


def number(text):
    text=str(text).replace('−','-')
    text=re.sub(r'\s','',text)
    if not re.fullmatch(r'[+-]?(?:\d+|\d{1,3}(?:\.\d{3})+)(?:,\d+)?',text):
        raise ValueError('Invalid Portuguese number: '+text)
    return Decimal(text.replace('.','').replace(',','.'))


def compare(left,right):
    a,b=number(left),number(right)
    return '<' if a<b else '>' if a>b else '='


def adjacent(visible):
    anchors=[(i,int(value)) for i,value in enumerate(visible) if value is not None]
    if not anchors:raise ValueError('No visible sequence anchor')
    index,value=anchors[0]
    result=[value+i-index for i in range(len(visible))]
    if any(result[i]!=value for i,value in anchors):raise ValueError('Visible anchors do not form adjacent integers')
    return result
