# SPDX-License-Identifier: GPL-3.0-or-later
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

RUNNER = Path(__file__).with_name('run.py')


class CountingCLI(unittest.TestCase):
    def test_incompatible_options_fail_before_creating_output(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / 'untouched'
            for options in [['--activity', 'smallnumbers', '--validation', 'ok'],
                            ['--activity', 'enumerate', '--case', 'selectors', '--levels', '1'],
                            ['--activity', 'smallnumbers2', '--levels', '10']]:
                process = subprocess.run([sys.executable, str(RUNNER), '--resource-snapshot', directory,
                                          '--output', str(output), *options], capture_output=True, text=True)
                self.assertEqual(process.returncode, 2)
                self.assertIn('error:', process.stderr)
                self.assertFalse(output.exists())
