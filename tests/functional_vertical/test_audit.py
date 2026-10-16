# SPDX-License-Identifier: GPL-3.0-or-later
"""Audit real copied receipts; preserve phase identities and reject tampering."""
import hashlib,json,shutil,subprocess,sys,tempfile,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
EVIDENCE=ROOT/'.scratch/pt-pt/functional-vertical'
AUDITOR=ROOT/'tests/functional_vertical/audit.py'
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def reseal_index(evidence):
 p=evidence/'index.json';d=json.loads(p.read_text())
 for relative in d['artifact_sha256']:d['artifact_sha256'][relative]=sha(evidence/relative)
 for row in d['selected_final_cases']:row['result_sha256']=sha(evidence/row['folder']/'result.json')
 p.write_text(json.dumps(d))
class IdentityAudit(unittest.TestCase):
 def test_changed_receipt_fields_are_rejected_across_all_three_phases(self):
  with tempfile.TemporaryDirectory(prefix='vertical-audit-') as tmp:
   evidence=Path(tmp)/'copy';shutil.copytree(EVIDENCE,evidence,ignore=shutil.ignore_patterns('.native-qml-*'))
   for folder in ['previous-red','intermediate/vertical_addition-01','final/vertical_addition-01']:
    file=evidence/folder/'result.json';original=file.read_bytes()
    for field in ['source_sha256','portuguese_catalogue_sha256','runner_sha256','case_sha256','resource_manifest_sha256','binary_sha256']:
     with self.subTest(folder=folder,field=field):
      d=json.loads(original);d[field]='0'*64;file.write_text(json.dumps(d));reseal_index(evidence)
      run=subprocess.run([sys.executable,str(AUDITOR),str(evidence)],capture_output=True,text=True,timeout=30)
      self.assertNotEqual(run.returncode,0,f'Accepted altered {field} in {folder}')
      file.write_bytes(original)

class CoherentlyResealedArchive(unittest.TestCase):
 def test_resealed_po_manifest_bindings_and_receipts_are_rejected(self):
  with tempfile.TemporaryDirectory(prefix='vertical-resealed-') as tmp:
   evidence=Path(tmp)/'copy';shutil.copytree(EVIDENCE,evidence,ignore=shutil.ignore_patterns('.native-qml-*'))
   source=evidence/'frozen-source/complete'
   extra=source/'src/activities/vertical_subtraction/manifest.json';extra.write_text('{}')
   result=subprocess.run([sys.executable,str(AUDITOR),str(evidence)],capture_output=True,text=True,timeout=30)
   self.assertNotEqual(result.returncode,0,'The root manifest exception must not hide an extra nested file')
   extra.unlink()
   catalogue=source/'poqm/pt/gcompris_qt.po';catalogue.write_bytes(catalogue.read_bytes()+b'\n# changed historical bytes\n')
   qml=source/'src/activities/vertical_subtraction/VerticalSubtraction.qml';qml.write_bytes(qml.read_bytes()+b'\n// changed historical bytes\n')
   manifest=source/'manifest.json';data=json.loads(manifest.read_text());data['poqm/pt/gcompris_qt.po']=sha(catalogue);data['src/activities/vertical_subtraction/VerticalSubtraction.qml']=sha(qml);manifest.write_text(json.dumps(data,indent=2)+'\n')
   file=evidence/'receipt-inputs.json';bindings=json.loads(file.read_text())
   for folder,binding in bindings.items():
    if binding['source']=='frozen-source/complete':
     binding['source_manifest_sha256']=sha(manifest)
     receipt=evidence/folder/'result.json';data=json.loads(receipt.read_text());data['portuguese_catalogue_sha256']=sha(catalogue);data['source_sha256']=sha(qml);receipt.write_text(json.dumps(data))
   file.write_text(json.dumps(bindings));reseal_index(evidence)
   result=subprocess.run([sys.executable,str(AUDITOR),str(evidence)],capture_output=True,text=True,timeout=30)
   self.assertNotEqual(result.returncode,0,'Coherently re-signed historical PO must not pass an immutable-source audit')

@unittest.skipUnless(shutil.which('docker'),'Copied-proof isolation requires Docker')
class PortableAudit(unittest.TestCase):
 def test_copy_passes_without_worktree_and_corrupt_archives_are_rejected(self):
  image=subprocess.check_output(['docker','image','inspect','python:3.12-slim','--format','{{.Id}}'],text=True).strip()
  with tempfile.TemporaryDirectory(prefix='vertical-portable-') as tmp:
   suite=Path(tmp);evidence=suite/'evidence';shutil.copytree(EVIDENCE,evidence,ignore=shutil.ignore_patterns('.native-qml-*'))
   for name in ['audit.py','oracle.py']:shutil.copyfile(AUDITOR.parent/name,suite/name)
   bootstrap=('import pathlib,runpy,sys; '+f'assert not pathlib.Path({str(ROOT)!r}).exists(); '+"sys.path.insert(0,'/suite');sys.argv=['/suite/audit.py','/suite/evidence'];runpy.run_path('/suite/audit.py',run_name='__main__')")
   command=['docker','run','--rm','--read-only','--network','none','--cap-drop','ALL','--security-opt','no-new-privileges','--user','1000:1000','--mount',f'type=bind,src={suite},dst=/suite,readonly',image,'python','-B','-c',bootstrap]
   def invoke():return subprocess.run(command,capture_output=True,text=True,timeout=30)
   p=invoke();self.assertEqual(p.returncode,0,p.stderr);d=json.loads(p.stdout);self.assertEqual(d['puzzles'],360);self.assertEqual(d['datasets'],36)
   targets=['final/vertical_addition-01/case.qml','frozen-source/complete/src/activities/vertical_subtraction/subtraction.js','frozen-source/complete/poqm/pt/gcompris_qt.po','native-launcher.py','complete-resource-snapshot.json','complete-qt-resource-identity.json','frozen-source/complete/manifest.json']
   for relative in targets:
    with self.subTest(archive=relative):
     file=evidence/relative;original=file.read_bytes()
     if relative.endswith('.json'):
      d=json.loads(original)
      if relative.endswith('manifest.json'):d['src/activities/vertical_subtraction/subtraction.js']='0'*64
      elif relative=='complete-resource-snapshot.json':d['files']['bin/gcompris-qt']='0'*64
      else:d['vertical_addition'][0]['sha256']='0'*64
      file.write_text(json.dumps(d))
     else:file.write_bytes(original+b'\n ')
     reseal_index(evidence)
     p=invoke();self.assertNotEqual(p.returncode,0,p.stdout);file.write_bytes(original)
if __name__=='__main__':unittest.main()
