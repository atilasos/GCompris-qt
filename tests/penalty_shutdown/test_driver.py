# SPDX-License-Identifier: GPL-3.0-or-later
import subprocess,sys,tempfile,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
class ProbeBoundaries(unittest.TestCase):
 def test_existing_output_rejected_before_snapshot_or_source_access(self):
  with tempfile.TemporaryDirectory() as temporary:
   out=Path(temporary);(out/'keep').write_bytes(b'prior proof\0');run=subprocess.run([sys.executable,str(ROOT/'tests/penalty_shutdown/run.py'),'--snapshot','missing','--output',str(out)],capture_output=True)
   self.assertEqual(run.returncode,2);self.assertIn(b'Output must be new',run.stderr);self.assertEqual((out/'keep').read_bytes(),b'prior proof\0');self.assertEqual(len(list(out.iterdir())),1)
 def test_missing_snapshot_rejected_before_frozen_sources_are_prepared(self):
  with tempfile.TemporaryDirectory() as temporary:
   out=Path(temporary)/'new';run=subprocess.run([sys.executable,str(ROOT/'tests/penalty_shutdown/run.py'),'--snapshot','missing','--output',str(out)],capture_output=True);self.assertEqual(run.returncode,2);self.assertIn(b'Sealed snapshot is required',run.stderr);self.assertFalse(out.exists())
if __name__=='__main__':unittest.main()
