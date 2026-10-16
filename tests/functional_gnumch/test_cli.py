# SPDX-License-Identifier: GPL-3.0-or-later
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[2]
RUNNER=ROOT/'tests/functional_gnumch/run.py'

class GnumchSelectionCLI(unittest.TestCase):
 def test_invalid_ranges_are_rejected_before_preparation(self):
  for activity,total in [('gnumch-equality',40),('gnumch-inequality',40),('gnumch-factors',8),('gnumch-multiples',8),('gnumch-primes',8)]:
   for start,count in [(0,1),(1,0),(total,2),(999,1)]:
    with self.subTest(activity=activity,start=start,count=count),tempfile.TemporaryDirectory() as tmp:
     output=Path(tmp)/'output'
     p=subprocess.run([sys.executable,str(RUNNER),'--activity',activity,'--snapshot',tmp+'/absent','--output',str(output),'--start-level',str(start),'--levels',str(count)],capture_output=True,text=True,timeout=10)
     self.assertEqual(p.returncode,2,p.stdout+p.stderr);self.assertIn('Invalid level selection',p.stderr);self.assertFalse(output.exists())
 def test_existing_output_is_preserved(self):
  with tempfile.TemporaryDirectory() as tmp:
   output=Path(tmp)/'output';output.mkdir();(output/'case.qml').write_bytes(b'original-case\x00')
   p=subprocess.run([sys.executable,str(RUNNER),'--activity','gnumch-equality','--snapshot',tmp+'/absent','--output',str(output),'--levels','1'],capture_output=True,text=True,timeout=10)
   self.assertEqual(p.returncode,2);self.assertEqual((output/'case.qml').read_bytes(),b'original-case\x00');self.assertEqual([f.name for f in output.iterdir()],['case.qml'])
if __name__=='__main__':unittest.main()
