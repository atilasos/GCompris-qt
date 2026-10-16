# SPDX-License-Identifier: GPL-3.0-or-later
"""The parent must record real completion even when native JSON was green."""
import hashlib,json,subprocess,sys,tempfile,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
WRAPPER=ROOT/'tools/run-native-qml-supervised.py'
class SupervisedCLI(unittest.TestCase):
 def test_green_native_json_does_not_hide_child_failure(self):
  for exit_code in [0,1]:
   with self.subTest(exit_code=exit_code),tempfile.TemporaryDirectory() as tmp:
    base=Path(tmp);case=base/'input.qml';case.write_text('TestCase {}')
    child=base/'launcher.py';child.write_text('import sys,json\nfrom pathlib import Path\noutput=Path(sys.argv[sys.argv.index("--output")+1]);output.mkdir()\n(output/"result.json").write_text(json.dumps({"passed":True,"exit_code":0}))\nsys.exit('+str(exit_code)+')\n')
    output=base/'proof'
    p=subprocess.run([sys.executable,str(WRAPPER),'--launcher',str(child),'--case',str(case),'--output',str(output),'--activity','fixture'],capture_output=True,text=True)
    self.assertTrue((output/'launcher-status.json').is_file(),p.stderr)
    status=json.loads((output/'launcher-status.json').read_text())
    self.assertEqual(p.returncode,exit_code);self.assertEqual(status['exit_code'],exit_code)
    self.assertEqual(status['native_receipt_sha256'],hashlib.sha256((output/'result.json').read_bytes()).hexdigest())
    self.assertEqual(status['case_sha256'],hashlib.sha256(case.read_bytes()).hexdigest())
    self.assertEqual(status['kind'],'observed-subprocess-exit')
 def test_existing_output_bytes_are_untouched(self):
  with tempfile.TemporaryDirectory() as tmp:
   output=Path(tmp)/'old';output.mkdir();(output/'launcher-status.json').write_bytes(b'original status')
   p=subprocess.run([sys.executable,str(WRAPPER),'--case','unused','--output',str(output)],capture_output=True)
   self.assertNotEqual(p.returncode,0);self.assertEqual((output/'launcher-status.json').read_bytes(),b'original status')
if __name__=='__main__':unittest.main()
