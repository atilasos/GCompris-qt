#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Seal completed native artifacts, after every observed process has ended."""
import hashlib
import json
from pathlib import Path
from audit import CASES,HERE


if __name__=='__main__':
    files={name for case in CASES for name in (str(path.relative_to(HERE)) for path in (HERE/case).rglob('*') if path.is_file())}|set(CASES.values())|{'source-tree.zip','source-manifest.json','resource-snapshot.json','data.json','wav-software-decode.json','execution-notes.json'}
    for case in CASES:
        for name in ['result.json','launcher-status.json','tool-status.json']:assert (HERE/case/name).is_file()
        assert json.loads((HERE/case/'result.json').read_text())['passed'] is True
        assert json.loads((HERE/case/'launcher-status.json').read_text())['exit_code']==0
        assert json.loads((HERE/case/'tool-status.json').read_text())['exit_code']==0
    manifest={'format':1,'source':'fec529d1a','files':{name:hashlib.sha256((HERE/name).read_bytes()).hexdigest() for name in sorted(files)}}
    with (HERE/'capture.json').open('x') as stream:stream.write(json.dumps(manifest,indent=2)+'\n')
    print('Capture',len(files),'files SHA256',hashlib.sha256((HERE/'capture.json').read_bytes()).hexdigest())
