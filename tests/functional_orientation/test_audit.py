# SPDX-License-Identifier: GPL-3.0-or-later
"""Pure CLI copies, empty samples and coherent hash re-sealing attacks."""
import hashlib,io,json,shutil,subprocess,sys,tarfile,tempfile,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
BASE=ROOT/'.scratch/pt-pt/functional-orientation';CLI=ROOT/'tests/functional_orientation/audit.py'
def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()
class ImmutableOrientationProof(unittest.TestCase):
 def setUp(self):
  self.tmp=tempfile.TemporaryDirectory();self.addCleanup(self.tmp.cleanup);self.copy=Path(self.tmp.name)/'copy';shutil.copytree(BASE,self.copy,ignore=shutil.ignore_patterns('.native-qml-*'))
 def invoke(self,optimized=False):return subprocess.run([sys.executable,*(['-O'] if optimized else []),str(CLI),'--evidence',str(self.copy)],capture_output=True,text=True,timeout=45)
 def edit(self,path,change):
  file=self.copy/path;data=json.loads(file.read_text());change(data);file.write_text(json.dumps(data))
 def reseal(self):
  def update(index):
   for path in index['files']:index['files'][path]=digest(self.copy/path)
  self.edit('index.json',update)
 def rejected(self):
  for optimized in [False,True]:
   with self.subTest(optimized=optimized):self.assertNotEqual(self.invoke(optimized).returncode,0)
 def test_copied_valid_proof_passes_normal_and_optimized(self):
  for optimized in [False,True]:
   run=self.invoke(optimized);self.assertEqual(run.returncode,0,run.stderr);self.assertEqual(json.loads(run.stdout)['questions'],80)
 def test_green_native_json_does_not_hide_changed_external_return(self):
  self.edit('hands-complete/tool-status.json',lambda d:d.update(exit_code=1));self.reseal();self.rejected()
 def test_empty_case_set_and_empty_native_samples_rejected(self):
  self.edit('index.json',lambda d:d.update(cases={}));self.edit('hands-complete/result.json',lambda d:d['case_result'].update(completed=[]));self.reseal();self.rejected()
 def test_case_and_selected_geometry_resealed_together_are_rejected(self):
  case=self.copy/'positions-complete/case.qml';case.write_bytes(case.read_bytes()+b'\n// tampered\n')
  def change(d):d['case_sha256']=digest(case);d['case_result']['completed'][0]['index']=99
  self.edit('positions-complete/result.json',change)
  for status in ['launcher-status.json','tool-status.json']:
   self.edit('positions-complete/'+status,lambda d:d.update(case_sha256=digest(case),native_receipt_sha256=digest(self.copy/'positions-complete/result.json')))
  self.reseal();self.rejected()
 def test_physical_catalogue_capsule_and_receipt_can_not_be_resealed(self):
  capsule=self.copy/'sources/baseline/source.tar.xz'
  with tarfile.open(capsule,'r:xz') as archive:files={entry.name:archive.extractfile(entry).read() for entry in archive.getmembers()}
  files['poqm/pt/gcompris_qt.po']+=b'\n# changed historical translation\n';new_sha=hashlib.sha256(files['poqm/pt/gcompris_qt.po']).hexdigest()
  with tarfile.open(capsule,'w:xz') as archive:
   for name,raw in sorted(files.items()):
    entry=tarfile.TarInfo(name);entry.size=len(raw);archive.addfile(entry,io.BytesIO(raw))
  self.edit('sources/baseline/source-manifest.json',lambda d:d['files'].update({'poqm/pt/gcompris_qt.po':new_sha}))
  self.edit('hands-complete/result.json',lambda d:d.update(portuguese_catalogue_sha256=new_sha))
  for status in ['launcher-status.json','tool-status.json']:self.edit('hands-complete/'+status,lambda d:d.update(native_receipt_sha256=digest(self.copy/'hands-complete/result.json')))
  self.reseal();self.rejected()
 def test_resealed_actual_rcc_and_extracted_bytes_rejected(self):
  rcc=self.copy/'effective/mouse-complete/activity.rcc';rcc.write_bytes(rcc.read_bytes()+b'tampered')
  self.edit('qt-resources.json',lambda d:d['effective']['mouse-complete'].update(rcc_sha256=digest(rcc)))
  self.edit('mouse-complete/result.json',lambda d:d.update(private_rcc_sha256=digest(rcc)));self.reseal();self.rejected()
if __name__=='__main__':unittest.main()
