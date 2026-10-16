# SPDX-License-Identifier: GPL-3.0-or-later
import hashlib,json,shutil,subprocess,sys,tempfile,unittest,zipfile
from pathlib import Path
HERE=Path(__file__).resolve().parent;BASE=HERE.parents[1]/'.scratch/pt-pt/functional-grids/capsule'
class GridsPhysicalAudit(unittest.TestCase):
 def setUp(self):
  self.temp=tempfile.TemporaryDirectory(prefix='grids physical copy ');self.addCleanup(self.temp.cleanup);self.root=Path(self.temp.name);self.copy=self.root/'only evidence';shutil.copytree(BASE,self.copy)
  for name in ['audit.py','oracle.py','static_data.py']:shutil.copyfile(HERE/name,self.root/name)
 def invoke(self,optimized=False):return subprocess.run([sys.executable,*(['-O'] if optimized else []),str(self.root/'audit.py'),'--capsule',str(self.copy)],cwd=self.root,capture_output=True,text=True)
 def test_portable_physical_copy_without_original_tree_git_or_qt(self):
  result=self.invoke();self.assertEqual(result.returncode,0,result.stdout+result.stderr);value=json.loads(result.stdout);self.assertEqual(value['boards'],168);self.assertEqual(value['levels'],18)
 def mutate(self,artifact,callback,coherent=False):
  capture_path=self.copy/'capture.json';capture=json.loads(capture_path.read_text())
  with zipfile.ZipFile(self.copy/'objects.zip') as bundle:objects={name.removeprefix('objects/'):bundle.read(name) for name in bundle.namelist()}
  digest=capture['files'][artifact];raw=callback(objects[digest]);replacement=hashlib.sha256(raw).hexdigest();objects[replacement]=raw
  if coherent:
   capture['files'][artifact]=replacement;required=set(capture['files'].values())
   for value in capture['phases'].values():
    required.update(value['source']['files'].values());required.add(value['snapshot_manifest'])
    for rcc in value['canonical'].values():required.add(rcc['rcc_sha256']);required.update(row['sha256'] for row in rcc['files'])
   required.add(capture['origin_snapshot_manifest']);objects={key:value for key,value in objects.items() if key in required};capture['objects']=sorted(objects);capture_path.write_text(json.dumps(capture,indent=2)+'\n')
  else:objects[digest]=raw;objects.pop(replacement,None)
  with zipfile.ZipFile(self.copy/'objects.zip','w',zipfile.ZIP_DEFLATED) as bundle:
   for digest,raw in objects.items():bundle.writestr('objects/'+digest,raw)
 def reject(self):
  result=self.invoke();self.assertNotEqual(result.returncode,0);self.assertIn('Grids evidence rejected',result.stderr)
 def test_physical_private_rcc_corruption_is_rejected(self):self.mutate('cases/sudoku-dataset-4/resources/sudoku.rcc',lambda raw:raw+b'forged');self.reject()
 def test_physical_qm_corruption_is_rejected(self):self.mutate('cases/calcudoku-dataset-5/resources/gcompris_qt_pt.qm',lambda raw:raw+b'forged');self.reject()
 def test_physical_instrumented_qml_corruption_is_rejected(self):self.mutate('cases/sudoku-dataset-4/resources/extracted/gcompris/src/activities/sudoku/Sudoku.qml',lambda raw:raw+b'\n// forged');self.reject()
 def test_empty_completion_and_reseal_cannot_replace_literal_anchor(self):
  def change(raw):
   value=json.loads(raw);value['case_result']['evidence']['levels'][0]['boards']=[];return json.dumps(value).encode()
  self.mutate('cases/sudoku-dataset-4/result.json',change,True);self.reject()
 def test_forged_outer_success_and_coherent_reseal_is_rejected(self):
  def change(raw):value=json.loads(raw);value['exit_code']=0;return json.dumps(value).encode()
  self.mutate('cases/sudoku-help-red/tool-exit.json',change,True);self.reject()
 def test_copied_case_mutation_does_not_change_original_capsule(self):
  before=(BASE/'objects.zip').read_bytes();self.mutate('cases/calcudoku-dataset-5/case.qml',lambda raw:raw+b'\n// forged',True);self.reject();self.assertEqual((BASE/'objects.zip').read_bytes(),before)
 def test_coherent_po_sources_receipts_statuses_objects_and_reseal_hit_external_anchor(self):
  path=self.copy/'capture.json';capture=json.loads(path.read_text())
  with zipfile.ZipFile(self.copy/'objects.zip') as bundle:objects={name.removeprefix('objects/'):bundle.read(name) for name in bundle.namelist()}
  def store(raw):digest=hashlib.sha256(raw).hexdigest();objects[digest]=raw;return digest
  old=capture['phases']['final']['source']['files']['poqm/pt/gcompris_qt.po'];new=store(objects[old]+b'\n# forged historical catalogue\n');capture['phases']['final']['source']['files']['poqm/pt/gcompris_qt.po']=new
  for name,contract in capture['cases'].items():
   if contract['phase']!='final':continue
   prefix='cases/'+name+'/';receipt=json.loads(objects[capture['files'][prefix+'result.json']]);receipt['portuguese_catalogue_sha256']=new;receipt_sha=store(json.dumps(receipt).encode());capture['files'][prefix+'result.json']=receipt_sha
   status=json.loads(objects[capture['files'][prefix+'launcher-status.json']]);status['native_receipt_sha256']=receipt_sha;status_sha=store(json.dumps(status).encode());capture['files'][prefix+'launcher-status.json']=status_sha
   for filename in ['supervisor-exit.json','tool-exit.json']:
    value=json.loads(objects[capture['files'][prefix+filename]]);value['native_receipt_sha256']=receipt_sha;value['launcher_status_sha256']=status_sha;capture['files'][prefix+filename]=store(json.dumps(value).encode())
  required=set(capture['files'].values());required.add(capture['origin_snapshot_manifest'])
  for phase in capture['phases'].values():
   required.update(phase['source']['files'].values());required.add(phase['snapshot_manifest'])
   for rcc in phase['canonical'].values():required.add(rcc['rcc_sha256']);required.update(row['sha256'] for row in rcc['files'])
  capture['objects']=sorted(required);path.write_text(json.dumps(capture,indent=2)+'\n')
  with zipfile.ZipFile(self.copy/'objects.zip','w',zipfile.ZIP_DEFLATED) as bundle:
   for digest in sorted(required):bundle.writestr('objects/'+digest,objects[digest])
  result=self.invoke();self.assertNotEqual(result.returncode,0);self.assertIn('Immutable grids capsule changed',result.stderr)
 def test_optimized_audit_is_explicitly_rejected(self):
  result=self.invoke(True);self.assertNotEqual(result.returncode,0);self.assertIn('assertions',result.stderr)
if __name__=='__main__':unittest.main()
