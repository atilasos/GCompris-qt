# SPDX-License-Identifier: GPL-3.0-or-later
"""Record actual subprocess returns; a green Qt-shaped JSON cannot replace wait."""
import json,shutil,subprocess,sys,tempfile,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
class ObservedToolStatus(unittest.TestCase):
 def test_normal_green_json_with_external_failure_is_recorded_as_failure(self):
  with tempfile.TemporaryDirectory() as temporary:
   root=Path(temporary);suite=root/'tests/functional_orientation';suite.mkdir(parents=True);shutil.copyfile(ROOT/'tests/functional_orientation/capture.py',suite/'capture.py')
   (suite/'run.py').write_text('''import argparse,json,sys
from pathlib import Path
parser=argparse.ArgumentParser();parser.add_argument('--output');parser.add_argument('--fixture-exit',type=int);args=parser.parse_args()
output=Path(args.output);output.mkdir();(output/'case.qml').write_text('fixture input')
(output/'result.json').write_text(json.dumps({'exit_code':0,'passed':True}))
sys.exit(args.fixture_exit)
''')
   for code in [0,1,7]:
    output=root/str(code);run=subprocess.run([sys.executable,str(suite/'capture.py'),'--output',str(output),'--fixture-exit',str(code)],capture_output=True,text=True)
    self.assertEqual(run.returncode,code,run.stderr);status=json.loads((output/'tool-status.json').read_text());self.assertEqual(status['exit_code'],code);self.assertEqual(status['kind'],'observed-runner-exit-after-wait');self.assertEqual(json.loads((output/'result.json').read_text())['exit_code'],0)
if __name__=='__main__':unittest.main()
