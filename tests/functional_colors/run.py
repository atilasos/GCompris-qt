#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run real Qt colors cases against a private sealed snapshot."""
import argparse
import json
from pathlib import Path
import shutil
import subprocess
import sys
import uuid

ROOT = Path(__file__).resolve().parents[2]
NAMES = ['colors', 'advanced_colors']
MIXES = ['color_mix', 'color_mix_light']
TITLES = {'colors': 'Cores', 'advanced_colors': 'Cores avançadas', 'color_mix': 'Misturar as cores das tintas', 'color_mix_light': 'Mistura de cores da luz'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--activity', required=True, choices=NAMES+MIXES)
    parser.add_argument('--resource-snapshot', required=True, type=Path)
    parser.add_argument('--output', required=True, type=Path)
    parser.add_argument('--case', choices=['gameplay', 'controls', 'slider-ranges'], default='gameplay')
    parser.add_argument('--levels', type=int, default=0)
    parser.add_argument('--exit', choices=['home', 'escape'], default='home')
    args = parser.parse_args()
    total = {'colors': 3, 'advanced_colors': 20, 'color_mix': 6, 'color_mix_light': 6}[args.activity]
    if not 0 <= args.levels <= total:
        parser.error('Level count outside the original activity')
    if args.levels and args.case != 'gameplay':
        parser.error('--levels applies only to gameplay')
    if args.exit != 'home' and args.case != 'controls':
        parser.error('--exit applies only to controls')
    if args.case == 'slider-ranges' and args.activity not in MIXES:
        parser.error('Slider case requires a mixing activity')
    if args.output.exists() and any(args.output.iterdir()):
        parser.error('Use a new empty output directory')
    folder = ROOT / 'tests/functional_colors'
    template = args.case+'.qml' if args.case != 'gameplay' else ('names.qml' if args.activity in NAMES else 'mixing.qml')
    text = (folder/template).read_text()
    vocabulary = json.loads((folder/'names.json').read_text()).get(args.activity, {})
    for marker, value in {'__AUDIO__': (folder/'audio.fragment').read_text(), '__VOCABULARY__': json.dumps(vocabulary, ensure_ascii=False),
                          '__LEVEL_SIZES__': '[6,8,8]' if args.activity == 'colors' else json.dumps([8]*20),
                          '__FIRST_LEVEL__': '0', '__LEVEL_LIMIT__': str(args.levels), '__TITLE__': json.dumps(TITLES[args.activity], ensure_ascii=False),
                          '__TOTAL__': str(total), '__MIX__': str(args.activity in MIXES).lower(), '__ESCAPE__': str(args.exit == 'escape').lower()}.items():
        text = text.replace(marker, value)
    generated = ROOT/'build/functional-colors'/(uuid.uuid4().hex+'.qml')
    generated.parent.mkdir(parents=True, exist_ok=True)
    generated.write_text(text)
    qml = 'colors/FindIt.qml' if args.activity in NAMES else 'color_mix/ColorMix.qml'
    code = subprocess.call([sys.executable, str(ROOT/'tools/run-native-qml-case.py'), '--activity', args.activity,
                            '--resource-snapshot', str(args.resource_snapshot.resolve()), '--qml-file', str(ROOT/'src/activities'/qml),
                            '--case', str(generated), '--output', str(args.output.resolve()), '--offline', '--timeout', '1800', '--result-marker', 'NATIVE_COLORS_RESULT'])
    if args.output.is_dir():
        shutil.copyfile(generated, args.output/'case.qml')
    return code


if __name__ == '__main__':
    raise SystemExit(main())
