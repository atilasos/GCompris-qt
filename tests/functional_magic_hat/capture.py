#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Capture the bytes Qt exposes from the private magic hat snapshot."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from native_qml_resources import verify_snapshot


def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    if not __debug__:raise SystemExit('Magic hat validation requires assertions; Python -O is rejected')
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--snapshot',type=Path,required=True);parser.add_argument('--source-root',type=Path,required=True);parser.add_argument('--output',type=Path,required=True);args=parser.parse_args()
    snapshot=args.snapshot.resolve();source=args.source_root.resolve();args.output.mkdir(parents=True,exist_ok=True);manifest=verify_snapshot(snapshot)
    inputs=json.loads((source/'source-manifest.json').read_text());revision=inputs['revision']
    def blob(path):return subprocess.check_output(['git','-C',str(ROOT),'show',revision+':'+path])
    assert all(sha(source/path)==digest for path,digest in inputs['files'].items())
    cpp=ROOT/'tools/pt-pt-audio/rcc_inventory.cpp';assert cpp.read_bytes()==blob('tools/pt-pt-audio/rcc_inventory.cpp')
    inspector=ROOT/'build/magic-rcc-inventory';flags=subprocess.check_output(['pkg-config','--cflags','--libs','Qt6Core'],text=True).split()
    subprocess.run(['g++','-std=c++17','-fPIC',str(cpp),'-o',str(inspector),*flags],check=True)
    def inspect(path,export=None):return json.loads(subprocess.check_output([str(inspector),str(path),*([str(export)] if export else [])]))
    canonical={}
    for name in ['magic-hat-minus','magic-hat-plus','core']:
        path=snapshot/'share/gcompris-qt/rcc'/(name+'.rcc');rows=inspect(path);prefix='src/core' if name=='core' else 'src/activities/'+name
        expected={path for path in inputs['files'] if path.startswith(prefix+'/')};assert {row['path'] for row in rows}=={':/gcompris/'+path for path in expected}
        for row in rows:assert row['sha256']==hashlib.sha256(blob(row['path'].removeprefix(':/gcompris/'))).hexdigest()
        canonical[name]={'rcc_sha256':sha(path),'files':rows}
    audio=[]
    for name in ['smudge','crash','bonus']:
        relative='src/core/resource/sounds/'+name+'.wav';path=source/relative
        decoded=subprocess.run(['gst-launch-1.0','-q','filesrc','location='+str(path),'!','wavparse','!','audioconvert','!','fakesink'],capture_output=True,text=True,timeout=20);assert decoded.returncode==0,decoded.stderr
        audio.append({'path':relative,'sha256':sha(path),'decode_exit_code':decoded.returncode,'stderr':decoded.stderr})
    report={'revision':revision,'inspector_source_sha256':sha(cpp),'canonical':canonical,'audio':audio,'audio_scope':'Software WAV decode to fakesink only. Native Qt muted, no listening or pronunciation approval.'}
    for filename,content in [('source-manifest.json',(source/'source-manifest.json').read_bytes()),('snapshot-manifest.json',(snapshot/'manifest.json').read_bytes()),('origin-snapshot-manifest.json',(ROOT/'build/magic-origin/manifest.json').read_bytes())]:(args.output/filename).write_bytes(content)
    (args.output/'resources.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({'source_files':len(inputs['files']),'snapshot_files':len(manifest['files']),'audio_decoded':len(audio)}))

if __name__=='__main__':main()
