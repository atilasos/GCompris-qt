#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Synthesize the 32 approved missing PT-PT resources with a local Piper model.

No downloads. Does not alter or regenerate original recordings. Generate WAVs
first; encode_voices.py converts them to distribution OGG using local GStreamer.
"""
import argparse
import hashlib
import importlib.metadata
import json
from pathlib import Path
import wave
from piper import PiperVoice

ROOT = Path(__file__).resolve().parents[2]


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--model', type=Path, required=True)
    parser.add_argument('--wav-dir', type=Path, required=True)
    args = parser.parse_args()
    spec = json.loads((ROOT / 'resources/pt-pt-voices/texts.json').read_text())
    if sha(args.model) != spec['model_sha256'] or sha(Path(str(args.model) + '.json')) != spec['config_sha256']:
        parser.error('Model or unmodified configuration hash differs from approved samples')
    version = importlib.metadata.version('piper-tts')
    if version != '1.8.0':
        parser.error('This generation is pinned to Piper 1.8.0')
    voice = PiperVoice.load(args.model)
    results = []
    for row in spec['recordings']:
        target = args.wav_dir / Path(row['file']).with_suffix('.wav')
        target.parent.mkdir(parents=True, exist_ok=True)
        with wave.open(str(target), 'wb') as wav:
            voice.synthesize_wav(row['text'], wav)
        with wave.open(str(target)) as wav:
            results.append(dict(row, wav_sha256=sha(target), frames=wav.getnframes(),
                                sample_rate=wav.getframerate(), channels=wav.getnchannels(),
                                sample_width=wav.getsampwidth()))
        print(row['file'], flush=True)
    spec.update(piper_version=version, config_override=False, recordings=results)
    (args.wav_dir / 'manifest.json').write_text(json.dumps(spec, ensure_ascii=False, indent=2) + '\n')


if __name__ == '__main__':
    main()
