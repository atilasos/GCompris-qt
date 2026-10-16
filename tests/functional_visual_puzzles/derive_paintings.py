#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Propose piece positions from physical pixels and drawn orange circles."""
import argparse,hashlib,json,sys
from pathlib import Path
from PIL import Image
QA=Path(__file__).resolve().parent
sys.path.insert(0,str(QA.parent/'painting_pixel_solver'))
sys.path.insert(0,str(QA.parent))
from observation import solve_observed as silhouettes
from painting_rectangular_solver import solve_observed as rectangles

def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def derive(base):
 inventory=base/'inventory-paintings/result.json';calibration=base/'calibrate-paintings/result.json';boards=json.loads(inventory.read_text())['case_result']['boards'];calibrations=json.loads(calibration.read_text())['case_result']['boards'];answers={};models=[]
 for board in boards:
  level=board['level'];cal=next(b for b in calibrations if b['level']==level);sources=list(dict.fromkeys(p['source'] for page in board['pages'] for p in page));paths={s:base/'canonical/paintings/files/gcompris/src/activities/paintings/resource/image'/Path(s).name for s in sources};images={s:Image.open(p).convert('RGBA') for s,p in paths.items()}
  # The six opaque Bazille rectangles include black borders that defeat the
  # single-pixel seam model. This explicit alternate model has finite scope.
  if level==20:result=rectangles(images,board,cal,max_permutations=40320);method='rectangular-strips'
  else:result=silhouettes(images,board,cal,max_nodes=10000,overlap_fraction=.08,flat_border_constraints=True,canvas_padding=16);method='alpha-and-seams'
  frame=board['frame'];pieces={}
  for source,index in result['mapping'].items():
   circle=board['drawnCircles'][index];pieces[source]={'center':[(circle['x']-frame['x']+frame['width']/2)/frame['width'],(circle['y']-frame['y']+frame['height']/2)/frame['height']],'visible_circle_index':index,'piece_sha256':sha(paths[source]),'pixel_model':result['diagnostics'],'method':method}
  answers[str(level)]={'background':frame['source'],'answers':pieces};models.append({'level':level,'method':method,'result':result})
 return {'scope':'Pure pixel-model candidates requiring actual native confirmation','input_receipts':{'inventory':sha(inventory),'calibration':sha(calibration)},'paintings':answers,'models':models,'solver_sources':{str(p.relative_to(QA.parent)):sha(p) for directory in [QA.parent/'painting_pixel_solver',QA.parent/'painting_rectangular_solver'] for p in sorted(directory.glob('*.py'))}}
def main():
 p=argparse.ArgumentParser();p.add_argument('--base',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
 if a.output.exists() or a.output.is_symlink():p.error('Output must be new')
 result=derive(a.base)
 with a.output.open('x') as f:f.write(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
 print(json.dumps({'boards':len(result['paintings']),'pieces':sum(len(b['answers']) for b in result['paintings'].values()),'scope':result['scope']}))
if __name__=='__main__':main()
