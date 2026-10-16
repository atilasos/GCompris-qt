# SPDX-License-Identifier: GPL-3.0-or-later
"""Adversarial copies, never mutations of accepted native observations."""
import hashlib,io,json,shutil,tarfile,tempfile,unittest
from pathlib import Path
from unittest.mock import patch
import audit,audit_supplement,audit_all
BASE=Path(__file__).resolve().parents[2]/'.scratch/pt-pt/functional-exploration'
def write(path,value):path.write_text(json.dumps(value,ensure_ascii=False,indent=2)+'\n')
def reseal(root):
 write(root/'sealed.json',{str(p.relative_to(root)):audit.digest(p.read_bytes()) for p in sorted(root.rglob('*')) if p.is_file() and p.name!='sealed.json'})
 return audit.digest((root/'sealed.json').read_bytes())
def forge_catalogue(root):
 """Recalculate every dependent tar, source index, native receipt and return hash."""
 evidence=audit.data(root/'evidence.json');phase='reviewed';files=audit.unpack(root/'sources'/f'{phase}.tar.xz');key='poqm/pt/gcompris_qt.po';files[key]+=b'\n# coherent malicious replacement\n';new=audit.digest(files[key]);evidence['sources'][phase][key]=new
 with tarfile.open(root/'sources'/f'{phase}.tar.xz','w:xz') as tar:
  for name,raw in sorted(files.items()):
   member=tarfile.TarInfo(name);member.size=len(raw);tar.addfile(member,io.BytesIO(raw))
 for name,row in evidence['runs'].items():
  if row['phase']!=phase:continue
  folder=root/'runs'/name;native=audit.data(folder/'result.json');native['portuguese_catalogue_sha256']=new;write(folder/'result.json',native)
  for filename in ['launcher-status.json','supervisor-status.json','tool-status.json']:
   status=audit.data(folder/filename);status['native_receipt_sha256']=audit.digest((folder/'result.json').read_bytes());write(folder/filename,status)
 write(root/'evidence.json',evidence);return reseal(root)
class HistoricalProof(unittest.TestCase):
 def test_full_composed_evidence(self):
  result=audit_all.audit_all(BASE);self.assertEqual(result['questions'],116);self.assertEqual(result['supplemental_presentations'],6)
 def test_coherent_catalogue_reseal_needs_external_anchor(self):
  with tempfile.TemporaryDirectory() as tmp:
   root=Path(tmp)/'archive';shutil.copytree(BASE/'archive',root);new_anchor=forge_catalogue(root)
   with self.assertRaisesRegex(ValueError,'external anchor'):audit.audit(root)
   # This proves the attack was coherent internally, rather than a broken fixture.
   with patch.object(audit,'HISTORICAL_INDEX_SHA256',new_anchor):self.assertEqual(audit.audit(root)['questions'],116)
 def test_empty_campaign_rejected_even_with_trusted_reseal(self):
  with tempfile.TemporaryDirectory() as tmp:
   root=Path(tmp)/'archive';shutil.copytree(BASE/'archive',root);evidence=audit.data(root/'evidence.json');evidence['runs']={};write(root/'evidence.json',evidence);anchor=reseal(root)
   with patch.object(audit,'HISTORICAL_INDEX_SHA256',anchor):
    with self.assertRaisesRegex(ValueError,'Twenty selected native runs'):audit.audit(root)
 def test_supplement_reseal_rejected(self):
  with tempfile.TemporaryDirectory() as tmp:
   root=Path(tmp)/'supplement';shutil.copytree(BASE/'supplement-archive',root);rows=audit.data(root/'review.json');rows[0]['new']='adulterado';write(root/'review.json',rows);reseal(root)
   with self.assertRaisesRegex(ValueError,'external anchor'):audit_supplement.verify(root,BASE/'archive')
if __name__=='__main__':unittest.main()
