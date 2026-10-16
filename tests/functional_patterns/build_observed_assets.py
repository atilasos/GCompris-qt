#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Bind native painted colors and actual exported image pixels to public URIs."""
import hashlib
import json
from pathlib import Path
from PIL import Image
from svg import render
ROOT = Path(__file__).resolve().parents[2]
BASE = ROOT / '.scratch/pt-pt/functional-patterns'

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    output = ROOT / 'tests/functional_patterns/observed-assets.json'
    render_dir = BASE / 'canonical/mosaic/rendered'
    if output.exists() or output.is_symlink() or render_dir.exists() or render_dir.is_symlink():
        raise ValueError('Outputs must be new')
    records = {'scope': 'Public source URIs locate actual resource bytes; image signatures hash normalized RGBA pixels. Native colors come from painted rectangles, including Qt ARGB white.', 'palette_samples': {}, 'calibration_receipts': {}, 'images': {}}
    for name in ('redraw', 'redraw_symmetrical'):
        receipt = BASE / ('calibrate2-' + name) / 'result.json'
        case = json.loads(receipt.read_text())['case_result']
        if case['failures'] or len(case['samples']) != 7:
            raise ValueError('Incomplete native palette calibration')
        records['palette_samples'][name] = [{'id': s['id'], 'signature': s['signature']} for s in case['samples']]
        records['calibration_receipts'][name] = digest(receipt)
    render_dir.mkdir()
    for path in sorted((BASE / 'canonical/mosaic/files/gcompris/src/activities/mosaic/resource').glob('*.svg')):
        rendered = render_dir / (path.stem + '.png')
        render(path, rendered)
        with Image.open(rendered) as picture:
            picture = picture.convert('RGBA')
            pixels = hashlib.sha256(picture.tobytes()).hexdigest()
        uri = 'qrc:/' + path.relative_to(BASE / 'canonical/mosaic/files').as_posix()
        records['images'][uri] = {'signature': 'rgba160-sha256:' + pixels, 'resource_sha256': digest(path), 'rendered_sha256': digest(rendered), 'rendered': rendered.relative_to(ROOT).as_posix()}
    if not records['images']:
        raise ValueError('No actual resource pictures')
    with output.open('x') as stream:
        stream.write(json.dumps(records, ensure_ascii=False, indent=2) + '\n')
    print(json.dumps({'palette_samples': {k: len(v) for k,v in records['palette_samples'].items()}, 'images': len(records['images'])}))

if __name__ == '__main__':
    main()
