# SPDX-License-Identifier: GPL-3.0-or-later
"""Keep retrospective tool observations distinct from new supervisor sidecars."""
import hashlib
import json
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from native_qml_supervision import verify_status
OBSERVATIONS_SHA256='f4c1c16f6847e90bf32d709a847d589b05b3d502bf65e65b0ece9006bf5c020c'


def historical_completion(base,name,expected_exit):
    raw=(base/'supervisor-observations.json').read_bytes()
    assert hashlib.sha256(raw).hexdigest()==OBSERVATIONS_SHA256,'Immutable retrospective supervisor observations'
    history=json.loads(raw)
    rows={row['directory']:row for row in history['observations']}
    assert len(rows)==len(history['observations'])==18 and not history['missing_outcomes']
    observation=rows[name]
    assert observation['launcher_exit_code']==expected_exit,'Historical native launcher completion'
    assert observation['native_receipt_sha256']==hashlib.sha256((base/name/'result.json').read_bytes()).hexdigest()
    assert observation['case_sha256']==hashlib.sha256((base/name/'case.qml').read_bytes()).hexdigest()


def verify_completion(base,name,expected_exit):
    status=base/name/'launcher-status.json'
    if status.exists():
        return verify_status(status,base/name/'result.json',base/name/'case.qml',expected_exit)
    historical_completion(base,name,expected_exit)
