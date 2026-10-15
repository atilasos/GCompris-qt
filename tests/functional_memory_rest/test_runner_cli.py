# SPDX-License-Identifier: GPL-3.0-or-later
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[2]
RUNNER=ROOT/'tests/functional_memory_rest/run.py'

class RunnerSelectionCLI(unittest.TestCase):
    def assert_rejected_before_preparation(self,activity,case):
        with tempfile.TemporaryDirectory() as directory:
            temporary=Path(directory)
            # A real Node executable is neither needed nor allowed for a bad
            # selection. This sentinel records accidental data preparation.
            sentinel=temporary/'node';marker=temporary/'node-was-started'
            sentinel.write_text('#!/bin/sh\ntouch "$NODE_MARKER"\nexit 0\n')
            sentinel.chmod(0o755)
            output=temporary/'output'
            environment={**os.environ,'PATH':str(temporary)+os.pathsep+os.environ['PATH'],'NODE_MARKER':str(marker)}
            result=subprocess.run([sys.executable,str(RUNNER),'--binary',sys.executable,
                '--snapshot',str(temporary/'absent-snapshot'),'--output',str(output),
                '--activity',activity,'--case',case],cwd=ROOT,env=environment,
                text=True,capture_output=True,timeout=15)
            self.assertEqual(result.returncode,2,result.stdout+result.stderr)
            self.assertIn('No applicable cases',result.stderr)
            self.assertFalse(marker.exists(),'Rejected selections must not prepare data')
            self.assertFalse(output.exists(),'Rejected selections must not create output')

    def test_inapplicable_activity_case_combinations(self):
        invalid=[('memory','audio_probe'),('memory-tux','audio_probe'),
                 ('memory-tux','configuration'),('memory-sound-tux','configuration'),
                 ('memory-case-association-tux','configuration')]
        for activity,case in invalid:
            with self.subTest(activity=activity,case=case):
                self.assert_rejected_before_preparation(activity,case)

if __name__=='__main__':unittest.main()
