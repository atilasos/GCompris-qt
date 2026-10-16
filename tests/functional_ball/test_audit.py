# SPDX-License-Identifier: GPL-3.0-or-later
"""Physical, immutable ball evidence; no original paths or optimized-away checks."""
import hashlib,io,json,shutil,subprocess,sys,tarfile,tempfile,unittest
from pathlib import Path
from unittest.mock import patch
import audit
ROOT=Path(__file__).resolve().parents[2]
EVIDENCE=ROOT/'.scratch/pt-pt/functional-ball'
def copy_proof(target):shutil.copytree(EVIDENCE,target,ignore=shutil.ignore_patterns('.native-qml-*','snapshot'))
class PhysicalAudit(unittest.TestCase):
 def test_original_passes_normal_and_optimized_with_shutdown_diagnostic_explicit(self):
  for optimized in [[],['-O']]:
   run=subprocess.run([sys.executable,*optimized,str(ROOT/'tests/functional_ball/audit.py'),'--evidence',str(EVIDENCE)],capture_output=True,text=True);self.assertEqual(run.returncode,0,run.stderr);d=json.loads(run.stdout);self.assertEqual(d['route_levels'],27);self.assertEqual(d['historical_shutdown_failures'],1)
 def test_case_receipt_resource_source_manifest_and_index_tampering(self):
  for path in ['catch-hands/case.qml','catch-keyboard/result.json','effective/penalty-replay/activity.rcc','sources/reset/source.tar.xz','sources/reset/source-manifest.json','index.json']:
   with self.subTest(path=path),tempfile.TemporaryDirectory() as temporary:
    root=Path(temporary)/'proof';copy_proof(root);p=root/path;p.write_bytes(p.read_bytes()+b'\nforged')
    with self.assertRaises((ValueError,OSError,KeyError,TypeError)):audit.audit(root)
 def test_resealed_po_source_receipts_and_statuses_cannot_forge_history(self):
  with tempfile.TemporaryDirectory() as temporary:
   root=Path(temporary)/'proof';copy_proof(root);capsule=root/'sources/reset/source.tar.xz'
   with tarfile.open(capsule,'r:xz') as source:files={m.name:source.extractfile(m).read() for m in source.getmembers()}
   po='poqm/pt/gcompris_qt.po';files[po]+=b'\n# forged historical PO\n';digest=hashlib.sha256(files[po]).hexdigest()
   with tarfile.open(capsule,'w:xz') as target:
    for name,raw in files.items():entry=tarfile.TarInfo(name);entry.size=len(raw);target.addfile(entry,io.BytesIO(raw))
   manifest=root/'sources/reset/source-manifest.json';d=json.loads(manifest.read_text());d['files'][po]=digest;manifest.write_text(json.dumps(d));index=json.loads((root/'index.json').read_text())
   for name,description in index['cases'].items():
    if description['phase']!='reset':continue
    receipt=root/name/'result.json';d=json.loads(receipt.read_text());d['portuguese_catalogue_sha256']=digest;receipt.write_text(json.dumps(d));receipt_hash=hashlib.sha256(receipt.read_bytes()).hexdigest();status=root/name/'launcher-status.json';d=json.loads(status.read_text());d['native_receipt_sha256']=receipt_hash;status.write_text(json.dumps(d));tool=root/name/'tool-status.json';d=json.loads(tool.read_text());d['native_receipt_sha256']=receipt_hash;d['launcher_status_sha256']=hashlib.sha256(status.read_bytes()).hexdigest();tool.write_text(json.dumps(d))
   index['files']={name:hashlib.sha256((root/name).read_bytes()).hexdigest() for name in index['files']};(root/'index.json').write_text(json.dumps(index))
   with self.assertRaisesRegex(ValueError,'Immutable original index'):audit.audit(root)
 def test_empty_cases_rejected_even_if_index_anchor_is_supplied(self):
  with tempfile.TemporaryDirectory() as temporary:
   root=Path(temporary);index=json.loads((EVIDENCE/'index.json').read_text());index['cases']={};raw=json.dumps(index).encode();(root/'index.json').write_bytes(raw)
   with patch.object(audit,'EXPECTED_INDEX_SHA256',hashlib.sha256(raw).hexdigest()):
    with self.assertRaisesRegex(ValueError,'Nonempty exact historical case set'):audit.audit(root)
if __name__=='__main__':unittest.main()
