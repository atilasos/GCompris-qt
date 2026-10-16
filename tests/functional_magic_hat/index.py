#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Index only completed magic hat cases with verified post-wait status."""
import argparse
import hashlib
import json
from pathlib import Path
import sys

if not __debug__:raise SystemExit('Magic hat validation requires assertions; Python -O is rejected')
ROOT=Path(__file__).resolve().parents[2]
BASE=ROOT/'.scratch/pt-pt/functional-magic-hat'
CASES={'minus-tracer':'tracer','minus-complete':'campaign','plus-complete':'campaign','minus-controls':'controls','plus-controls':'controls','help-vocabulary-diagnostic':'diagnostic'}


def build(base):
    for name,kind in CASES.items():
        raw=(base/name/'result.json').read_bytes();result=json.loads(raw);status=json.loads((base/name/'launcher-status.json').read_text());expected=1 if kind=='diagnostic' else 0
        assert status['exit_code']==expected and result['passed']==(expected==0),'Unsuccessful launcher: '+name
        assert status['native_receipt_sha256']==hashlib.sha256(raw).hexdigest()
        assert status['case_sha256']==result['case_sha256']==hashlib.sha256((base/name/'case.qml').read_bytes()).hexdigest()
        if kind!='tracer':
            outer=json.loads((base/name/'supervisor-exit.json').read_text());assert outer['exit_code']==expected and outer['native_receipt_sha256']==hashlib.sha256(raw).hexdigest(),'Unsuccessful supervisor: '+name
    files={}
    for path in sorted(base.rglob('*')):
        relative=path.relative_to(base)
        if any(part.startswith('.') for part in relative.parts) or relative.as_posix()=='index.json':continue
        assert not path.is_symlink()
        if path.is_file():files[relative.as_posix()]=hashlib.sha256(path.read_bytes()).hexdigest()
    (base/'index.json').write_text(json.dumps({'cases':{name:{'kind':kind} for name,kind in CASES.items()},'files':files},indent=2)+'\n')


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--evidence',type=Path,default=BASE);args=parser.parse_args()
    try:build(args.evidence)
    except (AssertionError,OSError,ValueError,KeyError) as error:print('Cannot index magic hat cases: '+str(error),file=sys.stderr);return 1
    return 0

if __name__=='__main__':raise SystemExit(main())
