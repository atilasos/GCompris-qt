# SPDX-License-Identifier: GPL-3.0-or-later
"""Rolling-circle geometry from drawn centers and public tooth labels."""
import math,re,xml.etree.ElementTree as ET

def position(route,t):
 initial=route['initial'];c=initial['center'];g=initial['gear'];p=initial['pen'];dx,dy=g['x']-c['x'],g['y']-c['y'];radius=math.hypot(dx,dy);phase=math.atan2(dx,-dy);frequency=route['wheel']/route['gear']-1;u,v=p['x']-g['x'],p['y']-g['y'];a=frequency*t
 return (c['x']+radius*math.sin(phase+t)+u*math.cos(a)+v*math.sin(a),c['y']-radius*math.cos(phase+t)-u*math.sin(a)+v*math.cos(a))

def svg_paths(raw):
 root=ET.fromstring(raw);paths=[]
 for element in root.iter():
  if element.tag.rsplit('}',1)[-1]!='path':continue
  data=element.get('d','');tokens=re.findall(r'[MLZ]|[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?',data)
  if re.sub(r'[\s,]','',data)!=re.sub(r'[\s,]','',''.join(tokens)):raise ValueError('Unexpected vector command')
  points=[];index=0
  while index<len(tokens):
   command=tokens[index];index+=1
   if command=='Z':continue
   if command not in ['M','L'] or index+1>=len(tokens):raise ValueError('Malformed vector point')
   points.append((float(tokens[index]),float(tokens[index+1])));index+=2
  if not points:raise ValueError('Empty vector path')
  paths.append({'points':points,'style':dict(pair.split(':',1) for pair in element.get('style','').split(';') if ':' in pair)})
 if not paths:raise ValueError('No drawn vectors')
 return paths

def curve_error(route,points):
 if not points:raise ValueError('No drawn points')
 loops=route['gear']//math.gcd(int(route['wheel']),int(route['gear']));duration=2*math.pi*loops;count=math.ceil(duration/.003);buckets={}
 for i in range(count+1):
  x,y=position(route,duration*i/count);buckets.setdefault((math.floor(x/2),math.floor(y/2)),[]).append((x,y))
 worst=0
 for x,y in points:
  bx,by=math.floor(x/2),math.floor(y/2);best=math.inf
  for dx in [-2,-1,0,1,2]:
   for dy in [-2,-1,0,1,2]:
    for u,v in buckets.get((bx+dx,by+dy),[]):best=min(best,(u-x)**2+(v-y)**2)
  worst=max(worst,math.sqrt(best))
 return worst
