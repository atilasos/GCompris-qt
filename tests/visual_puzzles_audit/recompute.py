# SPDX-License-Identifier: GPL-3.0-or-later
"""Recalculate oracles from preserved visible pixels, never authored answers."""
import io,json,sys
from functools import lru_cache
from pathlib import Path
from PIL import Image
from store import require,sha
TESTS=Path(__file__).resolve().parent.parent
sys.path.insert(0,str(TESTS/'functional_visual_puzzles'))
sys.path.insert(0,str(TESTS/'painting_pixel_solver'))
from pixels import locate_detail,difference_points
from observation import solve_observed

def asset(reader,activity,url):
 require(url.startswith('qrc:/gcompris/'),'Unexpected public image URI')
 return reader.artifact('canonical/'+activity+'/files/'+url[len('qrc:/'):])
@lru_cache(maxsize=160)
def detail(piece,background):return locate_detail(Image.open(io.BytesIO(piece)),Image.open(io.BytesIO(background)))
@lru_cache(maxsize=16)
def photo(scene_bytes,geometry):
 scene=Image.open(io.BytesIO(scene_bytes));frames=json.loads(geometry);crops=[];boxes=[]
 for frame in frames:
  x=round(frame['x']-frame['width']/2);y=round(frame['y']-frame['height']/2);box=[x,y,x+round(frame['width']),y+round(frame['height'])]
  require(min(box)>=0 and box[2]<=scene.width and box[3]<=scene.height,'Actual photo frame outside screenshot');boxes.append(box);crops.append(scene.crop(box))
 candidates=difference_points(*crops);candidates.sort(key=lambda row:(-row['pixels'],row['pixel'][1],row['pixel'][0]));require(candidates,'No actual visible differences')
 wrong=None
 for x,y in [(10,10),(crops[0].width-10,10),(10,crops[0].height-10),(crops[0].width-10,crops[0].height-10)]:
  if all(max(row['box'][0]-x,0,x-row['box'][2])**2+max(row['box'][1]-y,0,y-row['box'][3])**2>45**2 for row in candidates):wrong=[x,y];break
 require(wrong is not None,'No visibly unchanged wrong-test corner')
 return {'crop_boxes':boxes,'candidates':candidates,'image_size':list(crops[0].size),'wrong_pixel':wrong,'scene_sha256':sha(scene_bytes)}
@lru_cache(maxsize=30)
def painting(image_pairs,board_json,calibration_json,rectangular=False):
 images={source:Image.open(io.BytesIO(raw)).convert('RGBA') for source,raw in image_pairs};board=json.loads(board_json);calibration=json.loads(calibration_json)
 if rectangular:
  # The final rectangular helper is supplied by its owning task before sealing.
  sys.path.insert(0,str(TESTS))
  from painting_rectangular_solver import solve_observed as solve_rectangular
  return solve_rectangular(images,board,calibration,max_permutations=40320)
 return solve_observed(images,board,calibration,overlap_fraction=.08,flat_border_constraints=True,canvas_padding=16,max_nodes=10000)

def oracles(reader,receipts,runs):
 inventory={contract['activity']:receipts[name]['case_result']['boards'] for name,contract in runs.items() if contract['kind']=='inventory'}
 require(set(inventory)=={'details','paintings','photo_hunter'},'Three public inventories')
 answers={'details':{},'paintings':{},'photo_hunter':{}}
 for board in inventory['details']:
  background=asset(reader,'details',board['frame']['source']);image=Image.open(io.BytesIO(background));pieces={p['source']:p for page in board['pages'] for p in page};matched={}
  for source in pieces:
   raw=asset(reader,'details',source);match=dict(detail(raw,background));box=match['pixel_box'];match.update(center=[(box[0]+box[2])/2/image.width,(box[1]+box[3])/2/image.height],piece_sha256=sha(raw));matched[source]=match
  answers['details'][board['level']]={'background':board['frame']['source'],'answers':matched}
 photo_inventory_name=next(name for name,c in runs.items() if c['kind']=='inventory' and c['activity']=='photo_hunter')
 for board in inventory['photo_hunter']:
  scene=reader.artifact('runs/'+photo_inventory_name+'/level-'+str(board['level'])+'-question.png');answers['photo_hunter'][board['level']]=photo(scene,json.dumps([board['left'],board['right']],sort_keys=True))
 calibration=next(receipts[name]['case_result']['boards'] for name,c in runs.items() if c['kind']=='calibration');cal_by_level={c['level']:c for c in calibration}
 for board in inventory['paintings']:
  pieces=list(dict.fromkeys(p['source'] for page in board['pages'] for p in page));pairs=tuple((source,asset(reader,'paintings',source)) for source in pieces)
  # Level20's rectilinear legacy cuts need a different validated pixel model.
  model=painting(pairs,json.dumps(board,sort_keys=True),json.dumps(cal_by_level[board['level']],sort_keys=True),rectangular=board['level']==20);frame=board['frame'];matched={}
  for source,slot in model['mapping'].items():
   circle=board['drawnCircles'][slot];matched[source]={'center':[(circle['x']-(frame['x']-frame['width']/2))/frame['width'],(circle['y']-(frame['y']-frame['height']/2))/frame['height']],'visible_circle_index':slot,'piece_sha256':sha(dict(pairs)[source]),'pixel_model':model['diagnostics'],'method':'rectangular-strips' if board['level']==20 else 'alpha-and-seams'}
  answers['paintings'][board['level']]={'background':board['frame']['source'],'answers':matched}
 return inventory,answers
