# SPDX-License-Identifier: GPL-3.0-or-later
"""Infer unrotated piece placement from alpha/RGB and public painted slots."""
import math
from dataclasses import dataclass
from PIL import Image

class AmbiguousPuzzle(ValueError):
 """At least two arrangements have indistinguishable pixel evidence."""
class NoSolution(ValueError):
 """No arrangement satisfies the visible canvas and alpha constraints."""
class SearchLimit(ValueError):
 """The bounded search cannot certify its best candidate."""

@dataclass
class _Placement:
 piece: int
 slot: int
 left: int
 top: int
 mask: int
 area: int
 image: object

def solve(images_by_id, visible_slots_in_canvas_pixels, canvas_size, *, max_nodes=100000, overlap_fraction=.015, flat_border_constraints=False):
 """Return piece ID -> index in the supplied visible slot list, or refuse.

 IDs are opaque labels. Images use their observed orientation and native size.
 A small explicit alpha overlap budget tolerates rounded centers/antialiasing.
 The winning arrangement must be the unique minimum of RGB seam discontinuity.
 Search exhaustion raises SearchLimit instead of returning an uncertified guess.
 """
 width,height=map(int,canvas_size);slots=list(visible_slots_in_canvas_pixels)
 if width<=0 or height<=0 or not images_by_id or len(images_by_id)!=len(slots):raise ValueError('Expected equal nonempty pieces and slots on a positive canvas')
 if not 0<=overlap_fraction<.1 or max_nodes<1:raise ValueError('Invalid overlap fraction or node budget')
 if any(not all(math.isfinite(v) for v in point) or len(point)!=2 for point in slots):raise ValueError('Expected finite x/y slot pairs')
 extrema=(min(p[0] for p in slots),max(p[0] for p in slots),min(p[1] for p in slots),max(p[1] for p in slots))
 ids=list(images_by_id);placements=[];domains=[]
 for piece,key in enumerate(ids):
  image=images_by_id[key].convert('RGBA');alpha=image.getchannel('A');bbox=alpha.point(lambda value:255 if value>=128 else 0).getbbox()
  if bbox is None:raise ValueError('Empty alpha piece')
  pixels=alpha.load();rows=[sum(1<<x for x in range(image.width) if pixels[x,y]>=128) for y in range(image.height)];area=sum(row.bit_count() for row in rows);options=[]
  flags=(False,False,False,False)
  if flat_border_constraints and area<image.width*image.height*.98:
   flags=(sum(pixels[0,y]>=128 for y in range(image.height))/image.height>.6,sum(pixels[image.width-1,y]>=128 for y in range(image.height))/image.height>.6,sum(pixels[x,0]>=128 for x in range(image.width))/image.width>.6,sum(pixels[x,image.height-1]>=128 for x in range(image.width))/image.width>.6)
  for slot,(cx,cy) in enumerate(slots):
   left=round(cx-image.width/2);top=round(cy-image.height/2)
   if not (0<=left+bbox[0] and left+bbox[2]<=width and 0<=top+bbox[1] and top+bbox[3]<=height):continue
   if flat_border_constraints and ((flags[0] and left+bbox[0]>extrema[0]) or (flags[1] and left+bbox[2]<extrema[1]) or (flags[2] and top+bbox[1]>extrema[2]) or (flags[3] and top+bbox[3]<extrema[3])):continue
   mask=0
   for y,row in enumerate(rows):
    if row:mask|=(row<<left if left>=0 else row>>-left)<<((top+y)*width)
   options.append(len(placements));placements.append(_Placement(piece,slot,left,top,mask,area,image.load()))
  domains.append(options)
 cache={};pair_checks=0
 def relation(a,b):
  nonlocal pair_checks
  if a>b:a,b=b,a
  key=(a,b)
  if key in cache:return cache[key]
  pair_checks+=1;p=placements[a];q=placements[b]
  if p.slot==q.slot or (p.mask&q.mask).bit_count()>min(p.area,q.area)*overlap_fraction:cache[key]=None;return None
  total=0;count=0
  for dx,dy in [(0,0),(1,0),(-1,0),(0,1),(0,-1)]:
   shift=dy*width+dx;contacts=p.mask&(q.mask>>shift if shift>=0 else q.mask<<-shift)
   # At most128 evenly distributed contact pixels per shift keeps proof cost bounded.
   stride=max(1,math.ceil(contacts.bit_count()/128));position=0
   while contacts:
    bit=contacts&-contacts;contacts^=bit
    if position%stride:position+=1;continue
    position+=1;index=bit.bit_length()-1;y,x=divmod(index,width);bx=x+dx;by=y+dy
    if not (0<=bx<width and 0<=by<height):continue
    rgb1=p.image[x-p.left,y-p.top];rgb2=q.image[bx-q.left,by-q.top]
    total+=sum((rgb1[k]-rgb2[k])**2 for k in range(3))/3;count+=1
  cost=total/count if count else 0.;cache[key]=cost;return cost
 nodes=0;best=math.inf;second=math.inf;winner=None;ties=0
 def search(remaining,chosen,cost):
  nonlocal nodes,best,second,winner,ties
  nodes+=1
  if nodes>max_nodes:raise SearchLimit(f'Pixel search exceeded {max_nodes} nodes; no certified mapping')
  if not remaining:
   if cost<best-1e-9:second=best;best=cost;winner=dict(chosen);ties=1
   elif abs(cost-best)<=1e-9:ties+=1;second=best
   elif cost<second:second=cost
   return
  # Minimum already-determined seam contribution for each remaining piece.
  ranked=[];bound=cost
  for piece,options in remaining.items():
   viable=[]
   for candidate in options:
    scores=[relation(candidate,assigned) for assigned in chosen.values()]
    if any(score is None for score in scores):continue
    viable.append((sum(scores),candidate))
   if not viable:return
   viable.sort();bound+=viable[0][0];ranked.append((len(viable),piece,viable))
  if bound>second+1e-9:return
  _,piece,options=min(ranked,key=lambda row:row[0]);next_remaining={p:list(opts) for p,opts in remaining.items() if p!=piece}
  for extra,candidate in options:
   if cost+extra>second+1e-9:continue
   # Forward checking includes alpha complementarity and the all-different slots.
   filtered={p:[other for other in opts if relation(candidate,other) is not None] for p,opts in next_remaining.items()}
   if any(not opts for opts in filtered.values()):continue
   chosen[piece]=candidate;search(filtered,chosen,cost+extra);del chosen[piece]
 search(dict(enumerate(domains)),{},0.)
 if winner is None:raise NoSolution('No canvas-fitting nonoverlapping alpha arrangement')
 if ties>1:raise AmbiguousPuzzle(f'{ties} arrangements share the best RGB seam cost {best:g}')
 selected=[placements[candidate] for candidate in winner.values()]
 max_overlap=max(((p.mask&q.mask).bit_count()/min(p.area,q.area) for i,p in enumerate(selected) for q in selected[i+1:]),default=0.)
 return {'mapping':{ids[piece]:placements[candidate].slot for piece,candidate in winner.items()},'diagnostics':{'status':'unique','nodes':nodes,'pair_checks':pair_checks,'method':'alpha constraints and RGB seam continuity','rgb_cost':best,'runner_up_cost':second if math.isfinite(second) else None,'flat_border_constraints':flat_border_constraints,'overlap_fraction':overlap_fraction,'maximum_observed_pair_overlap':max_overlap,'alpha_threshold':128,'contact_sample_limit_per_shift':128}}
