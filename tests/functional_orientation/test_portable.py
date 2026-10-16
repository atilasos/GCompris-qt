# SPDX-License-Identifier: GPL-3.0-or-later
"""Only physical evidence and trusted auditor code; no original tree, Git or Qt."""
import json,shutil,subprocess,tempfile,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
@unittest.skipUnless(shutil.which('docker'),'Portable boundary needs installed Docker')
class PhysicalCopy(unittest.TestCase):
 def test_copy_without_any_original_path_passes_under_optimization(self):
  image=subprocess.check_output(['docker','image','inspect','alpine:latest','--format','{{.Id}}'],text=True).strip()
  with tempfile.TemporaryDirectory() as temporary:
   suite=Path(temporary);shutil.copytree(ROOT/'.scratch/pt-pt/functional-orientation',suite/'evidence',ignore=shutil.ignore_patterns('.native-qml-*'))
   code=suite/'code/tests/functional_orientation';code.mkdir(parents=True)
   for name in ['audit.py','oracle.py']:shutil.copyfile(ROOT/'tests/functional_orientation'/name,code/name)
   bootstrap=("import pathlib,runpy,sys\n"+f"if pathlib.Path({str(ROOT)!r}).exists(): raise RuntimeError('Original worktree must be inaccessible')\n"+"sys.path.insert(0,'/suite/code/tests/functional_orientation');sys.argv=['audit.py','--evidence','/suite/evidence'];runpy.run_path('/suite/code/tests/functional_orientation/audit.py',run_name='__main__')")
   command=['docker','run','--rm','--read-only','--network','none','--cap-drop','ALL','--security-opt','no-new-privileges','--user','1000:1000']
   for source,target in [('/usr','/usr'),('/lib','/lib'),('/lib64','/lib64'),(str(suite),'/suite')]:command+=['--mount',f'type=bind,src={source},dst={target},readonly']
   command+=['--entrypoint','/usr/bin/python3',image,'-B','-O','-c',bootstrap]
   result=subprocess.run(command,capture_output=True,text=True,timeout=45);self.assertEqual(result.returncode,0,result.stderr);self.assertEqual(json.loads(result.stdout)['questions'],80)
if __name__=='__main__':unittest.main()
