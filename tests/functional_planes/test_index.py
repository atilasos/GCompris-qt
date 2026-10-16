# SPDX-License-Identifier: GPL-3.0-or-later
"""Synthetic file fixtures test the post-wait boundary, never native game evidence."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[2]
CLI=ROOT/'tests/functional_planes/index.py'


class FinishedRunIndex(unittest.TestCase):
    def setUp(self):
        self.directory=tempfile.TemporaryDirectory();self.addCleanup(self.directory.cleanup);self.root=Path(self.directory.name)
        green=['parity-tutorial-focus','interception-tracer','number-complete','numbers-odd-even-complete','alphabet-complete','number-controls','numbers-odd-even-controls','alphabet-sequence-controls']
        red=['alphabet-modern-red','alphabet-order-red','alphabet-controller-miss','number-controller-miss','parity-controller-miss']
        for name in green+red:
            directory=self.root/name;directory.mkdir();case=b'// synthetic fixture, not a Qt run\n';(directory/'case.qml').write_bytes(case);case_sha=hashlib.sha256(case).hexdigest()
            receipt=json.dumps({'passed':name in green,'exit_code':0,'timeout':False,'case_sha256':case_sha}).encode();(directory/'result.json').write_bytes(receipt)
            (directory/'launcher-status.json').write_text(json.dumps({'exit_code':0 if name in green else 1,'native_receipt_sha256':hashlib.sha256(receipt).hexdigest(),'case_sha256':case_sha}))

    def invoke(self):return subprocess.run([sys.executable,str(CLI),'--evidence',str(self.root)],capture_output=True,text=True)

    def test_matching_finished_statuses_create_an_index(self):
        result=self.invoke();self.assertEqual(result.returncode,0,result.stderr);self.assertEqual(len(json.loads((self.root/'index.json').read_text())['cases']),13)

    def test_green_receipt_with_failed_outer_launcher_is_rejected_before_indexing(self):
        path=self.root/'number-complete/launcher-status.json';value=json.loads(path.read_text());value['exit_code']=1;path.write_text(json.dumps(value))
        result=self.invoke();self.assertEqual(result.returncode,1);self.assertIn('Unsuccessful launcher',result.stderr);self.assertFalse((self.root/'index.json').exists())

    def test_receipt_without_post_wait_status_is_rejected(self):
        (self.root/'number-complete/launcher-status.json').unlink();result=self.invoke();self.assertEqual(result.returncode,1);self.assertFalse((self.root/'index.json').exists())
