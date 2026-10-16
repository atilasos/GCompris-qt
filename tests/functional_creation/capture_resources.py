#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Retain all fixed-image providers from the sealed snapshot, with real exports."""
import argparse,hashlib,json,shutil,subprocess,sys
from pathlib import Path
from inventory import inventory
from rcc_export import compile_exporter,export_resources
from phase import verify_source
if not __debug__:raise SystemExit('Creation capture requires assertions; Python -O rejected')
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from native_qml_resources import verify_snapshot

def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 parser=argparse.ArgumentParser();parser.add_argument('--source',type=Path,required=True);parser.add_argument('--snapshot',type=Path,required=True);parser.add_argument('--output',type=Path,required=True);args=parser.parse_args()
 if args.output.is_symlink() or args.output.exists():parser.error('New output required')
 source=args.source.resolve();snapshot=args.snapshot.resolve();output=args.output.resolve()
 frozen=verify_source(source);manifest=verify_snapshot(snapshot);items=inventory(source);output.mkdir(parents=True);(output/'rcc').mkdir();cpp=source/'tools/pt-pt-audio/rcc_inventory.cpp';binary=output/'inspector';compile_exporter(cpp,binary);providers={};exported={}
 for name in items['providers']:
  path=snapshot/'share/gcompris-qt/rcc'/(name+'.rcc');destination=output/'rcc'/path.name;shutil.copyfile(path,destination);assert sha(destination)==manifest['files']['share/gcompris-qt/rcc/'+name+'.rcc'];rows=export_resources(binary,destination,output/'extracted'/name);providers[name]={'rcc_sha256':sha(destination),'files':rows}
  for row in rows:
   actual=output/'extracted'/name/row['path'].removeprefix(':/');assert actual.stat().st_size==row['bytes'] and sha(actual)==row['sha256'];exported['qrc:'+row['path'][1:]]=actual
  print('CAPTURE_PROVIDER',name,len(rows),flush=True)
 git_assets={}
 for url in items['assets']:
  raw=exported[url].read_bytes();relative=url.removeprefix('qrc:/gcompris/');historical=subprocess.check_output(['git','-C',str(ROOT),'show',frozen['revision']+':'+relative]);assert raw==historical,'Image bytes differ from pinned Git source: '+url;git_assets[relative]=hashlib.sha256(raw).hexdigest()
 binary.unlink();assert sha(cpp)==frozen['files']['tools/pt-pt-audio/rcc_inventory.cpp'];verify_snapshot(snapshot);(output/'physical.json').write_text(json.dumps({'revision':frozen['revision'],'snapshot_manifest_sha256':sha(snapshot/'manifest.json'),'inspector_source_sha256':sha(cpp),'providers':providers,'inventory':items,'git_assets':git_assets},indent=2)+'\n');print('PHYSICAL_IMAGE_ASSETS',len(git_assets))
if __name__=='__main__':main()
