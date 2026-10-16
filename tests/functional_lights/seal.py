#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Seal only selected, completed proof artifacts. Never rewrite an existing seal."""
import hashlib,json
from pathlib import Path
from audit import HERE,CASES,selected_paths
for name,(_,_,positive) in CASES.items():
 folder=HERE/name;receipt=json.loads((folder/'result.json').read_text());status=json.loads((folder/'launcher-status.json').read_text());tool=json.loads((folder/'tool-status.json').read_text());expected=0 if positive else 1
 assert receipt['passed'] is positive and receipt['exit_code']==0 and not receipt['timeout'] and status['exit_code']==tool['exit_code']==expected
 assert tool['chunk_id']!='NEEDS_ACTUAL'
files={name:hashlib.sha256((HERE/name).read_bytes()).hexdigest() for name in sorted(selected_paths(HERE))}
with (HERE/'capture.json').open('x') as stream:stream.write(json.dumps({'format':1,'files':files},indent=2)+'\n')
digest=hashlib.sha256((HERE/'capture.json').read_bytes()).hexdigest();print(len(files),digest)
p=Path(__file__).with_name('audit.py');text=p.read_text();assert "CAPTURE_SHA='PENDING'" in text;p.write_text(text.replace("CAPTURE_SHA='PENDING'","CAPTURE_SHA='"+digest+"'"))
