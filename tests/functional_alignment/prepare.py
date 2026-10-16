#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Build frozen alignment games activity RCCs in a private tree and seal every dependency."""
import argparse
import json
from pathlib import Path
import shutil
import subprocess
import sys
import uuid
import xml.etree.ElementTree as ET
from phase import ACTIVITIES, verify_source

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
from native_qml_resources import create_snapshot, verify_snapshot


def main():
    if not __debug__:raise SystemExit('Alignment games validation requires assertions; Python -O is rejected')
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--origin-snapshot', type=Path, required=True)
    parser.add_argument('--source-root', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    args.source_root = args.source_root.resolve()
    verify_source(args.source_root)
    for activity in ACTIVITIES:
        if not (args.source_root/'src/activities'/activity/'CMakeLists.txt').is_file():
            raise ValueError('Missing frozen activity source: '+activity)
    origin = args.origin_snapshot.resolve()
    verify_snapshot(origin)
    base = ROOT / 'build/alignment-base' / uuid.uuid4().hex
    binary = base / 'bin/gcompris-qt'
    binary.parent.mkdir(parents=True)
    shutil.copyfile(origin / 'bin/gcompris-qt', binary)
    binary.chmod(0o755)
    share = base / 'share/gcompris-qt'
    share.mkdir(parents=True)
    for entry in (origin / 'share/gcompris-qt').iterdir():
        if entry.name == 'rcc':
            (share / 'rcc').mkdir()
            for resource in entry.iterdir():
                (share / 'rcc' / resource.name).symlink_to(resource)
        else:
            (share / entry.name).symlink_to(entry)
    if (origin / 'lib/qml').is_dir():
        (base / 'lib').mkdir()
        (base / 'lib/qml').symlink_to(origin / 'lib/qml')
    for name in [*ACTIVITIES, 'core']:
        source = args.source_root / 'src/core' if name == 'core' else args.source_root / 'src/activities' / name
        prefix = '/gcompris/src/core' if name == 'core' else '/gcompris/src/activities/' + name
        tree = ET.Element('RCC')
        resources = ET.SubElement(tree, 'qresource', prefix=prefix)
        for path in sorted(source.rglob('*')):
            if path.is_file():
                ET.SubElement(resources, 'file', alias=path.relative_to(source).as_posix()).text = str(path)
        qrc = base / (name + '.qrc')
        ET.ElementTree(tree).write(qrc, encoding='utf-8')
        output = share / 'rcc' / (name + '.rcc')
        output.unlink()
        subprocess.run(['/usr/lib/qt6/libexec/rcc', '--binary', str(qrc), '-o', str(output)], check=True)
    create_snapshot(binary, args.output.resolve())
    print(json.dumps({'snapshot': str(args.output.resolve()), 'files': len(verify_snapshot(args.output.resolve())['files'])}))


if __name__ == '__main__':
    main()
