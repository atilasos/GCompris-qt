# SPDX-License-Identifier: GPL-3.0-or-later
"""Bind historical software decode observations to physical canonical bytes."""
import io
from PIL import Image
from store import require,sha

def verify_media(reader):
 report=reader.json('auxiliary/media-check2/report.json');require(report['pillow']=='12.1.1' and len(report['images'])==562 and len(report['sounds'])==4,'Finite physical media inventory')
 expected={path.removeprefix('canonical/') for path in reader.capture['files'] if path.startswith('canonical/') and '/files/' in path and path.lower().endswith(('.webp','.png','.jpg','.jpeg','.svg'))};require({r['file'] for r in report['images']}==expected,'Every canonical displayed image covered')
 raster=svg=0
 for index,row in enumerate(report['images']):
  raw=reader.artifact('canonical/'+row['file']);require(sha(raw)==row['sha256'] and len(raw)==row['bytes'],'Actual decoded/rendered source bytes')
  if row['file'].lower().endswith('.svg'):
   require(row['exit_code']==0 and row['render_size']==160 and row['renderer']=='librsvg-2.so.2 with libcairo.so.2','Historical SVG rendering observation');raw=reader.artifact('auxiliary/media-check2/render-'+str(index)+'.png');svg+=1
  else:raster+=1
  image=Image.open(io.BytesIO(raw));image.load();require((image.width,image.height,image.mode)==(row['width'],row['height'],row['mode']),'Physical image/render can be decoded by pure Pillow')
 for sound in report['sounds']:
  raw=reader.artifact('canonical/'+sound['file']);require(sha(raw)==sound['sha256'] and raw.startswith(b'RIFF') and sound['exit_code']==0 and sound['argv'][-1]=='fakesink','Physical WAV and historical integral software decoder return')
 failed=reader.json('auxiliary/media-check1/failure.json');require(failed['kind']=='missing-local-executable' and failed['command']=='rsvg-convert' and failed['external_exit_code']==1,'Prerequisite failure preserved without product conclusion')
 return {'physical_images':562,'raster_decoded':raster,'svg_historical_renders':svg,'wav_historical_software_decodes':4,'human_audio_approval_claimed':False}
