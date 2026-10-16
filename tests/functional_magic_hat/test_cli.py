# SPDX-License-Identifier: GPL-3.0-or-later
import subprocess
import sys
from pathlib import Path
import unittest

HERE=Path(__file__).resolve().parent


class ValidationInterpreter(unittest.TestCase):
    def test_optimized_python_is_explicitly_rejected_at_cli_boundaries(self):
        for filename in ['phase.py','prepare.py','inventory.py','run.py','capture.py','index.py','audit.py']:
            with self.subTest(filename=filename):
                result=subprocess.run([sys.executable,'-O',str(HERE/filename),'--help'],capture_output=True,text=True)
                self.assertNotEqual(result.returncode,0)
                self.assertIn('assertions',result.stderr)
