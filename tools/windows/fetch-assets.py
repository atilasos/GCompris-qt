#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Download the exact reviewed resource set; reject a changed CDN object."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import urllib.request


def fetch(entries, destination):
    destination = Path(destination).resolve()
    for entry in entries:
        path = destination / entry['path']
        if not path.resolve().is_relative_to(destination):
            raise ValueError('Resource path escapes its destination')
        path.parent.mkdir(parents=True, exist_ok=True)
        temporary = path.with_suffix(path.suffix + '.partial')
        try:
            with urllib.request.urlopen(entry['url'], timeout=120) as source, temporary.open('wb') as output:
                shutil.copyfileobj(source, output)
            if temporary.stat().st_size != entry['bytes'] or hashlib.sha256(temporary.read_bytes()).hexdigest() != entry['sha256']:
                raise ValueError(f"Resource checksum mismatch: {entry['path']}")
            temporary.replace(path)
            print(entry['path'], entry['sha256'])
        finally:
            temporary.unlink(missing_ok=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('destination', type=Path)
    args = parser.parse_args()
    lock = json.loads(Path(__file__).with_name('assets-lock.json').read_text())
    fetch(lock['files'], args.destination)
