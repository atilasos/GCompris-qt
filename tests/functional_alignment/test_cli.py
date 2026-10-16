# SPDX-License-Identifier: GPL-3.0-or-later
import hashlib,json,os,subprocess,sys,tempfile,unittest
from pathlib import Path
HERE=Path(__file__).resolve().parent
class OptimizedValidation(unittest.TestCase):
 def test_optimized_validation_clis_cannot_silently_skip_assertions(self):
  for name in ['phase.py','prepare.py','run.py','capture.py','archive.py','seal.py','audit.py']:
   with self.subTest(name=name):
    result=subprocess.run([sys.executable,'-O',str(HERE/name),'--help'],capture_output=True,text=True,env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1'));self.assertNotEqual(result.returncode,0);self.assertIn('assertions',result.stderr)

 def test_existing_output_is_rejected_before_supervisor_or_status_writes(self):
  with tempfile.TemporaryDirectory(prefix='alignment CLI ') as temporary:
   root=Path(temporary);source=root/'source';source.mkdir();(source/'source-manifest.json').write_text(json.dumps({'revision':'fixture','files':{}}));output=root/'existing';output.mkdir();sentinel=output/'tool-exit.json';sentinel.write_text('original observation\n');before={path.name:hashlib.sha256(path.read_bytes()).hexdigest() for path in output.iterdir()}
   completed=subprocess.run([sys.executable,str(HERE/'run.py'),'--source-root',str(source),'--snapshot',str(root/'absent snapshot'),'--activity','align4','--output',str(output)],capture_output=True,text=True)
   self.assertEqual(completed.returncode,2);self.assertIn('new output directory',completed.stderr);self.assertEqual({path.name:hashlib.sha256(path.read_bytes()).hexdigest() for path in output.iterdir()},before)
