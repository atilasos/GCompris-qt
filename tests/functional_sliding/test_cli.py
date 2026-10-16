# SPDX-License-Identifier: GPL-3.0-or-later
import os,subprocess,sys,unittest
from pathlib import Path
HERE=Path(__file__).resolve().parent
class OptimizedValidation(unittest.TestCase):
 def test_optimized_validation_clis_cannot_silently_skip_assertions(self):
  for name in ['phase.py','prepare.py','run.py','capture.py','archive.py','seal.py','audit.py']:
   with self.subTest(name=name):
    result=subprocess.run([sys.executable,'-O',str(HERE/name),'--help'],capture_output=True,text=True,env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1'));self.assertNotEqual(result.returncode,0);self.assertIn('assertions',result.stderr)
