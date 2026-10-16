# SPDX-License-Identifier: GPL-3.0-or-later
import subprocess,sys,tempfile,unittest
from pathlib import Path
HERE=Path(__file__).resolve().parent
class CreationOutputBoundary(unittest.TestCase):
 def test_existing_output_is_untouched_before_source_read(self):
  with tempfile.TemporaryDirectory() as d:
   p=Path(d);sentinel=p/'tool-exit.json';sentinel.write_bytes(b'original')
   args=['--source-root',str(p/'missing'),'--snapshot',str(p/'missing'),'--activity','sketch','--exact-case',str(p/'missing'),'--output',str(p)]
   result=subprocess.run([sys.executable,str(HERE/'run.py'),*args],capture_output=True)
   self.assertEqual(result.returncode,2);self.assertIn(b'new output',result.stderr);self.assertEqual(sentinel.read_bytes(),b'original');self.assertEqual(list(p.iterdir()),[sentinel])
 def test_optimized_runner_rejected(self):
  result=subprocess.run([sys.executable,'-O',str(HERE/'run.py'),'--help'],capture_output=True)
  self.assertNotEqual(result.returncode,0);self.assertIn(b'-O',result.stderr)
if __name__=='__main__':unittest.main()
