# SPDX-License-Identifier: GPL-3.0-or-later
"""Kinship from drawn orthogonal segments, ring markers and visible icons."""
from collections import deque

def graph(people,segments,rings):
 points={(p['x'],p['y']) for p in people}
 for x,y,a,b in segments:
  if x!=a and y!=b:raise ValueError('Non-orthogonal visible edge')
  points.update([(x,y),(a,b)])
 for x,y,a,b in segments:
  for c,d,e,f in segments:
   if y==b and c==e and min(x,a)<=c<=max(x,a) and min(d,f)<=y<=max(d,f):points.add((c,y))
 def on(point,line):
  x,y,a,b=line;u,v=point;return min(x,a)<=u<=max(x,a) and min(y,b)<=v<=max(y,b) and (x==a==u or y==b==v)
 links={p:set() for p in points}
 for line in segments:
  ordered=sorted(p for p in points if on(p,line))
  for a,b in zip(ordered,ordered[1:]):links[a].add(b);links[b].add(a)
 locations={(p['x'],p['y']):i for i,p in enumerate(people)};parents=[];spouses=[[] for p in people]
 for i,p in enumerate(people):
  start=(p['x'],p['y']);found=set();seen={start};queue=deque([start])
  while queue:
   point=queue.popleft()
   for other in links[point]:
    if other in seen or other[1]>point[1] or (point[1]==start[1] and other[1]==start[1]):continue
    seen.add(other)
    if other in locations:found.add(locations[other])
    else:queue.append(other)
  parents.append(sorted(found))
 for ring in rings:
  candidates=[]
  for i,p in enumerate(people):
   if p['y']==ring[1] and any(on(ring,line) and on((p['x'],p['y']),line) for line in segments):candidates.append(i)
  left=[i for i in candidates if people[i]['x']<ring[0]];right=[i for i in candidates if people[i]['x']>ring[0]]
  if not left or not right:raise ValueError('Ring has no visible couple')
  a=max(left,key=lambda i:people[i]['x']);b=min(right,key=lambda i:people[i]['x']);spouses[a].append(b);spouses[b].append(a)
 return {'people':people,'parents':parents,'spouses':spouses}

def relation(g,me,target):
 if me==target:return None
 p=g['parents'];s=g['spouses'];sex=g['people'][target]['sex'];word=lambda male,female:male if sex=='M' else female if sex=='F' else None
 siblings=lambda a,b:bool(set(p[a])&set(p[b])) and a!=b
 if target in p[me]:return word('Pai','Mãe')
 if me in p[target]:return word('Filho','Filha')
 if any(target in p[a] for a in p[me]):return word('Avô','Avó')
 if any(me in p[a] for a in p[target]):return word('Neto','Neta')
 if siblings(me,target):return word('Irmão','Irmã')
 if any(siblings(a,target) for a in p[me]):return word('Tio','Tia')
 if any(siblings(me,a) for a in p[target]):return word('Sobrinho','Sobrinha')
 if any(siblings(a,b) for a in p[me] for b in p[target]):return word('Primo','Prima')
 if any(target in p[partner] for partner in s[me]):return word('Sogro','Sogra')
 if any(me in p[partner] for partner in s[target]):return word('Genro','Nora')
 if any(siblings(partner,target) for partner in s[me]) or any(siblings(me,partner) for partner in s[target]):return word('Cunhado','Cunhada')
 return None

# Conventional icon categories audited from the rendered SVG contact sheet.
# Faces have no explicit gender captions; this is a documented visual limitation.
ICON_CATEGORY={name:sex for sex,names in [('M',['babyBoy.svg','boy1.svg','boy2.svg','man1.svg','man2.svg','man3.svg','oldMan1.svg']),('F',['babyGirl.svg','girl1.svg','woman1.svg','woman2.svg','oldWoman1.svg'])] for name in names}
def observe(record):
 size=record['people'][0]['width'];half=lambda value:round(value/size*2)/2
 people=[{'x':half(p['x']+p['width']/2),'y':half(p['y']+p['height']/2),'sex':ICON_CATEGORY[p['source'].split('/')[-1]]} for p in record['people']]
 edges=[]
 for e in record['edges']:
  x,y=half(e['x']),half(e['y']);a,b=half(e['x']+e['width']),half(e['y']+e['height']);edges.append((x,y,a,b))
 rings=[(half(r['x']+r['width']/2),half(r['y']+r['height']/2)) for r in record['rings']]
 return graph(people,edges,rings)
