#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Capture original Qt resource identities and decode requested audio to fakesink."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys
from oracle import ALPHABET

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from native_qml_resources import verify_snapshot


def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--snapshot',type=Path,required=True)
    parser.add_argument('--source-root',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    snapshot=args.snapshot.resolve();source=args.source_root.resolve();args.output.mkdir(parents=True,exist_ok=True)
    manifest=verify_snapshot(snapshot);inputs=json.loads((source/'source-manifest.json').read_text());revision=inputs['revision']
    def blob(path):return subprocess.check_output(['git','-C',str(ROOT),'show',revision+':'+path])
    assert all(sha(source/path)==digest for path,digest in inputs['files'].items())
    cpp=ROOT/'tools/pt-pt-audio/rcc_inventory.cpp';assert cpp.read_bytes()==blob('tools/pt-pt-audio/rcc_inventory.cpp')
    inspector=ROOT/'build/planes-rcc-inventory'
    flags=subprocess.check_output(['pkg-config','--cflags','--libs','Qt6Core'],text=True).split()
    subprocess.run(['g++','-std=c++17','-fPIC',str(cpp),'-o',str(inspector),*flags],check=True)
    def inspect(path,export=None):return json.loads(subprocess.check_output([str(inspector),str(path),*([str(export)] if export else [])]))
    canonical={}
    for name in ['planegame','numbers-odd-even','alphabet-sequence','core']:
        path=snapshot/'share/gcompris-qt/rcc'/(name+'.rcc');rows=inspect(path)
        prefix='src/core' if name=='core' else 'src/activities/'+name
        expected={name for name in inputs['files'] if name.startswith(prefix+'/')}
        assert {row['path'] for row in rows}=={':/gcompris/'+name for name in expected}
        for row in rows:assert row['sha256']==hashlib.sha256(blob(row['path'].removeprefix(':/gcompris/'))).hexdigest()
        canonical[name]={'rcc_sha256':sha(path),'files':rows}
    external={}
    for activity,relative in [('algorithm','src/activities/algorithm/resource/desert_scene.svg'),('digital_electricity','src/activities/digital_electricity/resource/texture01.webp')]:
        path=snapshot/'share/gcompris-qt/rcc'/(activity+'.rcc');row=next(row for row in inspect(path) if row['path']==':/gcompris/'+relative)
        assert row['sha256']==hashlib.sha256(blob(relative)).hexdigest()
        external[activity]={'rcc_sha256':sha(path),'files':[row]}
    wanted={'U'+format(ord(char),'04X')+'.ogg' for char in ALPHABET+'0123456789'}|{str(number)+'.ogg' for number in range(10,21)}
    audio={};voice_rcc={}
    for path in sorted((snapshot/'share/gcompris-qt/rcc/data3/voices-ogg').glob('voices-pt-*.rcc')):
        export=ROOT/'build/planes-audio-export'/path.stem
        rows=inspect(path,export);voice_rcc[str(path.relative_to(snapshot))]=sha(path)
        for row in rows:
            relative=row['path'].removeprefix(':/gcompris/data/voices-ogg/pt/alphabet/')
            if relative in wanted:
                if relative in audio:
                    assert audio[relative]['sha256']==row['sha256'],'Selected voice differs between overlays'
                    audio[relative].setdefault('also_in_rcc',[]).append(str(path.relative_to(snapshot)))
                    continue
                actual=export/row['path'].removeprefix(':/')
                assert sha(actual)==row['sha256'] and row['ogg']
                run=subprocess.run(['gst-launch-1.0','-q','filesrc','location='+str(actual),'!','decodebin','!','audioconvert','!','fakesink'],capture_output=True,text=True,timeout=20)
                assert run.returncode==0,run.stderr
                audio[relative]={**row,'rcc':str(path.relative_to(snapshot)),'decode_exit_code':run.returncode,'decode_stderr':run.stderr}
    assert set(audio)==wanted and len(audio)==47
    crash=source/'src/core/resource/sounds/crash.wav'
    run=subprocess.run(['gst-launch-1.0','-q','filesrc','location='+str(crash),'!','wavparse','!','audioconvert','!','fakesink'],capture_output=True,text=True,timeout=20);assert run.returncode==0,run.stderr
    report={'revision':revision,'inspector_source_sha256':sha(cpp),'canonical':canonical,'external':external,'voice_rcc':voice_rcc,'voices':audio,'crash':{'path':'src/core/resource/sounds/crash.wav','sha256':sha(crash),'decode_exit_code':run.returncode},'audio_scope':'GStreamer decode to fakesink only. No physical listening, pronunciation or transfer of approval from the separate 32 additions.'}
    (args.output/'resource-identities.json').write_text(json.dumps(report,indent=2)+'\n')
    (args.output/'source-manifest.json').write_bytes((source/'source-manifest.json').read_bytes())
    (args.output/'snapshot-manifest.json').write_bytes((snapshot/'manifest.json').read_bytes())
    print(json.dumps({'source_files':len(inputs['files']),'snapshot_files':len(manifest['files']),'voices_decoded':len(audio),'external_assets':len(external)}))

if __name__=='__main__':main()
