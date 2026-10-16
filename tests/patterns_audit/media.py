# SPDX-License-Identifier: GPL-3.0-or-later
"""Verify physical image decodes and historical software-only sound decodes."""
import io
from PIL import Image, ImageSequence
from store import require, sha

def verify_media(reader):
    report=reader.json('auxiliary/media-check/report.json')
    require(report['pillow']=='12.1.1' and len(report['images'])==120 and len(report['sounds'])==15,'Finite canonical media inventory')
    prefix='canonical/'
    expected={p.removeprefix(prefix) for p in reader.capture['files'] if p.startswith(prefix) and '/files/' in p and p.lower().endswith(('.svg','.png','.jpg','.jpeg','.webp','.gif'))}
    require({r['file'] for r in report['images']}==expected,'All canonical image files checked')
    for index,row in enumerate(report['images']):
        raw=reader.artifact(prefix+row['file'])
        require(sha(raw)==row['sha256'] and len(raw)==row['bytes'],'Physical image input identity')
        if row['file'].endswith('.svg'):
            require(row['exit_code']==0 and row['render_size']==160 and row['renderer']=='librsvg-2.so.2 with libcairo.so.2','Historical SVG renderer observation')
            raw=reader.artifact(f'auxiliary/media-check/render-{index}.png')
        picture=Image.open(io.BytesIO(raw));picture.load()
        require((picture.width,picture.height,picture.mode)==(row['width'],row['height'],row['mode']),'Image metadata recomputed from physical bytes')
        for frame in ImageSequence.Iterator(picture):frame.load()
    sounds={p.removeprefix(prefix) for p in reader.capture['files'] if p.startswith(prefix) and '/files/' in p and p.lower().endswith(('.wav','.ogg'))}
    require({r['file'] for r in report['sounds']}==sounds,'Every canonical sound accounted for')
    for row in report['sounds']:
        raw=reader.artifact(prefix+row['file'])
        require(sha(raw)==row['sha256'] and raw.startswith(b'RIFF' if row['file'].endswith('.wav') else b'OggS'),'Physical sound format and identity')
        require(row['exit_code']==0 and row['argv'][-1]=='fakesink' and row['argv'][0]=='gst-launch-1.0','Historical full software decoder result; no physical playback claim')
    return {'images':120,'historical_sound_decodes':15,'human_hearing_claimed':False}
