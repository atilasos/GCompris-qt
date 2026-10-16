# SPDX-License-Identifier: GPL-3.0-or-later
"""Exercise the real runner CLI with a normal subprocess at its native boundary."""
import os,shutil,subprocess,sys,tempfile,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
class NativeBoundary(unittest.TestCase):
 def test_exit_and_receipt_must_both_pass(self):
  with tempfile.TemporaryDirectory() as temporary:
   root=Path(temporary);suite=root/'tests/functional_challenges';suite.mkdir(parents=True);(root/'tools').mkdir()
   shutil.copyfile(ROOT/'tests/functional_challenges/run.py',suite/'run.py')
   (suite/'phase.py').write_text('from pathlib import Path\nROOT=Path(__file__).resolve().parents[2]\ndef freeze(revision):return ROOT\n')
   (suite/'inventory.py').write_text("def inventory(source):return {'guess24':[{'count':1}]}\n")
   for name in ['guess24.qml','visible.fragment','solver.fragment']:(suite/name).write_text('public fixture')
   (root/'tools/run-native-qml-supervised.py').write_text('''import hashlib,json,os,sys
from pathlib import Path
args=sys.argv;output=Path(args[args.index('--output')+1]);case=Path(args[args.index('--case')+1]);output.mkdir()
(output/'result.json').write_text(json.dumps({'passed':os.environ['FIXTURE_PASSED']=='1','case_result':{'completed':[{}],'wins':1}}))
(output/'launcher-status.json').write_text(json.dumps({'case_sha256':hashlib.sha256(case.read_bytes()).hexdigest()}))
sys.exit(int(os.environ['FIXTURE_EXIT']))
''')
   for index,(outer,passed,expected) in enumerate([(1,True,1),(0,False,1),(0,True,0)]):
    run=subprocess.run([sys.executable,str(suite/'run.py'),'--activity','guess24','--revision','fixture','--snapshot',str(root),'--output',str(root/str(index))],env=dict(os.environ,FIXTURE_EXIT=str(outer),FIXTURE_PASSED=str(int(passed))),capture_output=True,text=True)
    self.assertEqual(run.returncode,expected,run.stderr)
if __name__=='__main__':unittest.main()
