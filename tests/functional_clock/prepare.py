#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Compose an immutable native clock case for selected visible routes."""
import argparse
from pathlib import Path
HERE=Path(__file__).resolve().parent


if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--first',type=int,choices=range(1,11),default=1);parser.add_argument('--levels',type=int,choices=range(1,11),default=10);parser.add_argument('--twenty-four',action='store_true');parser.add_argument('--output',type=Path,required=True);args=parser.parse_args()
    assert args.first+args.levels-1<=10
    text=(HERE/'gameplay.qml').read_text().replace('property int firstLevel: 1','property int firstLevel: '+str(args.first)).replace('property int targetLevels: 1','property int targetLevels: '+str(args.levels))
    if args.twenty_four:text=text.replace('property bool twentyFour: false','property bool twentyFour: true')
    with args.output.open('x') as stream:stream.write(text)
