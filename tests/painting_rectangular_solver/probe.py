#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Recompute the six-piece pixel candidate from a sealed, portable input fixture."""
import argparse
import hashlib
import json
from pathlib import Path
import sys
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from painting_rectangular_solver import solve_observed

EXPECTED_MANIFEST = '3982bdad81ae83e732746ed58159774c451f1d212ab323a38b19221766598414'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def probe(base):
    manifest_path = base/'manifest.json'
    if sha(manifest_path) != EXPECTED_MANIFEST:
        raise ValueError('Fixture manifest identity mismatch')
    manifest = json.loads(manifest_path.read_text())
    for name, digest in manifest['files'].items():
        if Path(name).name != name or sha(base/name) != digest:
            raise ValueError('Fixture physical byte identity mismatch: '+name)
    geometry = json.loads((base/'public-geometry.json').read_text())
    images = {source: Image.open(base/name).convert('RGBA')
              for source, name in manifest['images'].items()}
    result = solve_observed(images, geometry['board'], geometry['calibration'],
                            **manifest['parameters'])
    return {'scope': 'Recomputed pixels; no Qt execution or native completion claimed',
            'manifest_sha256': EXPECTED_MANIFEST,
            'source_sha256': {name: sha(Path(__file__).with_name(name))
                              for name in ['solver.py', 'probe.py', '__init__.py']},
            'parameters': manifest['parameters'], 'result': result}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--fixture', type=Path,
                        default=Path(__file__).with_name('fixtures')/'bazille')
    args = parser.parse_args()
    try:
        print(json.dumps(probe(args.fixture), indent=2))
        return 0
    except (ValueError, KeyError, OSError) as error:
        print(str(error), file=sys.stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
