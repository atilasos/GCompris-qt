# SPDX-License-Identifier: GPL-3.0-or-later
"""Read public curriculum, excluding supplied solutions from the solver inputs."""
import ast,json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
def array(text,marker):
 start=text.index('[',text.index(marker));depth=0;quote=None;escaped=False
 for end in range(start,len(text)):
  c=text[end]
  if quote:
   if escaped:escaped=False
   elif c=='\\':escaped=True
   elif c==quote:quote=None
  elif c in ['"',"'"]:quote=c
  elif c=='[':depth+=1
  elif c==']':
   depth-=1
   if depth==0:return ast.literal_eval(text[start:end+1])
 raise ValueError('Unclosed published array')
def inventory(source=ROOT):
 return inventory_from_text(lambda path:(source/path).read_text())
def inventory_from_text(read):
 result={'guess24':[],'guesscount':[]}
 for dataset in range(1,7):
  text=read(f'src/activities/guess24/resource/{dataset}/Data.qml');result['guess24']+=array(text,'data:')
 for dataset in range(1,5):
  text=read(f'src/activities/guesscount/resource/{dataset}/Data.qml');schemas=array(text,'"levelSchema"');ops=array(text,'"defaultOperators"');data=array(text,'"dataItems"')
  for number,(count,operators) in enumerate(zip(schemas,ops),1):result['guesscount'].append({'dataset':dataset,'within_dataset':number,'count':count,'operators':operators,'groups':data})
 text=read('src/activities/guesscount/dataset.js');result['admin']={'schema':array(text,'var levelSchema'),'operators':array(text,'var defaultOperators'),'data':array(text,'var dataset')}
 result['corpus']=[{'values':list(map(int,row['puzzle'].split())),'complexity':row['complexity']} for row in json.loads(read('src/activities/guess24/resource/guess24.json'))]
 return result
if __name__=='__main__':print(json.dumps(inventory(),indent=2))
