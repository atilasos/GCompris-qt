#!/usr/bin/env python3
"""Read-only branch/worktree integration audit. Refresh remotes before running."""
import json
import subprocess
from datetime import datetime, timezone


def git(*args):
    return subprocess.check_output(['git', *args], text=True).strip()


def contains(base, tip):
    result = subprocess.run(['git', 'merge-base', '--is-ancestor', tip, base])
    if result.returncode not in (0, 1):
        raise RuntimeError(f'Cannot compare {base} and {tip}')
    return result.returncode == 0


base = 'master'
branches = git('for-each-ref', '--format=%(refname:short)', 'refs/heads').splitlines()
worktrees = []
for block in git('worktree', 'list', '--porcelain').split('\n\n'):
    fields = dict(line.split(' ', 1) for line in block.splitlines() if ' ' in line)
    path = fields['worktree']
    worktrees.append({
        'path': path, 'head': fields['HEAD'], 'branch': fields.get('branch'),
        'integrated': contains(base, fields['HEAD']),
        'status': subprocess.check_output(['git', '-C', path, 'status', '--porcelain'], text=True).splitlines(),
    })
print(json.dumps({
    'timestamp': datetime.now(timezone.utc).isoformat(),
    'base': base, 'head': git('rev-parse', base),
    'origin': git('rev-parse', 'origin/master'),
    'upstream': git('rev-parse', 'upstream/master'),
    'upstream_integrated': contains(base, 'upstream/master'),
    'origin_integrated': contains(base, 'origin/master'),
    'branches': [{'name': b, 'head': git('rev-parse', b), 'integrated': contains(base, b)} for b in branches],
    'worktrees': worktrees,
}, indent=2))
