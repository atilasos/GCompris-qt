#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Observe the pure solver on existing native inventories; never run Qt."""
import argparse,hashlib,json,time
from pathlib import Path
from PIL import Image,__version__
from observation import solve_observed

def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def main():
 parser=argparse.ArgumentParser();parser.add_argument('--inventory',type=Path,required=True);parser.add_argument('--calibration',type=Path,required=True);parser.add_argument('--images',type=Path,required=True);parser.add_argument('--levels',default='1,2,3');parser.add_argument('--overlap-fraction',type=float,default=.08);parser.add_argument('--max-nodes',type=int,default=10000);parser.add_argument('--flat-borders',action='store_true');parser.add_argument('--canvas-padding',type=int,default=0);parser.add_argument('--output',type=Path,required=True);args=parser.parse_args()
 if args.output.exists() or args.output.is_symlink():raise FileExistsError('Use a fresh pure-observation output')
 inventory=json.loads(args.inventory.read_text())['case_result']['boards'];calibration=json.loads(args.calibration.read_text())['case_result']['boards'];records=[]
 for level in map(int,args.levels.split(',')):
  board=next(b for b in inventory if b['level']==level);cal=next(b for b in calibration if b['level']==level);sources=list(dict.fromkeys(p['source'] for page in board['pages'] for p in page))
  # URI basename only locates the physical bytes; it never implies placement.
  paths={source:args.images/Path(source).name for source in sources};images={source:Image.open(path).convert('RGBA') for source,path in paths.items()};start=time.monotonic()
  record={'level':level,'pieces':len(images),'piece_sha256':{s:sha(p) for s,p in paths.items()}}
  try:record['result']=solve_observed(images,board,cal,max_nodes=args.max_nodes,overlap_fraction=args.overlap_fraction,flat_border_constraints=args.flat_borders,canvas_padding=args.canvas_padding)
  except ValueError as error:record.update({'refused':type(error).__name__,'reason':str(error)})
  record['seconds']=round(time.monotonic()-start,6);records.append(record);print(json.dumps(record),flush=True)
 output={'solver_source_sha256':{name:sha(Path(__file__).with_name(name)) for name in ['solver.py','observation.py','probe.py']},'canvas_padding':args.canvas_padding,'flat_border_constraints':args.flat_borders,'scope':'Pure pixel-model candidates; no native placement or game conclusion claimed','pillow':__version__,'inventory_sha256':sha(args.inventory),'calibration_sha256':sha(args.calibration),'overlap_fraction':args.overlap_fraction,'max_nodes':args.max_nodes,'observations':records}
 with args.output.open('x') as stream:stream.write(json.dumps(output,ensure_ascii=False,indent=2)+'\n')
if __name__=='__main__':main()
