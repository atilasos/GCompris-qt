# SPDX-License-Identifier: GPL-3.0-or-later
"""Validate a supervisor's observed completion against exact native inputs."""
import hashlib
import json


def verify_status(path,receipt,case,expected_exit):
    status=json.loads(path.read_text())
    native=json.loads(receipt.read_text())
    assert status['format']==1 and status['kind']=='observed-subprocess-exit'
    assert status['exit_code']==expected_exit,'Native launcher did not finish with expected status'
    assert status['native_receipt_sha256']==hashlib.sha256(receipt.read_bytes()).hexdigest()
    assert status['case_sha256']==hashlib.sha256(case.read_bytes()).hexdigest()==native['case_sha256']
    assert status['launcher_sha256']==native['runner_sha256']
    return status
