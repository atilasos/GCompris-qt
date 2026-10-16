# SPDX-License-Identifier: GPL-3.0-or-later
"""Pure Latin/region/cage constraints, independent of either activity engine."""
from itertools import product
from math import prod

def cage_ok(values,target,op):
 if not values:return False
 if len(values)==1:return op=='' and values[0]==target
 if op=='+':return sum(values)==target
 if op in ['×','*']:return prod(values)==target
 if len(values)!=2:raise ValueError('Only addition/multiplication supported for cages larger than two')
 if op in ['−','-']:return abs(values[0]-values[1])==target
 if op in ['∕','÷',':','/']:
  a,b=sorted(values);return a>0 and b%a==0 and b//a==target
 raise ValueError('Unknown visible cage operator')

def units(puzzle):
 n=puzzle['n'];return [[r*n+c for c in range(n)] for r in range(n)]+[[r*n+c for r in range(n)] for c in range(n)]+puzzle.get('regions',[])

def valid(puzzle,values):
 n=puzzle['n']
 if len(values)!=n*n or any(type(v)!=int or not 1<=v<=n for v in values):return False
 if any(v and values[i]!=v for i,v in enumerate(puzzle['givens'])):return False
 if any(len(u)!=n or len({values[i] for i in u})!=n for u in units(puzzle)):return False
 return all(cage_ok([values[i] for i in cage['cells']],cage['target'],cage['op']) for cage in puzzle.get('cages',[]))

def solve(puzzle):
 n=puzzle['n'];values=list(puzzle['givens']);groups=units(puzzle)
 if n not in [3,4,5,9] or len(values)!=n*n or any(type(v)!=int or not 0<=v<=n for v in values):raise ValueError('Invalid visible grid')
 peers=[set() for _ in values]
 for group in groups:
  if len(group)!=n or len(set(group))!=n or any(not 0<=i<n*n for i in group):raise ValueError('Invalid visible region')
  seen=[values[i] for i in group if values[i]]
  if len(seen)!=len(set(seen)):raise ValueError('Conflicting visible givens')
  for i in group:peers[i].update(set(group)-{i})
 cages=[];by_cell={}
 for cage in puzzle.get('cages',[]):
  cells=cage['cells'];options=[]
  if not cells or any(i in by_cell for i in cells):raise ValueError('Invalid cage partition')
  for combination in product(range(1,n+1),repeat=len(cells)):
   if any(combination[a]==combination[b] and cells[b] in peers[cells[a]] for a in range(len(cells)) for b in range(a+1,len(cells))):continue
   if cage_ok(combination,cage['target'],cage['op']):options.append(combination)
  if not options:raise ValueError('Impossible visible cage')
  index=len(cages);cages.append((cells,options))
  for position,cell in enumerate(cells):by_cell[cell]=(index,position)
 if cages and set(by_cell)!=set(range(n*n)):raise ValueError('Incomplete visible cage partition')
 def candidates(cell):
  allowed=set(range(1,n+1))-{values[i] for i in peers[cell]}
  if cell in by_cell:
   index,position=by_cell[cell];cells,options=cages[index];possible=[option for option in options if all(not values[i] or values[i]==option[j] for j,i in enumerate(cells))];allowed&={option[position] for option in possible}
  return sorted(allowed)
 def search():
  empty=[i for i,v in enumerate(values) if not v]
  if not empty:return values.copy() if valid(puzzle,values) else None
  cell,choices=min(((i,candidates(i)) for i in empty),key=lambda pair:len(pair[1]))
  for value in choices:
   values[cell]=value;result=search()
   if result is not None:return result
  values[cell]=0;return None
 result=search()
 if result is None:raise ValueError('No solution for visible constraints')
 return result

def from_screen(record,arithmetic):
 n=record['size'];cells=[None]*(n*n)
 for cell in record['cells']:
  col=round(cell['x']/cell['width']);row=round(cell['y']/cell['height']);index=row*n+col
  if not 0<=col<n or not 0<=row<n or cells[index] is not None:raise ValueError('Ambiguous drawn cell geometry')
  cells[index]=cell
 if any(cell is None for cell in cells):raise ValueError('Missing drawn cell')
 symbols=[p['source'] for p in record['palette']]
 if len(symbols)!=n or len(set(symbols))!=n or '' in symbols:raise ValueError('Visible palette does not supply grid symbol domain')
 def value(source):
  if not source:return 0
  if source not in symbols:raise ValueError('Drawn clue not available in palette')
  if arithmetic:return int(source.rsplit('/',1)[-1].removesuffix('.svg'))
  return symbols.index(source)+1
 puzzle={'n':n,'givens':[value(c['source']) for c in cells],'regions':[],'cages':[]}
 if not arithmetic:
  for box in record['regions']:
   region=[i for i,c in enumerate(cells) if box['x']<=c['x']+c['width']/2<box['x']+box['width'] and box['y']<=c['y']+c['height']/2<box['y']+box['height']]
   if len(region)!=n:raise ValueError('Ambiguous visible region')
   puzzle['regions'].append(region)
  if puzzle['regions'] and sorted(i for region in puzzle['regions'] for i in region)!=list(range(n*n)):raise ValueError('Incomplete visible regions')
 else:
  frames={};walls={}
  for frame in record['cages']:
   index=round(frame['y']/frame['height'])*n+round(frame['x']/frame['width']);frames[index]=frame;edges=set()
   for wall in frame['walls']:
    if wall['width']>wall['height']:edges.add('T' if wall['y']+wall['height']/2<frame['height']/2 else 'B')
    else:edges.add('L' if wall['x']+wall['width']/2<frame['width']/2 else 'R')
   walls[index]=edges
  if set(frames)!=set(range(n*n)):raise ValueError('Missing visible cage frame')
  seen=set()
  for start in range(n*n):
   if start in seen:continue
   group=[];queue=[start];seen.add(start)
   while queue:
    cell=queue.pop();group.append(cell);row,col=divmod(cell,n)
    for nxt,allowed,edge,other in [(cell-1,col>0,'L','R'),(cell+1,col<n-1,'R','L'),(cell-n,row>0,'T','B'),(cell+n,row<n-1,'B','T')]:
     if allowed and nxt not in seen and edge not in walls[cell] and other not in walls[nxt]:seen.add(nxt);queue.append(nxt)
   labels=[label.replace(' ','') for cell in group for label in cells[cell]['labels']]
   if len(labels)!=1:raise ValueError('Cage needs one visible target/operator')
   import re
   match=re.fullmatch(r'(\d+)([+−×∕÷:/*-]?)',labels[0])
   if not match:raise ValueError('Unrecognised visible cage label')
   puzzle['cages'].append({'cells':sorted(group),'target':int(match[1]),'op':match[2]})
 return puzzle
