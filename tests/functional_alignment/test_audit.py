# SPDX-License-Identifier: GPL-3.0-or-later
import hashlib,io,json,shutil,subprocess,sys,tempfile,unittest,zipfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
BASE=ROOT/'.scratch/pt-pt/functional-alignment'
HERE=Path(__file__).resolve().parent

class PhysicalEvidenceAudit(unittest.TestCase):
 def setUp(self):
  self.temp=tempfile.TemporaryDirectory(prefix='alignment physical copy ');self.addCleanup(self.temp.cleanup);self.root=Path(self.temp.name);self.copy=self.root/'only evidence';shutil.copytree(BASE,self.copy,ignore=shutil.ignore_patterns('.native-qml-*'));self.cli=self.root/'audit.py';shutil.copyfile(HERE/'audit.py',self.cli);shutil.copyfile(HERE/'oracle.py',self.root/'oracle.py')
 def invoke(self,optimized=False):return subprocess.run([sys.executable,*(['-O'] if optimized else []),str(self.cli),'--evidence',str(self.copy)],cwd=self.root,capture_output=True,text=True)
 def alter(self,name,callback):
  path=self.copy/name;value=json.loads(path.read_text());callback(value);path.write_text(json.dumps(value,indent=2)+'\n')
 def receipt_chain(self,name):
  directory=self.copy/name;case=hashlib.sha256((directory/'case.qml').read_bytes()).hexdigest();self.alter(name+'/result.json',lambda value:value.update(case_sha256=case));receipt=hashlib.sha256((directory/'result.json').read_bytes()).hexdigest()
  self.alter(name+'/launcher-status.json',lambda value:value.update(case_sha256=case,native_receipt_sha256=receipt));status=hashlib.sha256((directory/'launcher-status.json').read_bytes()).hexdigest()
  for filename in ['supervisor-exit.json','tool-exit.json']:self.alter(name+'/'+filename,lambda value:value.update(case_sha256=case,native_receipt_sha256=receipt,launcher_status_sha256=status))
 def reseal(self):
  self.alter('capture.json',lambda value:value.update(files={name:hashlib.sha256((self.copy/name).read_bytes()).hexdigest() for name in value['files']}))
 def reject(self):
  result=self.invoke();self.assertNotEqual(result.returncode,0,result.stdout+result.stderr);self.assertIn('Alignment evidence rejected',result.stderr)
 def test_physical_copy_and_copied_auditor_work_without_git_or_original_paths(self):
  result=self.invoke();self.assertEqual(result.returncode,0,result.stdout+result.stderr);self.assertEqual(json.loads(result.stdout)['games'],42)
 def test_empty_solution_route_resealed_is_rejected(self):
  self.alter('tic-ai-complete/result.json',lambda value:value['case_result']['games'][0].update(moves=[]));self.receipt_chain('tic-ai-complete');self.reseal();self.reject()
 def test_source_archive_byte_change_and_reseal_is_rejected(self):
  path=self.copy/'source-tree.zip';path.write_bytes(path.read_bytes()+b'forged source');self.reseal();self.reject()
 def test_catalogue_hash_and_reseal_is_rejected(self):
  self.alter('align-help-green/result.json',lambda value:value.update(portuguese_catalogue_sha256='0'*64));self.receipt_chain('align-help-green');self.reseal();self.reject()
 def test_copied_case_changed_after_copy_does_not_change_original(self):
  path=self.copy/'tic-ai-complete/case.qml';before=(BASE/'tic-ai-complete/case.qml').read_bytes();path.write_bytes(before+b'\n// changed case\n');self.receipt_chain('tic-ai-complete');self.reseal();self.reject();self.assertEqual((BASE/'tic-ai-complete/case.qml').read_bytes(),before)
 def test_resource_map_path_and_hash_resealed_is_rejected(self):
  self.alter('identities-baseline/resources.json',lambda value:value['canonical']['tic_tac_toe']['files'][0].update(path=':/gcompris/forged.qml',sha256='0'*64));self.reseal();self.reject()
 def test_failed_outer_and_forged_tool_success_resealed_are_rejected(self):
  self.alter('tic-ai-complete/launcher-status.json',lambda value:value.update(exit_code=1));self.alter('align-help-red/tool-exit.json',lambda value:value.update(exit_code=0));self.reseal();self.reject()
 def test_coherent_catalogue_archive_manifests_receipts_statuses_and_reseal_cannot_replace_literal_anchor(self):
  path=self.copy/'source-tree.zip';phases=json.loads((self.copy/'source-phases.json').read_text());digests={}
  with zipfile.ZipFile(path) as bundle:entries={name:bundle.read(name) for name in bundle.namelist()}
  for phase in ['baseline','help','rules','final']:
   name=phase+'/poqm/pt/gcompris_qt.po';entries[name]+=b'\n# forged historical input\n';digests[phase]=hashlib.sha256(entries[name]).hexdigest();phases[phase]['files']['poqm/pt/gcompris_qt.po']=digests[phase]
  with zipfile.ZipFile(path,'w',zipfile.ZIP_DEFLATED) as bundle:
   for name,raw in entries.items():bundle.writestr(name,raw)
  (self.copy/'source-phases.json').write_text(json.dumps(phases,indent=2)+'\n')
  for phase in ['baseline','rules','final']:(self.copy/('identities-'+phase)/'source-manifest.json').write_text(json.dumps(phases[phase],indent=2)+'\n')
  cases=json.loads((self.copy/'capture.json').read_text())['cases']
  for name,contract in cases.items():
   self.alter(name+'/result.json',lambda value:value.update(portuguese_catalogue_sha256=digests[contract['phase']]));self.receipt_chain(name)
  self.reseal();self.reject()
 def test_optimized_python_rejects_otherwise_valid_proof(self):
  result=self.invoke(True);self.assertNotEqual(result.returncode,0);self.assertIn('assertions',result.stderr)

if __name__=='__main__':unittest.main()
