#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Supplement the immutable 89 capture with physical image comparisons, no Qt."""
import hashlib,io,json,zipfile
from pathlib import Path
from pixels import png
CAPTURE_SHA='9b8e6aab0aac15a3c9f8bcd73dcaac8b62a0eb7040181f6c874dd51e27ebeb61'
ZIP_SHA='2fe09088b42e0cf41917e430ebf4ac97e19a48f3c5ddf50e04648ef6d6ef9395'
def sha(raw):return hashlib.sha256(raw).hexdigest()
class Capture:
 def __init__(self,root):
  root=Path(root)
  if root.is_symlink() or (root/'capture.json').is_symlink() or (root/'objects.zip').is_symlink():raise ValueError('Historical capsule must use physical files')
  raw=(root/'capture.json').read_bytes()
  if sha(raw)!=CAPTURE_SHA:raise ValueError('Historical capture literal anchor changed')
  self.capture=json.loads(raw)
  for name in ['pixels.py','curves.py']:
   if sha(Path(__file__).with_name(name).read_bytes())!=self.capture['files']['harness/'+name]:raise ValueError('Historical pure oracle module changed')
  parts=sorted(root.glob('objects.zip.[0-9][0-9][0-9]'))
  if parts:
   if [p.name for p in parts]!=[f'objects.zip.{i:03d}' for i in range(len(parts))] or any(p.is_symlink() for p in parts):raise ValueError('Invalid physical archive parts')
   raw=b''.join(p.read_bytes() for p in parts)
  else:raw=(root/'objects.zip').read_bytes()
  if sha(raw)!=ZIP_SHA:raise ValueError('Historical physical archive literal anchor changed')
  self.bundle=zipfile.ZipFile(io.BytesIO(raw));names=self.bundle.namelist()
  if len(names)!=len(set(names)) or set(names)!={'objects/'+digest for digest in self.capture['objects']}:raise ValueError('Historical archive objects changed')
 def blob(self,digest):
  raw=self.bundle.read('objects/'+digest)
  if sha(raw)!=digest:raise ValueError('Physical object changed')
  return raw
 def file(self,path):return self.blob(self.capture['files'][path])
 def receipt(self,name):return json.loads(self.file('cases/'+name+'/result.json'))
 def image(self,name,label):return png(self.file('cases/'+name+'/'+label+'.png'))
 def saved(self,name,filename):
  rows=self.capture['cases'][name]['saved_after_wait'];row=next(r for r in rows if r['name']==filename)
  if not row['exists_after_wait']:raise ValueError('Requested saved file absent')
  return self.blob(row['sha256'])
 def close(self):self.bundle.close()

def region(image,rect=None):
 width,height,channels,rows=image
 x,y,w,h=(0,0,width,height) if rect is None else tuple(round(v) for v in rect)
 if x<0 or y<0 or w<1 or h<1 or x+w>width or y+h>height:raise ValueError('Canvas outside physical image')
 output=[]
 for row in rows[y:y+h]:
  selected=row[x*channels:(x+w)*channels]
  if channels==3:output.append(selected)
  else:
   rgb=bytearray(w*3);rgb[0::3]=selected[0::4];rgb[1::3]=selected[1::4];rgb[2::3]=selected[2::4];output.append(bytes(rgb))
 return (w,h,b''.join(output))

