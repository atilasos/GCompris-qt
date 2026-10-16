#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Encode the two exact teacher-approved WAVs. Never synthesize a new voice."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile
import wave

from complete_voices import APPROVAL_SHA256, APPROVED_LEGACY, ROOT


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def encode(approval, samples, output):
    if output.is_symlink() or output.exists():
        raise ValueError('New encoding output required')
    if sha(approval) != APPROVAL_SHA256:
        raise ValueError('Exact teacher approval identity required')
    decision = json.loads(approval.read_text(encoding='utf-8'))
    expected = {(Path(name).name, row['text'], row['wav'], row['wav_sha256'])
                for name, row in APPROVED_LEGACY.items()}
    if {(r['key'], r['text'], r['wav'], r['wav_sha256'])
            for r in decision['recordings']} != expected:
        raise ValueError('Approval does not identify the exact two WAVs')
    for row in APPROVED_LEGACY.values():
        if sha(samples / row['wav']) != row['wav_sha256']:
            raise ValueError('Approved WAV bytes changed')
    output.mkdir(parents=True)
    rows = []
    version = subprocess.check_output(['gst-launch-1.0', '--version'], text=True).strip()
    for name, approved in APPROVED_LEGACY.items():
        wav = samples / approved['wav']
        target = output / name
        target.parent.mkdir(parents=True, exist_ok=True)
        with wave.open(str(wav)) as stream:
            audio = {'frames': stream.getnframes(), 'sample_rate': stream.getframerate(),
                     'channels': stream.getnchannels(), 'sample_width': stream.getsampwidth()}
        command = ['gst-launch-1.0', '-q', 'filesrc', 'location=' + str(wav),
                   '!', 'wavparse', '!', 'audioconvert', '!', 'vorbisenc', 'quality=0.5',
                   '!', 'oggmux', '!', 'filesink', 'location=' + str(target)]
        subprocess.run(command, check=True)
        with tempfile.TemporaryDirectory(prefix='legacy decode ', dir=output) as temporary:
            pcm = Path(temporary) / 'decoded.pcm'
            decode = ['gst-launch-1.0', '-q', 'filesrc', 'location=' + str(target),
                      '!', 'decodebin', '!', 'audioconvert',
                      '!', 'audio/x-raw,format=S16LE,rate=22050,channels=1',
                      '!', 'filesink', 'location=' + str(pcm)]
            subprocess.run(decode, check=True)
            if pcm.stat().st_size != audio['frames'] * 2:
                raise ValueError('Encoded duration differs from approved WAV')
            decoded_sha = sha(pcm)
        rows.append({'file': name, **approved, **audio, 'sha256': sha(target),
                     'bytes': target.stat().st_size, 'decode': 'passed',
                     'decoded_pcm_sha256': decoded_sha,
                     'encoding_command': command, 'decode_command': decode})
    result = {'format': 1,
              'scope': 'Two approved source WAVs encoded for distribution; the teacher did not audition these OGG bytes',
              'human_approval_sha256': sha(approval),
              'review_archive_sha256': decision['archive_sha256'],
              'source_wav_review': 'approved', 'derived_ogg_human_review': 'not-performed',
              'encoder': 'GStreamer audioconvert/vorbisenc quality=0.5/oggmux',
              'gstreamer_version': version, 'recordings': rows}
    (output / 'replacements.json').write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n', encoding='utf-8', newline='\n')
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--approval', type=Path,
                        default=ROOT / '.scratch/pt-pt/legacy-word-review/human-approval.json')
    parser.add_argument('--samples', type=Path,
                        default=ROOT / '.scratch/pt-pt/legacy-word-review/samples')
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps(encode(args.approval.resolve(), args.samples.resolve(), args.output), ensure_ascii=False))
