# SPDX-License-Identifier: GPL-3.0-or-later
"""Spatial judgments from painted centers, visible lid and layer ordering."""
def relation(view):
 if view['dx'] < -.5:return 'left'
 if view['dx'] > .5:return 'right'
 if view['dy'] < -.6:return 'above'
 if view['dy'] > .5:return 'under'
 if not view['lid']:return 'inside'
 return 'behind' if view['boy_z'] < view['front_z'] else 'front'
def meaning(text):
 for word,value in [('à frente','front'),('atrás','behind'),('dentro','inside'),('em cima','above'),('debaixo','under'),('direita','right'),('esquerda','left'),('ao lado','beside')]:
  if word in text:return value
 raise ValueError('Unknown visible Portuguese relation: '+text)
def matches(actual,requested):return actual in ['left','right'] if requested=='beside' else actual==requested
