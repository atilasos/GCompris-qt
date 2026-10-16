#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Rebuild only the three vertical RCCs and seal a private runtime snapshot."""
import argparse,json,shutil,subprocess,sys,uuid
from pathlib import Path
import xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from native_qml_resources import create_snapshot,verify_snapshot
from run import ACTIVITIES

def main():
 p=argparse.ArgumentParser(description=__doc__)
 p.add_argument('--origin-snapshot',type=Path,required=True)
 p.add_argument('--source-root',type=Path,required=True);p.add_argument('--output',type=Path,required=True)
 a=p.parse_args()
 if a.output.exists():p.error('Snapshot destination must be new')
 origin=a.origin_snapshot.resolve();verify_snapshot(origin)
 stage=ROOT/'build/functional-vertical/stage'/uuid.uuid4().hex
 (stage/'bin').mkdir(parents=True);shutil.copyfile(origin/'bin/gcompris-qt',stage/'bin/gcompris-qt');(stage/'bin/gcompris-qt').chmod(0o755)
 for directory in ['share/gcompris-qt','lib/qml']:
  src=origin/directory;dst=stage/directory;dst.mkdir(parents=True)
  for item in src.iterdir():
   if item.name!='rcc':(dst/item.name).symlink_to(item,target_is_directory=item.is_dir())
   else:
    (dst/'rcc').mkdir()
    for resource in item.iterdir():(dst/'rcc'/resource.name).symlink_to(resource,target_is_directory=resource.is_dir())
 for activity in ACTIVITIES:
  source=(a.source_root/'src/activities'/activity).resolve()
  tree=ET.Element('RCC');resource=ET.SubElement(tree,'qresource',prefix='/gcompris/src/activities/'+activity)
  for file in sorted(source.rglob('*')):
   if file.is_file() and file.name!='CMakeLists.txt':ET.SubElement(resource,'file',alias=file.relative_to(source).as_posix()).text=str(file)
  qrc=stage/(activity+'.qrc');ET.ElementTree(tree).write(qrc,encoding='utf-8')
  output=stage/'share/gcompris-qt/rcc'/(activity+'.rcc');output.unlink()
  subprocess.run(['/usr/lib/qt6/libexec/rcc','--binary',str(qrc),'-o',str(output)],check=True)
 manifest=create_snapshot(stage/'bin/gcompris-qt',a.output.resolve())
 print(json.dumps({'files':len(manifest['files']),'output':str(a.output.resolve())}))
if __name__=='__main__':main()
