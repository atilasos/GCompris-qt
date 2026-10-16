#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Compose standalone native cases, refusing to overwrite existing proofs."""
import argparse
from pathlib import Path

HERE=Path(__file__).resolve().parent


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--levels',type=int,choices=[1,7],default=7)
    parser.add_argument('--controls',action='store_true')
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    source=(HERE/'gameplay.qml').read_text()
    if args.controls:source=source.split('    function test_complete()')[0]+(HERE/'controls.fragment').read_text()
    else:
        marker='property int targetLevels: 1';assert source.count(marker)==1
        source=source.replace(marker,'property int targetLevels: '+str(args.levels))
    with args.output.open('x') as stream:stream.write(source)
