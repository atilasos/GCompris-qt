#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Generate only three review samples from a separately downloaded local model.

Requires piper-tts (tested1.8.0). Does not install packages, download a model,
modify game resources or generate letter/phoneme recordings.
"""
import argparse
import hashlib
import importlib.metadata
import json
from pathlib import Path
import wave

from piper import PiperVoice

SAMPLES = {
    'polygons': 'Desenha os polígonos pedidos, clicando na grelha.',
    'sixteen': 'Clica numa seta para deslocares a respetiva linha ou coluna nessa direção. Coloca todas as peças pela ordem correta. Os números nas peças podem ajudar-te.',
    'vocabulario': 'O comboio chega à estação. O autocarro leva dezasseis crianças e dezassete mochilas.',
}


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--model', type=Path, required=True)
    parser.add_argument('--output-dir', type=Path, required=True)
    args = parser.parse_args()
    args.output_dir.mkdir(parents=True, exist_ok=True)
    model = PiperVoice.load(args.model)
    samples = []
    for name, text in SAMPLES.items():
        path = args.output_dir / f'{name}.wav'
        with wave.open(str(path), 'wb') as wav:
            model.synthesize_wav(text, wav)
        with wave.open(str(path)) as wav:
            samples.append({'file': path.name, 'text': text, 'sha256': sha256(path),
                            'frames': wav.getnframes(), 'sample_rate': wav.getframerate(),
                            'channels': wav.getnchannels(), 'sample_width': wav.getsampwidth()})
    manifest = {'status': 'awaiting-teacher-approval', 'piper_version': importlib.metadata.version('piper-tts'),
                'model_sha256': sha256(args.model), 'config_sha256': sha256(Path(str(args.model) + '.json')),
                'model_name': 'pt_PT-tugão-medium', 'config_override': False,
                'sample_only': True, 'samples': samples}
    (args.output_dir / 'manifest.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n')


if __name__ == '__main__':
    main()
