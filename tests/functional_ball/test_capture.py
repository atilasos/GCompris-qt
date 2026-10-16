# SPDX-License-Identifier: GPL-3.0-or-later
import json,shutil,subprocess,sys,tempfile,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
class ActualSupervisionReturn(unittest.TestCase):
 def test_green_json_cannot_hide_nonzero_supervisor_return(self):
  with tempfile.TemporaryDirectory() as temporary:
   root=Path(temporary);suite=root/'tests/functional_ball';suite.mkdir(parents=True);(root/'tools').mkdir();shutil.copyfile(ROOT/'tests/functional_ball/capture.py',suite/'capture.py');case=root/'input.qml';case.write_text('actual fixture case')
   (root/'tools/run-native-qml-supervised.py').write_text('''import hashlib,json,sys
from pathlib import Path
a=sys.argv;o=Path(a[a.index('--output')+1]);c=Path(a[a.index('--case')+1]);o.mkdir();(o/'result.json').write_text(json.dumps({'passed':True,'exit_code':0}));(o/'launcher-status.json').write_text(json.dumps({'case_sha256':hashlib.sha256(c.read_bytes()).hexdigest()}));sys.exit(int(a[a.index('--fixture-exit')+1]))
''')
   for code in [0,1,7]:
    output=root/str(code);run=subprocess.run([sys.executable,str(suite/'capture.py'),'--case',str(case),'--output',str(output),'--fixture-exit',str(code)],capture_output=True,text=True);self.assertEqual(run.returncode,code,run.stderr);self.assertEqual(json.loads((output/'tool-status.json').read_text())['exit_code'],code);self.assertEqual((output/'case.qml').read_bytes(),case.read_bytes())
 def test_existing_proof_refused_without_any_old_byte_change(self):
  with tempfile.TemporaryDirectory() as temporary:
   root=Path(temporary);out=root/'old';out.mkdir();(out/'case.qml').write_bytes(b'old\x00case');before={p.name:p.read_bytes() for p in out.iterdir()}
   result=subprocess.run([sys.executable,str(ROOT/'tests/functional_ball/capture.py'),'--output',str(out),'--case','nonexistent'],capture_output=True);self.assertEqual(result.returncode,2);self.assertIn(b'Output must be new',result.stderr);self.assertEqual(before,{p.name:p.read_bytes() for p in out.iterdir()})
if __name__=='__main__':unittest.main()
