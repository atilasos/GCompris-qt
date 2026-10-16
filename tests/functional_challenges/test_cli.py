# SPDX-License-Identifier: GPL-3.0-or-later
"""Real CLI refusals happen before source preparation or existing proof writes."""
import subprocess,sys,tempfile,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
class Boundaries(unittest.TestCase):
 def invoke(self,name,output,extra=()):
  args=['--revision','nonexistent-no-preparation','--snapshot','unused','--output',str(output),*extra]
  args+=['--activity','guess24']
  return subprocess.run([sys.executable,str(ROOT/'tests/functional_challenges'/name),*args],capture_output=True)
 def test_existing_output_preserved_by_runner_capture_and_coordinator(self):
  with tempfile.TemporaryDirectory() as tmp:
   out=Path(tmp);(out/'case.qml').write_bytes(b'old\0case');(out/'result.json').write_bytes(b'old receipt');before={p.name:p.read_bytes() for p in out.iterdir()}
   for name in ['run.py','capture.py']:
    run=self.invoke(name,out);self.assertEqual(run.returncode,2);self.assertIn(b'Output must be new',run.stderr);self.assertEqual(before,{p.name:p.read_bytes() for p in out.iterdir()})
 def test_empty_or_invalid_selection_rejected_before_preparation(self):
  with tempfile.TemporaryDirectory() as tmp:
   out=Path(tmp)/'new'
   for name,args in [('run.py',['--start-level','999']),('run.py',['--levels','0']),('run.py',['--start-level','6','--levels','2']),('run.py',['--kind','admin']),('run.py',['--kind','unknown']),('run.py',['--case-file','nonexistent'])]:
    run=self.invoke(name,out,args);self.assertEqual(run.returncode,2);self.assertFalse(out.exists())
if __name__=='__main__':unittest.main()
