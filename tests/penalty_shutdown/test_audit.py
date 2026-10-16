# SPDX-License-Identifier: GPL-3.0-or-later
import copy,hashlib,json,shutil,subprocess,sys,tempfile,unittest
from pathlib import Path
from unittest.mock import patch
import audit
ROOT=Path(__file__).resolve().parents[2]
EVIDENCE=ROOT/'.scratch/pt-pt/penalty-shutdown'
def clone(target):shutil.copytree(EVIDENCE,target,ignore=shutil.ignore_patterns('.native-qml-*'))
class PhysicalDiagnosis(unittest.TestCase):
 def test_normal_and_optimized_keep_the_issue_open(self):
  for flags in [[],['-O']]:
   run=subprocess.run([sys.executable,*flags,str(ROOT/'tests/penalty_shutdown/audit.py')],capture_output=True,text=True);self.assertEqual(run.returncode,0,run.stderr);d=json.loads(run.stdout);self.assertTrue(d['archive_valid']);self.assertFalse(d['issue_resolved']);self.assertEqual(d['historical_exit'],139)
 def test_case_pid_observation_source_and_index_tampering(self):
  for path in ['probes/baseline-bare/case.qml','probes/baseline-bare/inferior-status.json','sources/baseline/source.tar.xz','sources/final/source-manifest.json','history/penalty-complete/result.json','index.json']:
   with self.subTest(path=path),tempfile.TemporaryDirectory() as temporary:
    root=Path(temporary)/'proof';clone(root);p=root/path;p.write_bytes(p.read_bytes()+b'forged')
    with self.assertRaises((ValueError,OSError,KeyError,TypeError)):audit.audit(root)
 def test_resealing_a_green_historical139_is_rejected(self):
  with tempfile.TemporaryDirectory() as temporary:
   root=Path(temporary)/'proof';clone(root);p=root/'history/penalty-complete/result.json';d=json.loads(p.read_text());d['exit_code']=0;d['passed']=True;p.write_text(json.dumps(d));index=json.loads((root/'index.json').read_text());index['files']['history/penalty-complete/result.json']=hashlib.sha256(p.read_bytes()).hexdigest();(root/'index.json').write_text(json.dumps(index))
   with self.assertRaisesRegex(ValueError,'Immutable diagnostic index'):audit.audit(root)
 def test_empty_matrix_is_rejected_independently_of_index_anchor(self):
  with tempfile.TemporaryDirectory() as temporary:
   root=Path(temporary)/'proof';clone(root);p=root/'probes/observations.json';d=json.loads(p.read_text());d['actual']=0;d['runs']=[];p.write_text(json.dumps(d));index=json.loads((root/'index.json').read_text());index['files']['probes/observations.json']=hashlib.sha256(p.read_bytes()).hexdigest();raw=json.dumps(index).encode();(root/'index.json').write_bytes(raw)
   with patch.object(audit,'EXPECTED_INDEX_SHA256',hashlib.sha256(raw).hexdigest()):
    with self.assertRaisesRegex(ValueError,'Exact finite nonempty matrix'):audit.audit(root)
class InferiorIdentity(unittest.TestCase):
 def setUp(self):self.info=json.loads((EVIDENCE/'probes/baseline-bare/inferior-status.json').read_text());self.binary=self.info['binary_sha256']
 def test_native_signal_cannot_be_masked_by_wrapper_zero(self):
  self.info['native_exit_code']=139;self.info['signals']=['SIGSEGV']
  with self.assertRaisesRegex(ValueError,'wrapper0 is insufficient'):audit.validate_inferior(self.info,self.binary)
 def test_wrong_namespace_rejected(self):
  self.info['qt_pid_namespace']='pid:[different]'
  with self.assertRaisesRegex(ValueError,'Aligned'):audit.validate_inferior(self.info,self.binary)
 def test_raw_commandline_mismatch_rejected_even_with_true_flag(self):
  self.info['argv'][0]='/some/other/process'
  with self.assertRaisesRegex(ValueError,'cmdline'):audit.validate_inferior(self.info,self.binary)
if __name__=='__main__':unittest.main()
