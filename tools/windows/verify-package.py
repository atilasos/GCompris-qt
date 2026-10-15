#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Check a Windows candidate tree; startup listing is separate from game acceptance."""
import argparse
import hashlib
import json
from pathlib import Path


def check(stage, activities, entries, listed=None):
    required = ['bin/GCompris.exe', 'bin/Qt6Core.dll', 'bin/Qt6Gui.dll',
                'bin/Qt6Qml.dll', 'bin/vcruntime140.dll', 'bin/msvcp140.dll', 'bin/Qt6Quick.dll', 'bin/Qt6Multimedia.dll',
                'bin/platforms/qwindows.dll', 'bin/platforms/qoffscreen.dll',
                'bin/multimedia/ffmpegmediaplugin.dll',
                'bin/imageformats/qwebp.dll', 'bin/tls/qopensslbackend.dll',
                'bin/qml/QtQuick/qmldir', 'bin/qml/QtGraphs/qmldir',
                'lib/qml/Box2D.2.0/qmlbox2d.dll', 'lib/qml/Box2D.2.0/qmldir',
                'share/GCompris/translations/gcompris_qt_pt.qm',
                'share/GCompris/rcc/core.rcc']
    required.extend(f'share/GCompris/rcc/{name}.rcc' for name in activities)
    missing = [path for path in required if not (stage / path).is_file()]
    for pattern in ['bin/avcodec-*.dll', 'bin/avformat-*.dll', 'bin/avutil-*.dll',
                    'bin/libcrypto-3*.dll', 'bin/libssl-3*.dll']:
        if not list(stage.glob(pattern)):
            missing.append(pattern)
    corrupt = []
    for entry in entries:
        relative = 'share/GCompris/rcc/data3/' + entry['path']
        path = stage / relative
        if not path.is_file():
            missing.append(relative)
        elif path.stat().st_size != entry['bytes'] or hashlib.sha256(path.read_bytes()).hexdigest() != entry['sha256']:
            corrupt.append(relative)
    listed_set = None if listed is None else set(listed)
    absent = [] if listed_set is None else sorted(set(activities) - listed_set)
    unexpected = [] if listed_set is None else sorted(listed_set - set(activities))
    return {'passed': not (missing or corrupt or absent or unexpected),
            'scope': 'Packaged runtime files, locked assets, and optional native activity list; no gameplay/teacher acceptance',
            'expected_activities': len(activities), 'native_list_checked': listed is not None,
            'missing': missing, 'corrupt': corrupt, 'unlisted_activities': absent,
            'unexpected_activities': unexpected}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('stage', type=Path)
    parser.add_argument('--activities', type=Path, required=True)
    parser.add_argument('--listed', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    activities = [line.strip() for line in args.activities.read_text().splitlines()
                  if line.strip() and not line.lstrip().startswith('#')]
    listed = None if args.listed is None else args.listed.read_text(encoding='utf-8-sig').split()
    entries = json.loads(Path(__file__).with_name('assets-lock.json').read_text())['files']
    result = check(args.stage, activities, entries, listed)
    args.output.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result, indent=2))
    raise SystemExit(0 if result['passed'] else 1)
