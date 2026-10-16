# SPDX-License-Identifier: GPL-3.0-or-later
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


class ColorsCLI(unittest.TestCase):
    def test_incompatible_options_reject_before_snapshot_or_output(self):
        with tempfile.TemporaryDirectory() as folder:
            output = Path(folder)/'untouched'
            for options in [['--activity', 'colors', '--case', 'slider-ranges'],
                            ['--activity', 'color_mix', '--levels', '7'],
                            ['--activity', 'advanced_colors', '--case', 'controls', '--levels', '1']]:
                process = subprocess.run([sys.executable, str(Path(__file__).with_name('run.py')),
                                          '--resource-snapshot', folder, '--output', str(output), *options], capture_output=True, text=True)
                self.assertEqual(process.returncode, 2)
                self.assertIn('error:', process.stderr)
                self.assertFalse(output.exists())
