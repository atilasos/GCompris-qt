#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Compile ordering RCC in a private staging copy, then seal a new snapshot."""
import argparse
from pathlib import Path
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]


def prepare(staging, output):
    if not staging.is_dir() or output.exists():
        raise ValueError('Use an existing private staging copy and a new snapshot output')
    with tempfile.TemporaryDirectory(prefix='ordering-qrc-', dir=staging.parent) as directory:
        for name in ('core', 'ordering_numbers', 'ordering_alphabets', 'ordering_sentences'):
            source = ROOT / 'src/core' if name == 'core' else ROOT / 'src/activities' / name
            prefix = '/gcompris/src/core' if name == 'core' else '/gcompris/src/activities/' + name
            qrc = ET.Element('RCC')
            resource = ET.SubElement(qrc, 'qresource', prefix=prefix)
            for path in sorted(source.rglob('*')):
                if path.is_file():
                    ET.SubElement(resource, 'file', alias=path.relative_to(source).as_posix()).text = str(path)
            qrc_file = Path(directory) / (name + '.qrc')
            ET.ElementTree(qrc).write(qrc_file, encoding='utf-8')
            subprocess.run(['/usr/lib/qt6/libexec/rcc', '--binary', str(qrc_file), '-o',
                            str(staging / 'share/gcompris-qt/rcc' / (name + '.rcc'))], check=True)
    subprocess.run([sys.executable, str(ROOT / 'tools/native_qml_resources.py'),
                    '--binary', str(staging / 'bin/gcompris-qt'), '--output', str(output)], check=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--base', type=Path, required=True,
                        help='Mutable PRIVATE staging copy, never a shared build or a running snapshot')
    parser.add_argument('--output', type=Path, required=True, help='New independent sealed snapshot')
    args = parser.parse_args()
    prepare(args.base, args.output)
