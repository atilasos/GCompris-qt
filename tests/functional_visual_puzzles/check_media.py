#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Decode physical offline images and four reachable effects, without playback."""
import argparse,hashlib,json,subprocess
from pathlib import Path
from PIL import Image,__version__
from svg import render

def main():
 p=argparse.ArgumentParser();p.add_argument('--canonical',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
 if a.output.exists() or a.output.is_symlink():p.error('Output must be new')
 a.output.mkdir(parents=True);records=[]
 for name in ['core','babymatch','details','paintings','photo_hunter','guesscount','tic_tac_toe']:
  for source in sorted((a.canonical/name/'files').rglob('*')):
   if not source.is_file():continue
   suffix=source.suffix.lower()
   if suffix not in ['.webp','.png','.jpg','.jpeg','.svg']:continue
   row={'file':str(source.relative_to(a.canonical)),'sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'bytes':source.stat().st_size}
   if suffix=='.svg':
    target=a.output/f'render-{len(records)}.png';render(source,target);row.update({'renderer':'librsvg-2.so.2 with libcairo.so.2','render_size':160,'exit_code':0})
   else:target=source
   with Image.open(target) as img:img.load();row.update({'width':img.width,'height':img.height,'mode':img.mode})
   records.append(row)
 sounds=[]
 for name in ['brick','bleep','completetask','crash']:
  source=a.canonical/'core/files/gcompris/src/core/resource/sounds'/f'{name}.wav';cmd=['gst-launch-1.0','-q','filesrc','location='+str(source.absolute()),'!','decodebin','!','audioconvert','!','fakesink'];result=subprocess.run(cmd,capture_output=True,text=True,timeout=30);row={'file':str(source.relative_to(a.canonical)),'sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'argv':cmd,'exit_code':result.returncode,'stdout':result.stdout,'stderr':result.stderr};sounds.append(row)
  if result.returncode:raise RuntimeError(row)
 (a.output/'report.json').write_text(json.dumps({'scope':'Physical software decode/render, without human listening or device testing','pillow':__version__,'images':records,'sounds':sounds},indent=2)+'\n');print(json.dumps({'images':len(records),'sounds':len(sounds),'exit_code':0}))
if __name__=='__main__':main()
