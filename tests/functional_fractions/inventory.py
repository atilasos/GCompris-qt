#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Read all original fraction datasets using the real Qt PT translation converter."""
import json
from pathlib import Path
import subprocess
import tempfile
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]


def collect(root=ROOT):
    with tempfile.TemporaryDirectory() as directory:
        ts = Path(directory) / 'pt.ts'
        subprocess.run(['/usr/lib/qt6/bin/lconvert','-i',str(root/'poqm/pt/gcompris_qt.po'),'-o',str(ts),'-target-language','pt_PT'],check=True)
        translations = {m.findtext('source'):m.findtext('translation') for c in ET.parse(ts).findall('context')
                        if c.findtext('name') == 'Data' for m in c.findall('message')}
    files = [{'path':str(path.relative_to(root)), 'text':path.read_text()}
             for activity in ('fractions_create','fractions_find')
             for path in sorted((root/'src/activities'/activity/'resource').glob('*/Data.qml'),key=lambda p:int(p.parent.name))]
    result = subprocess.run(['node',str(root/'tests/functional_fractions/data.js')],
                            input=json.dumps({'translations':translations,'files':files}),text=True,capture_output=True,check=True)
    return json.loads(result.stdout)


if __name__ == '__main__':
    datasets=collect()
    print(json.dumps(datasets,ensure_ascii=False,indent=2))
