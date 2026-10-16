# SPDX-License-Identifier: GPL-3.0-or-later
"""Real CLI boundaries reject empty plans and preserve archived output bytes."""
import subprocess,sys,tempfile,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
class RunnerBoundaries(unittest.TestCase):
 def invoke(self,args,output):
  return subprocess.run([sys.executable,str(ROOT/'tests/functional_share/run.py'),'--revision','nonexistent-do-not-prepare','--snapshot','unused','--output',str(output),*args],capture_output=True)
 def test_invalid_combinations_do_not_prepare_sources_or_outputs(self):
  with tempfile.TemporaryDirectory() as tmp:
   output=Path(tmp)/'new'
   for args in [['--start-level','0'],['--start-level','16'],['--levels','0'],['--start-level','15','--levels','2']]:
    with self.subTest(args=args):
     result=self.invoke(args,output);self.assertEqual(result.returncode,2);self.assertIn(b'Invalid nonempty',result.stderr);self.assertFalse(output.exists())
 def test_existing_output_is_untouched_before_preparation(self):
  with tempfile.TemporaryDirectory() as tmp:
   output=Path(tmp);(output/'case.qml').write_bytes(b'archived\0case');(output/'result.json').write_bytes(b'archived result')
   before={p.name:p.read_bytes() for p in output.iterdir()};result=self.invoke([],output)
   self.assertEqual(result.returncode,2);self.assertIn(b'Output must be new',result.stderr);self.assertEqual({p.name:p.read_bytes() for p in output.iterdir()},before)
if __name__=='__main__':unittest.main()