def ink(raster):
 width,height,raw=raster
 return {(i//3%width,i//3//width) for i in range(0,len(raw),3) if max(raw[i:i+3])<200}

def maximum_delta(first,second):
 if first[:2]!=second[:2]:raise ValueError('Raster dimensions differ')
 return max(abs(a-b) for a,b in zip(first[2],second[2]))

def dilate(points,radius,width,height):
 return {(x+dx,y+dy) for x,y in points for dx in range(-radius,radius+1) for dy in range(-radius,radius+1) if 0<=x+dx<width and 0<=y+dy<height}

def dominant_ink(raster):
 from collections import Counter
 colors=Counter(raster[2][i:i+3] for i in range(0,len(raster[2]),3) if max(raster[2][i:i+3])<200)
 if not colors:raise ValueError('No actual painted pixels')
 return list(colors.most_common(1)[0][0])

def compare_reopened(saved,opened):
 if saved[:2]!=opened[:2]:raise ValueError('Reopened dimensions changed')
 a,b=ink(saved),ink(opened)
 if len(a)<1000 or len(b)<1000:raise ValueError('Reopened drawing is blank or incomplete')
 width,height=saved[:2]
 missing=a-dilate(b,1,width,height);extra=b-dilate(a,1,width,height)
 if missing or extra:raise ValueError('Reopened geometry differs by more than one pixel')
 if abs(len(a)-len(b))>len(a)*.01:raise ValueError('Reopened painted area differs by more than one percent')
 first,second=dominant_ink(saved),dominant_ink(opened)
 if max(abs(a-b) for a,b in zip(first,second))>2:raise ValueError('Reopened stroke color changed')
 return {'saved_ink_pixels':len(a),'opened_ink_pixels':len(b),'missing_beyond_one_pixel':len(missing),'extra_beyond_one_pixel':len(extra),'dominant_saved_rgb':first,'dominant_opened_rgb':second,'max_channel_delta':maximum_delta(saved,opened)}

def compare_vectors(saved,svg):
 import math,xml.etree.ElementTree as ET
 from curves import svg_paths
 root=ET.fromstring(svg);width,height=saved[:2]
 if (float(root.get('width')),float(root.get('height')))!=(width,height):raise ValueError('Physical PNG dimensions differ from SVG')
 if [float(v) for v in root.get('viewBox').split()]!=[0,0,width,height]:raise ValueError('Unexpected SVG coordinate space')
 points=set();paths=svg_paths(svg)
 for path in paths:
  if path['style'].get('stroke')!='#000000' or float(path['style'].get('stroke-width','0'))!=4 or float(path['style'].get('opacity','0'))!=.8:raise ValueError('Unexpected historical stroke style')
  vertices=path['points']
  for start,end in zip(vertices,vertices[1:]):
   count=max(1,math.ceil(math.hypot(end[0]-start[0],end[1]-start[1])))
   for step in range(count+1):points.add((round(start[0]+(end[0]-start[0])*step/count),round(start[1]+(end[1]-start[1])*step/count)))
 painted=ink(saved)
 if len(painted)<1000 or not points:raise ValueError('No nonempty saved drawing')
 if painted-dilate(points,3,width,height) or points-dilate(painted,3,width,height):raise ValueError('Physical PNG does not follow saved SVG vectors')
 # Black at opacity .8 on a white background has channel value 51.
 if dominant_ink(saved)!=[51,51,51]:raise ValueError('Physical PNG stroke color differs from SVG')
 return {'png_dimensions':[width,height],'svg_paths':len(paths),'ink_pixels':len(painted),'vector_samples':len(points),'vector_envelope_pixels':3,'dominant_rgb':dominant_ink(saved)}

def compare_undo_redo(completed,undone,redone):
 restored=maximum_delta(completed,redone)
 if restored>2:raise ValueError('Redo did not restore completed drawing')
 before,after=ink(completed),ink(undone)
 if len(before)-len(after)<1000:raise ValueError('Undo did not remove a substantial drawn stroke')
 if after-dilate(before,1,*completed[:2]):raise ValueError('Undo introduced unrelated dark pixels')
 lightening=sum(undone[2])-sum(completed[2])
 if lightening<=0:raise ValueError('Undo did not lighten the existing drawing')
 return {'completed_ink_pixels':len(before),'undone_ink_pixels':len(after),'removed_ink_pixels':len(before)-len(after),'redo_max_channel_delta':restored,'undo_lightening_sum':lightening}

def compare_preserved(before,after):
 if before!=after:raise ValueError('Cancelled operation lost or changed painted content')
 marks=sum(any(v<240 for v in before[2][i:i+3]) for i in range(0,len(before[2]),3))
 if marks<100:raise ValueError('Preservation check must contain actual work')
 return {'dimensions':list(before[:2]),'changed_rgb_bytes':0,'marked_pixels':marks}

def load_wheel(capture,level):
 name='wheels-levels-v4';receipt=capture.receipt(name);route=receipt['case_result']['evidence']['levels'][level-1];canvas=route['initial']['canvas'];rect=[canvas[k] for k in ['x','y','width','height']]
 return {'level':level,'receipt_sha256':sha(capture.file('cases/'+name+'/result.json')),'frames':{key:region(capture.image(name,f'level-{level}-'+key),rect) for key in ['saved','opened','completed','undo','redo']},'physical_png':region(png(capture.saved(name,f'RODAS{level}.png'))),'svg':capture.saved(name,f'RODAS{level}.svg')}

def check_wheel(observation):
 frames=observation['frames'];saved=observation['physical_png']
 if saved!=frames['saved']:raise ValueError('Physical PNG differs from complete scene at save')
 return {'level':observation['level'],'receipt_sha256':observation['receipt_sha256'],'physical_png':compare_vectors(saved,observation['svg']),'physical_png_matches_saved_scene_exactly':True,'reopened':compare_reopened(frames['saved'],frames['opened']),'undo_redo':compare_undo_redo(frames['completed'],frames['undo'],frames['redo'])}

def audit(root):
 capture=Capture(root)
 try:
  wheels=[check_wheel(load_wheel(capture,level)) for level in [1,2]];preserved=[]
  for name,before,after in [('wheels-controls-v2','before-partial-exit','partial-exit-preserved'),('sketch-controls-v5','pattern-drawing','partial-home-preserved'),('sketch-controls-v5','partial-home-preserved','new-cancel-preserved')]:
   receipt=capture.receipt(name);canvas=receipt['case_result']['evidence']['canvas'];rect=[canvas[k] for k in ['x','y','width','height']];result=compare_preserved(region(capture.image(name,before),rect),region(capture.image(name,after),rect));preserved.append({'case':name,'before':before,'after':after,'receipt_sha256':sha(capture.file('cases/'+name+'/result.json')),**result})
  png_files=[]
  mapping=[('wheels-levels-v4','RODAS1.png','level-1-saved'),('wheels-levels-v4','RODAS2.png','level-2-saved'),('wheels-controls-v2','CONTROLO.png','saved'),('wheels-controls-v2','CONTROLO2.png','partial-exit-preserved'),('wheels-controls-v2','FUNDO.png','green-background'),('sketch-tracer-v6','CRIAÇÃO.png','saved'),('sketch-tools-v3','artes.png','finished'),('sketch-controls-v5','CORES.png','saved-palette-work'),('sketch-background-v2','FOTO.png','photo-background'),('sketch-background-v2','FUNDO.png','orange-background')]
  for name,filename,scene in mapping:
   evidence=capture.receipt(name)['case_result']['evidence'];canvas=evidence['canvas'] if 'canvas' in evidence else evidence['levels'][int(filename[5])-1]['initial']['canvas'];rect=[canvas[k] for k in ['x','y','width','height']];physical=capture.saved(name,filename);raster=region(png(physical));drawn=region(capture.image(name,scene),rect)
   if raster!=drawn:raise ValueError('Physical PNG differs from actual saved creation: '+name+'/'+filename)
   png_files.append({'case':name,'file':filename,'sha256':sha(physical),'scene':scene,'dimensions':list(raster[:2]),'changed_rgb_bytes':0})
  return {'format':1,'capture_sha256':CAPTURE_SHA,'archive_sha256':ZIP_SHA,'new_native_runs':0,'wheels':wheels,'preserved':preserved,'saved_png_files':png_files,'scope':'Supplement to existing receipts only; original coverage and diagnostic statuses unchanged.'}
 finally:capture.close()

if __name__=='__main__':
 import argparse
 if not __debug__:raise SystemExit('Creation image supplement rejects Python -O')
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--capsule',type=Path,default=Path(__file__).resolve().parents[2]/'.scratch/pt-pt/functional-creation/portable-capsule');args=parser.parse_args();print(json.dumps(audit(args.capsule),indent=2))
