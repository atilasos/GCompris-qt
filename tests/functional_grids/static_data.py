# SPDX-License-Identifier: GPL-3.0-or-later
"""Declarative dataset inventory only; never imported by the native solver.

Fixed clue fingerprints establish finite coverage. They do not solve boards.
"""
import ast,re

def dataset(text):
 text=re.sub(r'/\*.*?\*/','',text,flags=re.S);text=re.sub(r'//[^\n]*','',text)
 def parse_from(position,symbols=None):
  tokens=re.findall(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|-?\d+|[A-Za-z_]\w*|[\[\]{},:]',text[position:]);cursor=0
  def value():
   nonlocal cursor
   token=tokens[cursor];cursor+=1
   if token=='[':
    result=[]
    while tokens[cursor]!=']':
     result.append(value())
     if tokens[cursor]==',':cursor+=1
     elif tokens[cursor]!=']':raise ValueError('Invalid data array')
    cursor+=1;return result
   if token=='{':
    result={}
    while tokens[cursor]!='}':
     key=value();assert tokens[cursor]==':';cursor+=1;result[key]=value()
     if tokens[cursor]==',':cursor+=1
     elif tokens[cursor]!='}':raise ValueError('Invalid data object')
    cursor+=1;return result
   if token[0] in ['"',"'"]:return ast.literal_eval(token)
   if re.fullmatch(r'-?\d+',token):return int(token)
   if token in ['true','false']:return token=='true'
   if token=='symbols' and symbols is not None:return symbols
   if token in ['imgName','text']:return token
   raise ValueError('Unsupported declarative token '+token)
  return value()
 marker=re.search(r'property\s+var\s+symbols\s*:\s*',text)
 if not marker:raise ValueError('Missing public symbol metadata')
 symbols=parse_from(marker.end());marker=re.search(r'(?m)^\s*data\s*:\s*',text)
 if not marker:raise ValueError('Missing dataset declaration')
 return parse_from(marker.end(),symbols)

def fixed_fingerprint(board,symbols):
 images={str(symbol['text']):symbol['imgName'] for symbol in symbols}
 return tuple('' if value=='.' else images[str(value)] for row in board for value in row)

def drawn_fingerprint(screen):
 n=screen['size'];cells=['']*(n*n)
 for cell in screen['cells']:
  index=round(cell['y']/cell['height'])*n+round(cell['x']/cell['width']);cells[index]=cell['source'].rsplit('/',1)[-1]
 return tuple(cells)
