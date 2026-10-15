#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Compile the Portugal catalog with Qt Linguist, without a gettext dependency."""
import argparse
from pathlib import Path
import os
import subprocess


def compile_catalog(qt_root, catalog, ts, qm):
    suffix = '.exe' if os.name == 'nt' else ''
    tools = Path(qt_root) / 'bin'
    subprocess.run([str(tools / ('lconvert' + suffix)), '-target-language', 'pt_PT', '-if', 'po', '-of', 'ts',
                    '-i', str(catalog), '-o', str(ts)], check=True)
    subprocess.run([str(tools / ('lrelease' + suffix)), '-removeidentical', '-nounfinished',
                    str(ts), '-qm', str(qm)], check=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ['qt_root', 'catalog', 'ts', 'qm']:
        parser.add_argument(name, type=Path)
    args = parser.parse_args()
    compile_catalog(args.qt_root, args.catalog, args.ts, args.qm)
