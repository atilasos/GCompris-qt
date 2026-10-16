# SPDX-License-Identifier: GPL-3.0-or-later
import hashlib,os,subprocess,sys,tempfile,unittest
from pathlib import Path
HERE=Path(__file__).resolve().parent
class GridsBoundaries(unittest.TestCase):
 def test_existing_output_rejected_before_source_or_snapshot_access_and_any_write(self):
  with tempfile.TemporaryDirectory(prefix='grids existing output ') as temporary:
   root=Path(temporary);output=root/'existing';output.mkdir();(output/'tool-exit.json').write_bytes(b'original observation');before={p.name:p.read_bytes() for p in output.iterdir()};result=subprocess.run([sys.executable,str(HERE/'run.py'),'--source-root',str(root/'absent'),'--snapshot',str(root/'absent snapshot'),'--activity','sudoku','--output',str(output)],capture_output=True,text=True);self.assertEqual(result.returncode,2);self.assertIn('new output directory',result.stderr);self.assertEqual({p.name:p.read_bytes() for p in output.iterdir()},before)
 def test_all_validation_clis_reject_optimized_python(self):
  for name in ['phase.py','prepare.py','run.py','observe_tool.py','seal.py','audit.py']:
   with self.subTest(name=name):
    result=subprocess.run([sys.executable,'-O',str(HERE/name),'--help'],capture_output=True,text=True,env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1'));self.assertNotEqual(result.returncode,0);self.assertIn('assertions',result.stderr)
if __name__=='__main__':unittest.main()
