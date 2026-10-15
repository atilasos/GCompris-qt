# SPDX-License-Identifier: GPL-3.0-or-later
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
ROOT=Path(__file__).resolve().parents[2]
class DrawingRunnerCLI(unittest.TestCase):
    def test_invalid_pilot_levels_never_produce_a_success_summary(self):
        for option,value in [('--levels','0'),('--start-level','999')]:
            with self.subTest(option=option),tempfile.TemporaryDirectory() as directory:
                output=Path(directory)/'result'
                result=subprocess.run([sys.executable,str(ROOT/'tests/functional_drawing/run.py'),
                    '--snapshot',str(Path(directory)/'absent'),'--output',str(output),
                    '--activity','number_sequence',option,value],capture_output=True,text=True,timeout=10)
                self.assertEqual(result.returncode,2,result.stdout+result.stderr)
                self.assertFalse((output/'summary.json').exists())
if __name__=='__main__':unittest.main()
