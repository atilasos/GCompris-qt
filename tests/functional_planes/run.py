#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Operate native flying sequences using immutable sources and post-wait status."""
import argparse
import json
from pathlib import Path
import shutil
import subprocess
import sys
from oracle import sequence

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source-root',type=Path,required=True)
    parser.add_argument('--snapshot',type=Path,required=True)
    parser.add_argument('--activity',choices=['planegame','numbers-odd-even','alphabet-sequence'],required=True)
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--controls',action='store_true')
    args=parser.parse_args()
    source=args.source_root.resolve();output=args.output.resolve()
    if output.exists():parser.error('Use a new output directory')
    text=(HERE/('controls.qml' if args.controls else 'gameplay.qml')).read_text().replace('__LEVELS__',json.dumps([sequence(args.activity,level) for level in range(1,5)]))
    for marker,filename in [('__MOVEMENT__','movement.fragment'),('__TUTORIAL__','tutorial.fragment')]:text=text.replace(marker,(HERE/filename).read_text())
    titles={'planegame':'Ordem numérica','numbers-odd-even':'Números pares e ímpares','alphabet-sequence':'Sequência alfabética'}
    text=text.replace('__TITLE__',json.dumps(titles[args.activity])).replace('__FIRST__',json.dumps(sequence(args.activity,1)[0])).replace('__ESCAPE__',json.dumps(args.activity=='alphabet-sequence'))
    case=ROOT/'build/planes-cases'/(args.activity+('-controls' if args.controls else '')+'.qml');case.parent.mkdir(parents=True,exist_ok=True);case.write_text(text)
    command=[sys.executable,str(source/'tools/run-native-qml-supervised.py'),'--source-root',str(source),'--activity',args.activity,'--qml-file',str(source/'src/activities/planegame/Planegame.qml'),'--resource-snapshot',str(args.snapshot.resolve()),'--case',str(case),'--output',str(output),'--result-marker','NATIVE_PLANE_RESULT','--offline','--timeout','2400']
    completed=subprocess.run(command)
    if output.exists():shutil.copyfile(case,output/'case.qml')
    return completed.returncode

if __name__=='__main__':raise SystemExit(main())
