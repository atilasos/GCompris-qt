#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run actual Qt counting cases with independent visible artwork receipts."""
import argparse
import json
from pathlib import Path
import shutil
import subprocess
import sys
import uuid
from inventory import inventory, ROOT


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--activity', choices=['enumerate', 'smallnumbers', 'smallnumbers2'], required=True)
    parser.add_argument('--resource-snapshot', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--case', choices=['gameplay', 'controls', 'selectors'], default='gameplay')
    parser.add_argument('--validation', choices=['automatic', 'ok'])
    parser.add_argument('--representation', choices=['all', 'dot', 'number', 'roman', 'image'])
    parser.add_argument('--levels', type=int, default=0, help='partial tracer only; omit for complete gameplay')
    parser.add_argument('--physical-only', action='store_true')
    args = parser.parse_args()
    if args.validation and args.activity != 'enumerate':
        parser.error('--validation applies only to enumerate')
    if args.representation and args.activity != 'smallnumbers2':
        parser.error('--representation applies only to smallnumbers2')
    maximum = 14 if args.activity == 'enumerate' else 9
    if not 0 <= args.levels <= maximum:
        parser.error('Requested level count is outside this activity')
    if args.case != 'gameplay' and (args.levels or args.physical_only or args.validation or args.representation):
        parser.error('Gameplay options require --case gameplay')
    if args.output.exists() and any(args.output.iterdir()):
        parser.error('Use a new empty output directory')
    folder = ROOT / 'tests/functional_counting'
    if args.case == 'gameplay':
        filename = 'enumerate.qml' if args.activity == 'enumerate' else 'falling.qml'
    elif args.case == 'controls':
        filename = 'enumerate-controls.qml' if args.activity == 'enumerate' else 'falling-controls.qml'
    else:
        filename = 'selectors.qml'
    text = (folder / filename).read_text()
    for marker, resource in [('__UI_HELPERS__', 'ui.fragment'), ('__COUNT_READERS__', 'rendered.fragment'), ('__FRUIT_DRAG__', 'fruit-drag.fragment')]:
        text = text.replace(marker, (folder / resource).read_text())
    data = inventory()
    dice = {'qrc:/gcompris/src/activities/smallnumbers/resource/' + name: value['visible_top_pips'] for name, value in data['dice'].items()}
    text = text.replace('__DICE_COUNTS__', json.dumps(dice)).replace('__VALIDATION_MODE__', '2' if args.validation == 'ok' else '1')
    text = text.replace('__LEVEL_LIMIT__', str(args.levels)).replace('__VISUAL_PREFERENCE__', 'false' if args.physical_only else 'true')
    text = text.replace('__REPRESENTATION__', json.dumps(args.representation or 'all'))
    generated = ROOT / 'build/functional-counting' / (uuid.uuid4().hex + '.qml')
    generated.parent.mkdir(parents=True, exist_ok=True)
    generated.write_text(text)
    qml = 'src/activities/enumerate/Enumerate.qml' if args.activity == 'enumerate' else 'src/activities/gletters/Gletters.qml'
    command = [sys.executable, str(ROOT / 'tools/run-native-qml-case.py'), '--resource-snapshot', str(args.resource_snapshot.resolve()),
               '--activity', args.activity, '--qml-file', qml, '--case', str(generated), '--output', str(args.output.resolve()),
               '--offline', '--timeout', '2400', '--result-marker', 'NATIVE_COUNTING_RESULT']
    code = subprocess.call(command)
    if args.output.is_dir():
        shutil.copyfile(generated, args.output / 'case.qml')
    if code or args.case != 'gameplay':
        return code
    audit = [sys.executable, str(folder / 'audit.py'), '--result', str(args.output / 'result.json'), '--case', str(args.output / 'case.qml'),
             '--output', str(args.output / 'oracle.json')]
    if args.levels or args.representation not in [None, 'all']:
        audit.append('--partial')
    return subprocess.call(audit)


if __name__ == '__main__':
    raise SystemExit(main())
