# SPDX-License-Identifier: GPL-3.0-or-later
"""A real subprocess fixture separates native JSON from the child's exit."""
import json,os,shutil,subprocess,sys,tempfile,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
class ObservedRunnerExit(unittest.TestCase):
 def test_child_exit_and_native_assertions_are_both_required(self):
  with tempfile.TemporaryDirectory(prefix='share-runner-fixture-') as temporary:
   root=Path(temporary);scripts=root/'tests/functional_share';scripts.mkdir(parents=True)
   for name in ['run.py','phase.py','inventory.py','gameplay.qml','visible.fragment']:shutil.copyfile(ROOT/'tests/functional_share'/name,scripts/name)
   for dataset in [1,2,3]:
    target=root/f'src/activities/share/resource/{dataset}';target.mkdir(parents=True)
    shutil.copyfile(ROOT/f'src/activities/share/resource/{dataset}/Data.qml',target/'Data.qml')
   tools=root/'tools';tools.mkdir();(root/'CMakeLists.txt').write_text('# Fixture source\n')
   (tools/'run-native-qml-supervised.py').write_text('''import argparse,hashlib,json,os,sys
from pathlib import Path
parser=argparse.ArgumentParser();parser.add_argument('--output');parser.add_argument('--case');args,_=parser.parse_known_args()
output=Path(args.output);output.mkdir()
(output/'result.json').write_text(json.dumps({'passed':os.environ['FIXTURE_GREEN']=='1','case_result':{'completed':[{}]*5,'wins':1}}))
(output/'launcher-status.json').write_text(json.dumps({'case_sha256':hashlib.sha256(Path(args.case).read_bytes()).hexdigest()}))
sys.exit(int(os.environ['FIXTURE_EXIT']))
''')
   subprocess.run(['git','init','-q',str(root)],check=True);subprocess.run(['git','add','.'],cwd=root,check=True)
   subprocess.run(['git','-c','user.name=Fixture','-c','user.email=fixture@example.invalid','commit','-qm','fixture'],cwd=root,check=True)
   for child_exit,green,expected in [(1,True,1),(0,False,1),(0,True,0)]:
    with self.subTest(child_exit=child_exit,green=green):
     output=root/f'output-{child_exit}-{green}'
     env=dict(os.environ,FIXTURE_GREEN=str(int(green)),FIXTURE_EXIT=str(child_exit))
     run=subprocess.run([sys.executable,str(scripts/'run.py'),'--revision','HEAD','--snapshot','unused','--output',str(output)],env=env,capture_output=True,text=True)
     self.assertEqual(run.returncode,expected,run.stderr)
     self.assertEqual(json.loads((output/'result.json').read_text())['passed'],green)
     self.assertTrue((output/'case.qml').is_file())
if __name__=='__main__':unittest.main()
