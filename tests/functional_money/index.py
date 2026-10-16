#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Index finished native money receipts; never treat running logs as passes."""
import hashlib
import json
from pathlib import Path
from run import LEVELS

ROOT=Path(__file__).resolve().parents[2]
BASE=ROOT/'.scratch/pt-pt/functional-money'


def main():
    cases={}
    for activity in LEVELS:
        for suffix,mode in [('auto',1),('ok',2)]:
            cases[activity+'-'+suffix]={'phase':'final','kind':'campaign','mode':mode}
        cases[activity+'-controls']={'phase':'final','kind':'controls'}
    for prefix,red,green in [('automatic-keyboard','original','keyboard-fixed'),('manual-feedback','keyboard-fixed','final'),('reachability','keyboard-fixed','final')]:
        cases[prefix+'-red']={'phase':red,'kind':'red'}
        cases[prefix+'-green']={'phase':green,'kind':'green'}
    for name,metadata in cases.items():
        result=json.loads((BASE/name/'result.json').read_text())
        assert result['exit_code']==0 and not result['timeout']
        assert result['passed']==(metadata['kind']!='red'),name
        assert hashlib.sha256((BASE/name/'case.qml').read_bytes()).hexdigest()==result['case_sha256']
    files={}
    for path in sorted(BASE.rglob('*')):
        relative=path.relative_to(BASE)
        if any(part.startswith('.') for part in relative.parts) or relative.as_posix()=='index.json':continue
        assert not path.is_symlink()
        if path.is_file():files[relative.as_posix()]=hashlib.sha256(path.read_bytes()).hexdigest()
    (BASE/'index.json').write_text(json.dumps({'cases':cases,'files':files},indent=2)+'\n')

if __name__=='__main__':main()
