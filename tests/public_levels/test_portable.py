# SPDX-License-Identifier: GPL-3.0-or-later
"""Pure copied proof, with original paths and executable tools inaccessible."""
import json,shutil,subprocess,tempfile,unittest
from pathlib import Path
from test_audit import coherent_catalogue_replacement
ROOT=Path(__file__).resolve().parents[2]
class PhysicalCopy(unittest.TestCase):
 def test_no_original_git_qt_or_network(self):
  image=subprocess.check_output(['docker','image','inspect','alpine:latest','--format','{{.Id}}'],text=True).strip()
  with tempfile.TemporaryDirectory() as temporary:
   suite=Path(temporary);shutil.copytree(ROOT/'.scratch/pt-pt/public-level-contracts/archive',suite/'evidence')
   shutil.copytree(suite/'evidence',suite/'forged');coherent_catalogue_replacement(suite/'forged')
   code=suite/'code/tests/public_levels';code.mkdir(parents=True)
   for name in ['audit.py','run.py','test_run.py']:shutil.copyfile(ROOT/'tests/public_levels'/name,code/name)
   # Mount Python's interpreter/libraries individually; /usr/bin/git and Qt
   # are deliberately absent, as are every original workspace and /home.
   bootstrap="import pathlib,shutil,sys;sys.path.insert(0,'/suite/code/tests/public_levels');from audit import audit;import json,unittest,io,test_run\n"
   bootstrap+=f"if pathlib.Path({str(ROOT)!r}).exists() or shutil.which('git') or pathlib.Path('/usr/lib/qt6').exists():raise RuntimeError('Isolation failed')\n"
   bootstrap+="result=audit(pathlib.Path('/suite/evidence'))\ntry: audit(pathlib.Path('/suite/forged'))\nexcept ValueError as error:\n if 'Historical archive index' not in str(error):raise\nelse:raise RuntimeError('Coherently replaced catalogue accepted')\n"
   bootstrap+="checked=unittest.TextTestRunner(stream=io.StringIO()).run(unittest.defaultTestLoader.loadTestsFromTestCase(test_run.ExistingOutput))\nif not checked.wasSuccessful():raise RuntimeError('Existing output bytes were changed')\nprint(json.dumps(result))"
   cmd=['docker','run','--rm','--read-only','--network','none','--cap-drop','ALL','--security-opt','no-new-privileges','--user','1000:1000','--tmpfs','/tmp:rw,mode=1777','--mount',f'type=bind,src={suite},dst=/suite,readonly']
   interpreter=Path('/usr/bin/python3').resolve()
   version=interpreter.name.removeprefix('python')
   stdlib=Path('/usr/lib')/('python'+version)
   for src in [str(interpreter),str(stdlib),'/usr/lib/x86_64-linux-gnu']:
    cmd+=['--mount',f'type=bind,src={src},dst={src},readonly']
   loader='/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2'
   cmd+=['--entrypoint',loader,image,'--library-path','/usr/lib/x86_64-linux-gnu',str(interpreter),'-B']
   for optimization in [[],['-O']]:
    with self.subTest(optimization=optimization):
     result=subprocess.run(cmd+optimization+['-c',bootstrap],capture_output=True,text=True,timeout=120);self.assertEqual(result.returncode,0,result.stderr);self.assertEqual(json.loads(result.stdout)['activities'],24)
if __name__=='__main__':unittest.main()
