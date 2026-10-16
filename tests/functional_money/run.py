#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run the native visible-price money contract against immutable Git inputs."""
import argparse
import json
from pathlib import Path
import shutil
import subprocess
import sys
from oracle import DENOMINATIONS
from phase import freeze

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
LEVELS = {'money': 23, 'money_cents': 23, 'money_back': 29, 'money_back_cents': 28}

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--revision', required=True)
    parser.add_argument('--snapshot', type=Path, required=True)
    parser.add_argument('--activity', choices=LEVELS, required=True)
    parser.add_argument('--mode', type=int, choices=[1,2], default=1)
    parser.add_argument('--controls', action='store_true')
    parser.add_argument('--output', type=Path, required=True)
    args=parser.parse_args()
    source=freeze(args.revision)
    output=args.output.resolve()
    if output.exists(): parser.error('output already exists')
    template=(HERE/('controls.qml' if args.controls else 'gameplay.qml')).read_text()
    replacements={'__DENOMINATIONS__':json.dumps(DENOMINATIONS),'__VISIBLE__':(HERE/'visible.fragment').read_text(),'__UI__':(HERE/'ui.fragment').read_text(),'__MODE__':str(args.mode),'__LEVELS__':str(LEVELS[args.activity]),'__CHANGE__':json.dumps('_back' in args.activity)}
    titles={'money':'Dinheiro','money_cents':'Dinheiro com cêntimos','money_back':'Dar o troco ao Tux','money_back_cents':'Dar o troco ao Tux, incluindo os cêntimos'}
    replacements.update({'__TITLE__':json.dumps(titles[args.activity]),'__TOTAL__':str(LEVELS[args.activity]),'__REDUCED__':str(LEVELS[args.activity]-7),'__ESCAPE__':json.dumps('cents' in args.activity)})
    for key,value in replacements.items(): template=template.replace(key,value)
    case=ROOT/'build/functional-money/cases'/(f'{args.activity}-'+('controls.qml' if args.controls else str(args.mode)+'.qml'))
    case.parent.mkdir(parents=True,exist_ok=True)
    case.write_text(template)
    command=[sys.executable,str(source/'tools/run-native-qml-case.py'),'--source-root',str(source),'--resource-snapshot',str(args.snapshot.resolve()),'--activity',args.activity,'--qml-file',str(source/'src/activities/money/MoneyCore.qml'),'--case',str(case),'--output',str(output),'--result-marker','NATIVE_MONEY_RESULT','--offline','--timeout','900']
    completed=subprocess.run(command)
    if output.exists():
        shutil.copyfile(case,output/'case.qml')
        (output/'invocation.json').write_text(json.dumps({'revision':source.name,'activity':args.activity,'mode':args.mode,'scope':'one natural board per runtime level; alternate mouse and keyboard; both validation modes'},indent=2)+'\n')
    return completed.returncode

if __name__=='__main__': sys.exit(main())
