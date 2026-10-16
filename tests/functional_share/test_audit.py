# SPDX-License-Identifier: GPL-3.0-or-later
"""The real auditor CLI rejects coherent re-sealing, including under Python -O."""
import hashlib,json,shutil,subprocess,sys,tempfile,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
BASE=ROOT/'.scratch/pt-pt/functional-share'
CLI=ROOT/'tests/functional_share/audit.py'
def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()
class ImmutableSharingProof(unittest.TestCase):
 def setUp(self):
  self.tmp=tempfile.TemporaryDirectory();self.addCleanup(self.tmp.cleanup)
  self.copy=Path(self.tmp.name)/'copy';shutil.copytree(BASE,self.copy,ignore=shutil.ignore_patterns('.native-qml-*'))
 def invoke(self,optimized=False):return subprocess.run([sys.executable,*(['-O'] if optimized else []),str(CLI),'--evidence',str(self.copy),'--repository',str(ROOT)],capture_output=True,text=True,timeout=45)
 def edit(self,relative,change):
  path=self.copy/relative;data=json.loads(path.read_text());change(data);path.write_text(json.dumps(data))
 def reseal(self):
  def update(index):
   for path in index['files']:index['files'][path]=digest(self.copy/path)
  self.edit('index.json',update)
 def rejected(self):
  for optimized in [False,True]:
   with self.subTest(optimized=optimized):self.assertNotEqual(self.invoke(optimized).returncode,0)
 def test_copied_original_passes_with_optimization(self):
  for optimized in [False,True]:
   run=self.invoke(optimized);self.assertEqual(run.returncode,0,run.stderr);self.assertEqual(json.loads(run.stdout)['questions'],146)
 def test_resealed_catalogue_and_source_identities_are_rejected(self):
  self.edit('full/hidden-01/result.json',lambda d:d.update(source_sha256='0'*64,portuguese_catalogue_sha256='0'*64))
  self.edit('phases/final/source-manifest.json',lambda d:d['files'].update({'poqm/pt/gcompris_qt.po':'0'*64,'src/activities/share/Share.qml':'0'*64}))
  self.reseal();self.rejected()
 def test_outer_failure_cannot_be_hidden_by_green_native_json(self):
  self.edit('full/hidden-01/launcher-status.json',lambda d:d.update(exit_code=1));self.reseal();self.rejected()
 def test_resealed_case_and_painted_distribution_are_rejected(self):
  folder=self.copy/'full/hidden-01';case=folder/'case.qml';case.write_bytes(case.read_bytes()+b'\n// changed input\n')
  def receipt(d):d['case_sha256']=digest(case);d['case_result']['completed'][0]['final'][0]['count']=6
  self.edit('full/hidden-01/result.json',receipt)
  self.edit('full/hidden-01/launcher-status.json',lambda d:d.update(case_sha256=digest(case),native_receipt_sha256=digest(folder/'result.json')))
  self.reseal();self.rejected()
 def test_resealed_effective_qt_source_bytes_are_rejected(self):
  path=self.copy/'effective/resources/src/activities/share/CandyWidget.qml';path.write_bytes(path.read_bytes()+b'\n// resealed wrong source\n')
  def identities(d):
   for entry in d['share-effective']['files']:
    if entry['path'].endswith('/CandyWidget.qml'):entry.update(sha256=digest(path),bytes=path.stat().st_size)
  self.edit('qt-resources.json',identities);self.reseal();self.rejected()
if __name__=='__main__':unittest.main()
