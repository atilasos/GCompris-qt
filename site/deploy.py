#!/usr/bin/env python3
# SPDX-FileCopyrightText: NONE
# SPDX-License-Identifier: CC0-1.0
"""Build and update only the existing gcompris-fork Pages project."""
import os
import subprocess
import sys
from pathlib import Path

root = Path(__file__).resolve().parents[1]
subprocess.run([sys.executable, str(root / 'site/build.py')], check=True)
env = dict(os.environ)
credentials = Path.home() / '.config/cloudflare-publish/credentials.env'
if credentials.exists():
    for line in credentials.read_text().splitlines():
        if line.strip() and not line.lstrip().startswith('#') and '=' in line:
            key, value = line.split('=', 1)
            env.setdefault(key.strip(), value.strip().strip('\"\''))
if not all(env.get(key) for key in ('CLOUDFLARE_API_TOKEN', 'CLOUDFLARE_ACCOUNT_ID')):
    raise SystemExit('Cloudflare credentials missing; see cloudflare-publish skill')
subprocess.run(['npx', '--yes', 'wrangler@4.151.1', 'pages', 'deploy', str(root / 'build/fork-site'),
                '--project-name', 'gcompris-fork', '--branch', 'main', '--commit-dirty=true'],
               cwd=root, env=env, check=True)
