#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Seal completed executions only after all three process results are observed."""
import hashlib
import json
from audit import CASES,EXTRA,HERE


if __name__=='__main__':
    names={str(path.relative_to(HERE)) for case in CASES for path in (HERE/case).rglob('*') if path.is_file()}|{row[0] for row in CASES.values()}|EXTRA
    for name,(_,_,positive) in CASES.items():
        directory=HERE/name;result=json.loads((directory/'result.json').read_text());status=json.loads((directory/'launcher-status.json').read_text());tool=json.loads((directory/'tool-status.json').read_text());outer=0 if positive else 1
        assert result['passed'] is positive and result['exit_code']==0 and status['exit_code']==tool['exit_code']==outer
    capture={'format':1,'files':{name:hashlib.sha256((HERE/name).read_bytes()).hexdigest() for name in sorted(names)}}
    with (HERE/'capture.json').open('x') as stream:stream.write(json.dumps(capture,indent=2)+'\n')
    print('Capture files',len(names),'SHA',hashlib.sha256((HERE/'capture.json').read_bytes()).hexdigest())
