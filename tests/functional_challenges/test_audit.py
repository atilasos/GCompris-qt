# SPDX-License-Identifier: GPL-3.0-or-later
"""Unchanged physical proofs pass; corrupted and fully re-sealed archives fail."""
import hashlib,io,json,shutil,subprocess,sys,tarfile,tempfile,unittest
from pathlib import Path
from unittest.mock import patch
import audit
ROOT=Path(__file__).resolve().parents[2]
EVIDENCE=ROOT/'.scratch/pt-pt/functional-challenges'
class ImmutableEvidence(unittest.TestCase):
 def test_original_under_normal_and_optimized_python(self):
  for optimized in [[],['-O']]:
   p=subprocess.run([sys.executable,*optimized,str(ROOT/'tests/functional_challenges/audit.py'),'--evidence',str(EVIDENCE)],capture_output=True,text=True)
   self.assertEqual(p.returncode,0,p.stderr);self.assertEqual(json.loads(p.stdout)['primary_puzzles'],186)
 def test_physical_case_receipt_capsule_manifest_and_index_tampering(self):
  paths=['native/guess24-01/case.qml','native/guess24-01/result.json','sources/language/source.tar.xz','sources/language/source-manifest.json','index.json']
  for path in paths:
   with self.subTest(path=path),tempfile.TemporaryDirectory() as temporary:
    copy=Path(temporary)/'proof';shutil.copytree(EVIDENCE,copy,ignore=shutil.ignore_patterns(".native-qml-*"));p=copy/path;p.write_bytes(p.read_bytes()+b'\nchanged')
    with self.assertRaises((ValueError,OSError,KeyError,TypeError)):audit.audit(copy)
 def test_forged_receipt_and_resealed_index_do_not_replace_historical_identity(self):
  with tempfile.TemporaryDirectory() as temporary:
   copy=Path(temporary)/'proof';shutil.copytree(EVIDENCE,copy,ignore=shutil.ignore_patterns(".native-qml-*"));path=copy/'native/guess24-01/result.json';receipt=json.loads(path.read_text());receipt['source_sha256']='0'*64;receipt['portuguese_catalogue_sha256']='0'*64;path.write_text(json.dumps(receipt));index=json.loads((copy/'index.json').read_text());index['files']['native/guess24-01/result.json']=hashlib.sha256(path.read_bytes()).hexdigest();(copy/'index.json').write_text(json.dumps(index))
   with self.assertRaisesRegex(ValueError,'Immutable original index'):audit.audit(copy)
 def test_changed_po_capsule_manifest_receipts_statuses_and_index_cannot_be_resealed(self):
  with tempfile.TemporaryDirectory() as temporary:
   copy=Path(temporary)/'proof';shutil.copytree(EVIDENCE,copy,ignore=shutil.ignore_patterns('.native-qml-*'));capsule=copy/'sources/language/source.tar.xz'
   with tarfile.open(capsule,'r:xz') as source:files={member.name:source.extractfile(member).read() for member in source.getmembers()}
   po='poqm/pt/gcompris_qt.po';files[po]+=b'\n# forged historical catalogue\n';digest=hashlib.sha256(files[po]).hexdigest()
   with tarfile.open(capsule,'w:xz') as target:
    for name,raw in files.items():entry=tarfile.TarInfo(name);entry.size=len(raw);target.addfile(entry,io.BytesIO(raw))
   manifest=copy/'sources/language/source-manifest.json';data=json.loads(manifest.read_text());data['files'][po]=digest;manifest.write_text(json.dumps(data))
   index=json.loads((copy/'index.json').read_text())
   for name,description in index['cases'].items():
    if description['phase']!='language':continue
    receipt=copy/'native'/name/'result.json';data=json.loads(receipt.read_text());data['portuguese_catalogue_sha256']=digest;receipt.write_text(json.dumps(data));receipt_digest=hashlib.sha256(receipt.read_bytes()).hexdigest()
    for filename in ['launcher-status.json','tool-status.json']:
     status=receipt.parent/filename;data=json.loads(status.read_text());data['native_receipt_sha256']=receipt_digest;status.write_text(json.dumps(data))
   index['files']={name:hashlib.sha256((copy/name).read_bytes()).hexdigest() for name in index['files']};(copy/'index.json').write_text(json.dumps(index))
   with self.assertRaisesRegex(ValueError,'Immutable original index'):audit.audit(copy)
 def test_empty_case_set_is_rejected_independently_of_index_anchor(self):
  with tempfile.TemporaryDirectory() as temporary:
   copy=Path(temporary);index=json.loads((EVIDENCE/'index.json').read_text());index['cases']={};raw=json.dumps(index).encode();(copy/'index.json').write_bytes(raw)
   with patch.object(audit,'EXPECTED_INDEX_SHA256',hashlib.sha256(raw).hexdigest()):
    with self.assertRaisesRegex(ValueError,'Nonempty exact historical case set'):audit.audit(copy)
if __name__=='__main__':unittest.main()
