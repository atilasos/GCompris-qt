#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Compile current connected-drawing resources privately, then seal an independent snapshot."""
import argparse
from pathlib import Path
import subprocess
import sys
import xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser();p.add_argument('--base',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
for name in ['core','number_sequence','clickanddraw','drawletters','drawnumbers']:
 source=ROOT/'src/core' if name=='core' else ROOT/'src/activities'/name
 prefix='/gcompris/src/core' if name=='core' else '/gcompris/src/activities/'+name
 qrc=ET.Element('RCC');r=ET.SubElement(qrc,'qresource',prefix=prefix)
 for f in sorted(source.rglob('*')):
  if f.is_file():ET.SubElement(r,'file',alias=f.relative_to(source).as_posix()).text=str(f)
 qrcfile=a.base/(name+'.qrc');ET.ElementTree(qrc).write(qrcfile,encoding='utf-8')
 subprocess.run(['/usr/lib/qt6/libexec/rcc','--binary',str(qrcfile),'-o',str(a.base/'share/gcompris-qt/rcc'/(name+'.rcc'))],check=True)
subprocess.run([sys.executable,str(ROOT/'tools/native_qml_resources.py'),'--binary',str(a.base/'bin/gcompris-qt'),'--output',str(a.output)],check=True)
