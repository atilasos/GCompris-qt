#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Publish completed and independently verified learning evidence."""
import json
from pathlib import Path
import shutil
from audit import verify,sha,SOURCE,ARCHIVE,DEFAULT

if __name__=='__main__':
    root=DEFAULT;report=verify(root,locked=False)
    target=root/'auditor';assert not target.exists();target.mkdir()
    for name in ('audit.py','archive.py','inventory.py','audit_data.py','oracles.py'):
        shutil.copyfile(Path(__file__).parent/name,target/name)
    paths=[path for directory in ('archive','final','auditor','resources') for path in (root/directory).rglob('*') if path.is_file()]
    paths += [root/name for name in ('resources.json','resource-exporter.cpp','resource-decoder.py','hands-contact.png')]
    lock={'source_commit':SOURCE,'archive_sha256':ARCHIVE,'files':{path.relative_to(root).as_posix():sha(path) for path in sorted(paths)}}
    (root/'lock.json').write_text(json.dumps(lock,indent=2)+'\n');(root/'index.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    verify(root);print(json.dumps({'sealed_files':len(paths),**report}))
