#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Encode approved local synthesis output as Ogg Vorbis, verify decoding/hashes."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--wav-dir', type=Path, required=True)
    parser.add_argument('--output-dir', type=Path, required=True)
    args = parser.parse_args()
    manifest = json.loads((args.wav_dir / 'manifest.json').read_text())
    manifest['encoder'] = 'GStreamer audioconvert/vorbisenc quality=0.5/oggmux'
    for row in manifest['recordings']:
        wav = args.wav_dir / Path(row['file']).with_suffix('.wav')
        if hashlib.sha256(wav.read_bytes()).hexdigest() != row['wav_sha256']:
            parser.error(f'WAV hash differs: {wav}')
        target = args.output_dir / row['file']
        target.parent.mkdir(parents=True, exist_ok=True)
        temporary = target.with_suffix('.partial')
        subprocess.run(['gst-launch-1.0', '-q', 'filesrc', f'location={wav}', '!', 'wavparse',
                        '!', 'audioconvert', '!', 'vorbisenc', 'quality=0.5', '!', 'oggmux',
                        '!', 'filesink', f'location={temporary}'], check=True)
        subprocess.run(['gst-launch-1.0', '-q', 'filesrc', f'location={temporary}', '!', 'decodebin',
                        '!', 'audioconvert', '!', 'fakesink'], check=True)
        temporary.replace(target)
        row.update(sha256=hashlib.sha256(target.read_bytes()).hexdigest(), bytes=target.stat().st_size,
                   decode='passed')
    (args.output_dir / 'manifest.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n')


if __name__ == '__main__':
    main()
