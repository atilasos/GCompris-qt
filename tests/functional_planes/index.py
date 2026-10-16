#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Index only finished native runs and their SHA-bound post-wait statuses."""
import argparse
import sys
import hashlib
import json
from pathlib import Path
from audit import ORIGINAL,FIXED

ROOT=Path(__file__).resolve().parents[2]
BASE=ROOT/'.scratch/pt-pt/functional-planes'


def index(base):
    cases={
        'interception-tracer':{'kind':'tracer','revision':ORIGINAL,'snapshot':'origin'},
        'parity-tutorial-focus':{'kind':'focus','revision':ORIGINAL,'snapshot':'canonical'},
        'number-complete':{'kind':'campaign','revision':ORIGINAL,'snapshot':'canonical'},
        'numbers-odd-even-complete':{'kind':'campaign','revision':ORIGINAL,'snapshot':'canonical'},
        'alphabet-complete':{'kind':'campaign','revision':FIXED,'snapshot':'canonical'},
        'alphabet-modern-red':{'kind':'red','revision':ORIGINAL,'snapshot':'canonical'},
        'alphabet-order-red':{'kind':'diagnostic','revision':ORIGINAL,'snapshot':'canonical'},
        'alphabet-controller-miss':{'kind':'diagnostic','revision':FIXED,'snapshot':'canonical'},
        'number-controller-miss':{'kind':'diagnostic','revision':ORIGINAL,'snapshot':'canonical'},
        'parity-controller-miss':{'kind':'diagnostic','revision':ORIGINAL,'snapshot':'canonical'},
    }
    for name in ['number-controls','numbers-odd-even-controls','alphabet-sequence-controls']:cases[name]={'kind':'controls','revision':ORIGINAL,'snapshot':'canonical'}
    for name,entry in cases.items():
        result=base/name/'result.json';status=json.loads((base/name/'launcher-status.json').read_text());native=json.loads(result.read_text())
        expected=0 if entry['kind'] in ['tracer','campaign','controls','focus'] else 1
        assert status['exit_code']==expected and native['passed']==(expected==0),'Unsuccessful launcher: '+name
        assert status['native_receipt_sha256']==hashlib.sha256(result.read_bytes()).hexdigest(),name
        assert status['case_sha256']==native['case_sha256']==hashlib.sha256((base/name/'case.qml').read_bytes()).hexdigest(),name
        assert native['exit_code']==0 and not native['timeout']
    files={}
    for path in sorted(base.rglob('*')):
        relative=path.relative_to(base)
        if any(part.startswith('.') for part in relative.parts) or relative.as_posix()=='index.json':continue
        assert not path.is_symlink()
        if path.is_file():files[relative.as_posix()]=hashlib.sha256(path.read_bytes()).hexdigest()
    (base/'index.json').write_text(json.dumps({'cases':cases,'files':files},indent=2)+'\n')

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--evidence',type=Path,default=BASE);args=parser.parse_args()
    try:index(args.evidence)
    except (AssertionError,OSError,ValueError,KeyError) as error:
        print('Cannot index flying runs: '+str(error),file=sys.stderr);return 1
    return 0


if __name__=='__main__':raise SystemExit(main())
