# SPDX-License-Identifier: GPL-3.0-or-later
"""Reject empty selections and preserve accepted output before preparation."""
import subprocess,sys,tempfile,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
class RunnerBoundaries(unittest.TestCase):
 def test_invalid_nonempty_selections_are_rejected_before_source_preparation(self):
  with tempfile.TemporaryDirectory() as tmp:
   output=Path(tmp)/'new'
   commands=[('run.py',['--start-level','0'],b'Invalid nonempty'),('run.py',['--start-level','30'],b'Invalid nonempty'),('run.py',['--levels','0'],b'Invalid nonempty'),('run.py',['--start-level','29','--levels','2'],b'Invalid nonempty'),('trace_steps.py',['--level','0','--step','1'],b'Positive configured'),('trace_steps.py',['--level','30','--step','1'],b'Positive configured'),('trace_steps.py',['--level','1','--step','0'],b'Positive configured')]
   for name,args,message in commands:
    with self.subTest(script=name,args=args):
     run=subprocess.run([sys.executable,str(ROOT/'tests/functional_graduated'/name),'--activity','graduated_line_read','--revision','nonexistent-do-not-prepare','--snapshot','unused','--output',str(output),*args],capture_output=True)
     self.assertEqual(run.returncode,2);self.assertIn(message,run.stderr);self.assertFalse(output.exists())
 def test_existing_case_and_receipt_bytes_are_preserved(self):
  with tempfile.TemporaryDirectory() as tmp:
   output=Path(tmp);(output/'case.qml').write_bytes(b'accepted case\0');(output/'result.json').write_bytes(b'accepted receipt')
   original={p.name:p.read_bytes() for p in output.iterdir()}
   for name,args in [('run.py',[]),('trace_steps.py',['--level','1','--step','1'])]:
    run=subprocess.run([sys.executable,str(ROOT/'tests/functional_graduated'/name),'--activity','graduated_line_read','--revision','nonexistent-do-not-prepare','--snapshot','unused','--output',str(output),*args],capture_output=True)
    self.assertEqual(run.returncode,2);self.assertIn(b'Output must be new',run.stderr)
    self.assertEqual(original,{p.name:p.read_bytes() for p in output.iterdir()})
if __name__=='__main__':unittest.main()
