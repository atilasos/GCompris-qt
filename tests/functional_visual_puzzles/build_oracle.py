#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Derive candidate locations solely from actual picture pixels and UI frames."""
import argparse,hashlib,json
from pathlib import Path
from PIL import Image
from pixels import locate_detail,difference_points
ROOT=Path(__file__).resolve().parents[2]
BASE=ROOT/'.scratch/pt-pt/functional-visual-puzzles'
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def asset(activity,url):
 relative=url.removeprefix('qrc:/gcompris/')
 path=BASE/'canonical'/activity/'files/gcompris'/relative
 if not url.startswith('qrc:/gcompris/') or not path.is_file():raise ValueError('Actual canonical image missing')
 return path

def build():
 output={'details':{},'photo_hunter':{},'input_receipts':{},'canonical_index_sha256':sha(BASE/'canonical/index.json'),'unresolved':[]}
 for activity in ['details','photo_hunter']:
  receipt=BASE/('inventory-'+activity)/'result.json';native=json.loads(receipt.read_text());output['input_receipts'][activity]=sha(receipt)
  if not native['passed']:raise ValueError('Inventory did not pass')
  for board in native['case_result']['boards']:
   level=str(board['level'])
   if activity=='details':
    background=Image.open(asset(activity,board['frame']['source']));answers={}
    for piece in board['pieces']:
     path=asset(activity,piece['source'])
     try:
      answer=locate_detail(Image.open(path),background);box=answer['pixel_box'];answer['center']=[(box[0]+box[2])/2/background.width,(box[1]+box[3])/2/background.height];answer['piece_sha256']=sha(path);answers[piece['source']]=answer
     except ValueError as error:output['unresolved'].append({'activity':activity,'level':level,'piece':piece['source'],'error':str(error)})
    output[activity][level]={'background':board['frame']['source'],'background_sha256':sha(asset(activity,board['frame']['source'])),'answers':answers}
   else:
    scene=Image.open(BASE/'inventory-photo_hunter'/('level-'+level+'-question.png'));crops=[];boxes=[]
    for side in ['left','right']:
     frame=board[side];x=round(frame['x']-frame['width']/2);y=round(frame['y']-frame['height']/2);box=[x,y,x+round(frame['width']),y+round(frame['height'])]
     if min(box)<0 or box[2]>scene.width or box[3]>scene.height:raise ValueError('Visible picture outside scene')
     boxes.append(box);crops.append(scene.crop(box))
    candidates=difference_points(*crops);candidates.sort(key=lambda row:(-row['pixels'],row['pixel'][1],row['pixel'][0]))
    if not candidates:raise ValueError('No independently visible differences')
    wrong=None
    for x,y in [(10,10),(crops[0].width-10,10),(10,crops[0].height-10),(crops[0].width-10,crops[0].height-10)]:
     if all(max(row['box'][0]-x,0,x-row['box'][2])**2+max(row['box'][1]-y,0,y-row['box'][3])**2>45**2 for row in candidates):wrong=[x,y];break
    if wrong is None:raise ValueError('No visibly unchanged corner sufficiently far from all differences')
    output[activity][level]={'crop_boxes':boxes,'scene_sha256':sha(BASE/'inventory-photo_hunter'/('level-'+level+'-question.png')),'candidates':candidates,'image_size':list(crops[0].size),'wrong_pixel':wrong}
 return output

def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True);args=parser.parse_args()
 if args.output.exists():parser.error('Output must be new')
 result=build()
 with args.output.open('x') as stream:stream.write(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
 print(json.dumps({'details':sum(len(row['answers']) for row in result['details'].values()),'photo_levels':len(result['photo_hunter']),'photo_candidates':sum(len(row['candidates']) for row in result['photo_hunter'].values()),'unresolved':result['unresolved']}))
 return 1 if result['unresolved'] else 0
if __name__=='__main__':raise SystemExit(main())
