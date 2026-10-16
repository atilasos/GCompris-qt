#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Publish a validated, self-contained proof package after every process exits."""
import json
from pathlib import Path
import shutil
from audit import verify,sha,SOURCE_COMMIT,ARCHIVE_SHA,DEFAULT

if __name__=='__main__':
    evidence=DEFAULT
    report=verify(evidence,require_lock=False)
    tools=evidence/'auditor';assert not tools.exists();tools.mkdir()
    for name in ('audit.py','archive.py','inventory.py','audit_data.py','oracles.py'):
        shutil.copyfile(Path(__file__).parent/name,tools/name)
    paths=[path for root in ('archive','final','auditor','history','wording-red-final','wording-green') for path in (evidence/root).rglob('*') if path.is_file()]
    assert not any('.native-qml-' in str(path) for path in paths)
    lock={'source_commit':SOURCE_COMMIT,'archive_manifest_sha256':ARCHIVE_SHA,
          'files':{path.relative_to(evidence).as_posix():sha(path) for path in sorted(paths)}}
    (evidence/'lock.json').write_text(json.dumps(lock,indent=2)+'\n')
    (evidence/'index.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    verify(evidence)
    print(json.dumps({'levels':report['levels'],'questions':report['questions'],'sealed_files':len(paths)}))
