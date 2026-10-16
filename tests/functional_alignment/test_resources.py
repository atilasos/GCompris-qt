# SPDX-License-Identifier: GPL-3.0-or-later
import hashlib,json,shutil,subprocess,sys,tempfile,unittest,zipfile
from pathlib import Path
HERE=Path(__file__).resolve().parent
BASE=HERE.parents[1]/'.scratch/pt-pt/functional-alignment'
SUPPLEMENT=HERE.parents[1]/'.scratch/pt-pt/functional-alignment-resources'
class EffectivePhysicalResources(unittest.TestCase):
 def setUp(self):
  self.temp=tempfile.TemporaryDirectory(prefix='alignment resources physical copy ');self.addCleanup(self.temp.cleanup);self.root=Path(self.temp.name);self.original=self.root/'original';self.supplement=self.root/'supplement';shutil.copytree(BASE,self.original);shutil.copytree(SUPPLEMENT,self.supplement)
  for name in ['audit.py','oracle.py','audit_resources.py']:shutil.copyfile(HERE/name,self.root/name)
 def invoke(self,optimized=False):return subprocess.run([sys.executable,*(['-O'] if optimized else []),str(self.root/'audit_resources.py'),'--original',str(self.original),'--supplement',str(self.supplement)],cwd=self.root,capture_output=True,text=True)
 def test_copied_physical_overrides_and_extractions_verify_all_historical_receipts(self):
  result=self.invoke();self.assertEqual(result.returncode,0,result.stdout+result.stderr);summary=json.loads(result.stdout);self.assertEqual(summary['receipts_with_exact_overrides'],39);self.assertEqual(summary['primary_games_preserved'],42)
 def change_object(self,digest,missing=False,coherent=False):
  path=self.supplement/'resources.zip'
  with zipfile.ZipFile(path) as bundle:entries={name:bundle.read(name) for name in bundle.namelist()}
  key='objects/'+digest
  if missing:del entries[key]
  else:
   raw=entries[key];entries[key]=raw[:-1]+bytes([raw[-1]^1])
   if coherent:
    replacement=hashlib.sha256(entries[key]).hexdigest();entries['objects/'+replacement]=entries.pop(key);report=self.supplement/'resources.json';report.write_text(report.read_text().replace(digest,replacement))
  with zipfile.ZipFile(path,'w',zipfile.ZIP_DEFLATED) as bundle:
   for name,raw in entries.items():bundle.writestr(name,raw)
  if coherent:
   capture=self.supplement/'capture.json';value=json.loads(capture.read_text());value['files']={name:hashlib.sha256((self.supplement/name).read_bytes()).hexdigest() for name in value['files']};capture.write_text(json.dumps(value,indent=2)+'\n')
 def reject(self):
  result=self.invoke();self.assertNotEqual(result.returncode,0);self.assertIn('Alignment physical resources rejected',result.stderr)
 def test_changed_physical_private_rcc_is_rejected(self):
  value=json.loads((self.supplement/'resources.json').read_text());self.change_object(value['cases']['tic-ai-complete']['rcc']['rcc_sha256']);self.reject()
 def test_changed_physical_qm_is_rejected(self):
  value=json.loads((self.supplement/'resources.json').read_text());self.change_object(value['cases']['align-ai-complete']['qm_sha256']);self.reject()
 def test_changed_qt_instrumented_extraction_is_rejected(self):
  value=json.loads((self.supplement/'resources.json').read_text());self.change_object(value['cases']['keyboard-ai-green']['instrumented_qml_sha256']);self.reject()
 def test_missing_physical_override_is_rejected(self):
  value=json.loads((self.supplement/'resources.json').read_text());self.change_object(value['cases']['align-ai-complete']['rcc']['rcc_sha256'],missing=True);self.reject()
 def test_coherent_new_object_identity_report_and_reseal_cannot_replace_literal_anchor(self):
  value=json.loads((self.supplement/'resources.json').read_text());self.change_object(value['cases']['tic-ai-complete']['rcc']['rcc_sha256'],coherent=True);result=self.invoke();self.assertNotEqual(result.returncode,0);self.assertIn('Immutable supplemental capture changed',result.stderr)
 def test_copy_alteration_does_not_change_original_resources(self):
  before=(SUPPLEMENT/'resources.zip').read_bytes();value=json.loads((self.supplement/'resources.json').read_text());self.change_object(value['cases']['keyboard-ai-green']['qm_sha256']);self.reject();self.assertEqual((SUPPLEMENT/'resources.zip').read_bytes(),before)
 def test_optimized_audit_is_explicitly_rejected(self):
  result=self.invoke(True);self.assertNotEqual(result.returncode,0);self.assertIn('assertions',result.stderr)
 def test_reconstruction_rejects_existing_output_without_writing(self):
  directory=self.root/'existing reconstruction';directory.mkdir();sentinel=directory/'original.txt';sentinel.write_bytes(b'keep original output');result=subprocess.run([sys.executable,str(HERE/'reconstruct_resources.py'),'--output',str(directory)],capture_output=True,text=True);self.assertNotEqual(result.returncode,0);self.assertIn('new supplementary output',result.stderr);self.assertEqual({p.name:p.read_bytes() for p in directory.iterdir()},{'original.txt':b'keep original output'})
 def test_optimized_reconstruction_is_explicitly_rejected_before_output(self):
  directory=self.root/'absent output';result=subprocess.run([sys.executable,'-O',str(HERE/'reconstruct_resources.py'),'--output',str(directory)],capture_output=True,text=True);self.assertNotEqual(result.returncode,0);self.assertIn('assertions',result.stderr);self.assertFalse(directory.exists())
if __name__=='__main__':unittest.main()
