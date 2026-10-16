# SPDX-License-Identifier: GPL-3.0-or-later
"""Validate a copy with only trusted Git objects, no original workspace paths."""
import json,shutil,subprocess,tempfile,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
@unittest.skipUnless(shutil.which('docker'),'Portable proof requires Docker')
class PortableGitProof(unittest.TestCase):
 def test_copied_proof_passes_without_historical_worktree(self):
  image=subprocess.check_output(['docker','image','inspect','alpine:latest','--format','{{.Id}}'],text=True).strip()
  common=(ROOT/Path(subprocess.check_output(['git','rev-parse','--git-common-dir'],cwd=ROOT,text=True).strip())).resolve()
  with tempfile.TemporaryDirectory(prefix='graduated-portable-') as tmp:
   suite=Path(tmp);shutil.copytree(ROOT/'.scratch/pt-pt/functional-graduated',suite/'evidence',ignore=shutil.ignore_patterns('.native-qml-*'))
   code=suite/'code/tests/functional_graduated';code.mkdir(parents=True)
   for name in ['audit.py','oracle.py','phase.py']:shutil.copyfile(ROOT/'tests/functional_graduated'/name,code/name)
   tools=suite/'code/tools';tools.mkdir();shutil.copyfile(ROOT/'tools/native_qml_supervision.py',tools/'native_qml_supervision.py')
   bootstrap=('import pathlib,sys,runpy; '+f'assert not pathlib.Path({str(ROOT)!r}).exists(); '+"sys.path.insert(0,'/suite/code/tests/functional_graduated');sys.argv=['audit.py','--evidence','/suite/evidence','--repository','/repo'];runpy.run_path('/suite/code/tests/functional_graduated/audit.py',run_name='__main__')")
   command=['docker','run','--rm','--read-only','--network','none','--cap-drop','ALL','--security-opt','no-new-privileges','--user','1000:1000']
   for src,dst in [('/usr','/usr'),('/lib','/lib'),('/lib64','/lib64'),(str(common),'/repo'),(str(suite),'/suite')]:command+=['--mount',f'type=bind,src={src},dst={dst},readonly']
   command+=['--entrypoint','/usr/bin/python3',image,'-B','-c',bootstrap]
   run=subprocess.run(command,capture_output=True,text=True,timeout=45)
   self.assertEqual(run.returncode,0,run.stderr);self.assertEqual(json.loads(run.stdout)['questions'],574)
if __name__=='__main__':unittest.main()
