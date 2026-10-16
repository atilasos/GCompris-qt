#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Inventory every original erase resource and decode its images and WAV files."""
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
from pathlib import Path
import re
import subprocess
import wave
import xml.etree.ElementTree as ET
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
HERE = ROOT / '.scratch/pt-pt/functional-erase'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def decode(path):
    record = {'file':str(path.relative_to(ROOT)), 'sha256':sha(path), 'bytes':path.stat().st_size}
    if path.suffix == '.webp':
        with Image.open(path) as image:
            image.load()
            assert image.format == 'WEBP' and image.width > 0 and image.height > 0
            record.update(codec='WEBP', type='video', width=image.width, height=image.height,
                          decoder='Pillow full pixel decode')
    else:
        subprocess.run(['gst-launch-1.0', '-q', 'filesrc', 'location='+str(path),
                        '!', 'decodebin', '!', 'audioconvert', '!', 'fakesink'],
                       check=True, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
        with wave.open(str(path), 'rb') as audio:
            assert audio.getnframes() > 0 and audio.getframerate() > 0
            record.update(codec=audio.getcomptype(), type='audio', sample_rate=audio.getframerate(),
                          channels=audio.getnchannels(), duration=audio.getnframes()/audio.getframerate(),
                          decoder='GStreamer decodebin/audioconvert/fakesink')
    return record


def audit():
    source = ROOT / 'src/activities/erase'
    script = (source / 'erase.js').read_text()
    image_names = re.findall(r'\["([^"]+\.webp)"', script)
    images = sorted((source / 'resource').glob('*.webp'))
    assert len(image_names) == len(set(image_names)) == len(images) == 33
    assert set(image_names) == {path.name for path in images}
    masks = sorted((source / 'resource').glob('transparent_square*.svg'))
    assert len(masks) == 3
    for path in masks:
        assert ET.parse(path).getroot().tag.endswith('svg')
    sounds = sorted((source / 'resource').glob('*.wav')) + [ROOT / 'src/core/resource/sounds/completetask.wav']
    assert len(sounds) == 3
    with ThreadPoolExecutor(max_workers=4) as pool:
        decoded = list(pool.map(decode, images + sounds))
    files = {}
    for name in ('erase', 'erase_clic', 'erase_2clic'):
        for path in sorted((ROOT / 'src/activities' / name).rglob('*')):
            if path.is_file():
                files[str(path.relative_to(ROOT))] = sha(path)
    return {'levels':6, 'images_per_level':6,
            'drawn_grid_by_level':[{'level':i+1, 'columns':5 if i%2==0 else 8, 'rows':5 if i%2==0 else 8} for i in range(6)],
            'image_names':image_names, 'decoded_resources':decoded,
            'mask_sha256':{path.name:sha(path) for path in masks}, 'source_files_sha256':files,
            'scope':'All original resources decoded; no SoundEffect playback, hardware audition or pronunciation claim.'}


if __name__ == '__main__':
    report = audit()
    (HERE / 'data.json').write_text(json.dumps(report, ensure_ascii=False, indent=2)+'\n')
    print(json.dumps({'images':len(report['image_names']), 'decoded':len(report['decoded_resources']),
                      'masks':len(report['mask_sha256']), 'source_files':len(report['source_files_sha256'])}))
