# SPDX-License-Identifier: GPL-3.0-or-later
"""Verify the immutable evidence CLI on copies, including coherent re-sealing."""
import hashlib,json,shutil,subprocess,sys,tempfile,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
BASE=ROOT/'.scratch/pt-pt/functional-graduated'
CLI=ROOT/'tests/functional_graduated/audit.py'
class HistoricalGraduations(unittest.TestCase):
 def setUp(self):
  self.tmp=tempfile.TemporaryDirectory(prefix='graduated-proof-');self.addCleanup(self.tmp.cleanup)
  self.copy=Path(self.tmp.name)/'copy';shutil.copytree(BASE,self.copy,ignore=shutil.ignore_patterns('.native-qml-*'))
 def invoke(self):return subprocess.run([sys.executable,str(CLI),'--evidence',str(self.copy),'--repository',str(ROOT)],capture_output=True,text=True,timeout=45)
 def reseal(self):
  file=self.copy/'index.json';d=json.loads(file.read_text())
  for path in d['files']:d['files'][path]=hashlib.sha256((self.copy/path).read_bytes()).hexdigest()
  file.write_text(json.dumps(d))
 def test_independent_copy_is_complete(self):
  run=self.invoke();self.assertEqual(run.returncode,0,run.stderr)
  d=json.loads(run.stdout);self.assertEqual(d['questions'],574);self.assertEqual(d['levels'],58)
 def test_resealed_receipt_catalogue_and_manifest_are_not_new_truth(self):
  path=self.copy/'full/graduated_line_read-01/result.json';d=json.loads(path.read_text());d['portuguese_catalogue_sha256']='0'*64;path.write_text(json.dumps(d))
  path=self.copy/'phases/final/source-manifest.json';d=json.loads(path.read_text());d['files']['poqm/pt/gcompris_qt.po']='0'*64;path.write_text(json.dumps(d));self.reseal()
  self.assertNotEqual(self.invoke().returncode,0)
 def test_failed_external_exit_cannot_be_hidden_by_green_native_json(self):
  path=self.copy/'full/graduated_line_read-01/launcher-status.json';d=json.loads(path.read_text());d['exit_code']=1;path.write_text(json.dumps(d));self.reseal()
  self.assertNotEqual(self.invoke().returncode,0)
 def test_resealed_case_and_answer_corruption_is_rejected(self):
  case=self.copy/'full/graduated_line_read-01/case.qml';case.write_bytes(case.read_bytes()+b'\n// modified\n')
  path=case.with_name('result.json');d=json.loads(path.read_text());d['case_sha256']=hashlib.sha256(case.read_bytes()).hexdigest();d['case_result']['completed'][0]['response']='999';path.write_text(json.dumps(d));self.reseal()
  self.assertNotEqual(self.invoke().returncode,0)
if __name__=='__main__':unittest.main()
