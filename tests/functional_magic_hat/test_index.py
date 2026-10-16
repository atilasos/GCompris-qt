# SPDX-License-Identifier: GPL-3.0-or-later
"""Synthetic JSON fixtures for the completion boundary, never native evidence."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from index import CASES

HERE=Path(__file__).resolve().parent


class CompletedMagicHatIndex(unittest.TestCase):
    def setUp(self):
        self.directory=tempfile.TemporaryDirectory();self.addCleanup(self.directory.cleanup);self.root=Path(self.directory.name)
        for name,kind in CASES.items():
            path=self.root/name;path.mkdir();case=b'// synthetic fixture, not a Qt run\n';(path/'case.qml').write_bytes(case);case_sha=hashlib.sha256(case).hexdigest();expected=1 if kind=='diagnostic' else 0
            raw=json.dumps({'passed':expected==0,'exit_code':0,'timeout':False,'case_sha256':case_sha}).encode();(path/'result.json').write_bytes(raw);sha=hashlib.sha256(raw).hexdigest()
            (path/'launcher-status.json').write_text(json.dumps({'format':1,'kind':'observed-subprocess-exit','exit_code':expected,'native_receipt_sha256':sha,'case_sha256':case_sha}))
            if kind!='tracer':(path/'supervisor-exit.json').write_text(json.dumps({'kind':'observed-supervisor-subprocess-exit','exit_code':expected,'native_receipt_sha256':sha}))

    def invoke(self):return subprocess.run([sys.executable,str(HERE/'index.py'),'--evidence',str(self.root)],capture_output=True,text=True)

    def test_completed_consistent_statuses_can_be_indexed(self):
        result=self.invoke();self.assertEqual(result.returncode,0,result.stderr);self.assertEqual(len(json.loads((self.root/'index.json').read_text())['cases']),6)

    def test_green_native_receipt_with_failed_launcher_is_rejected(self):
        path=self.root/'minus-complete/launcher-status.json';value=json.loads(path.read_text());value['exit_code']=1;path.write_text(json.dumps(value));result=self.invoke();self.assertEqual(result.returncode,1);self.assertIn('Unsuccessful launcher',result.stderr);self.assertFalse((self.root/'index.json').exists())

    def test_failed_supervisor_rejects_green_launcher_and_native_receipt(self):
        path=self.root/'minus-complete/supervisor-exit.json';value=json.loads(path.read_text());value['exit_code']=1;path.write_text(json.dumps(value));result=self.invoke();self.assertEqual(result.returncode,1);self.assertIn('Unsuccessful supervisor',result.stderr)

    def test_missing_post_wait_status_is_rejected(self):
        (self.root/'minus-complete/launcher-status.json').unlink();self.assertEqual(self.invoke().returncode,1);self.assertFalse((self.root/'index.json').exists())
