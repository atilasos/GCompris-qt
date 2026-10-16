# SPDX-License-Identifier: GPL-3.0-or-later
"""Reject evidence tampering even when its outer seal is recalculated."""
import hashlib,io,json,shutil,subprocess,tarfile,tempfile,unittest
from pathlib import Path
from audit import audit
ROOT=Path(__file__).resolve().parents[2];BASE=ROOT/'.scratch/pt-pt/public-level-contracts/archive'
def reseal(base):
 files={str(p.relative_to(base)):hashlib.sha256(p.read_bytes()).hexdigest() for p in base.rglob('*') if p.is_file() and p.name!='sealed.json'}
 (base/'sealed.json').write_text(json.dumps(files))
def coherent_catalogue_replacement(base):
 capsule=base/'green-sources.tar.xz'
 with tarfile.open(capsule,'r:xz') as archive:
  files={entry.name:archive.extractfile(entry).read() for entry in archive.getmembers()}
 po='poqm/pt/gcompris_qt.po';files[po]+=b'\n# fabricated post-campaign catalogue\n'
 newhash=hashlib.sha256(files[po]).hexdigest()
 with tarfile.open(capsule,'w:xz') as archive:
  for name,raw in files.items():
   entry=tarfile.TarInfo(name);entry.size=len(raw);archive.addfile(entry,io.BytesIO(raw))
 index=base/'evidence.json';evidence=json.loads(index.read_text());evidence['sources']['green'][po]=newhash;index.write_text(json.dumps(evidence))
 folders=[base/'runs'/name for name,record in evidence['runs'].items() if record['phase']=='green']+list((base/'exclusions').iterdir())
 for folder in folders:
  receipt=folder/'result.json';native=json.loads(receipt.read_text());native['portuguese_catalogue_sha256']=newhash;receipt.write_text(json.dumps(native))
  for name in ['launcher-status.json','tool-status.json']:
   status=folder/name;value=json.loads(status.read_text());value['native_receipt_sha256']=hashlib.sha256(receipt.read_bytes()).hexdigest();status.write_text(json.dumps(value))
 reseal(base)

class Evidence(unittest.TestCase):
 def test_physical_archive(self):self.assertEqual(audit(BASE)['identical_red_green_pairs'],24)
 def test_recomputed_seal_does_not_hide_corruption(self):
  for kind in ['receipt','source','resource','case','screenshot','return','empty']:
   with self.subTest(kind=kind),tempfile.TemporaryDirectory() as tmp:
    base=Path(tmp)/'evidence';shutil.copytree(BASE,base)
    if kind=='receipt':
     p=base/'runs/leftright-green/result.json';x=json.loads(p.read_text());x['case_result']['evidence']['total']=0;p.write_text(json.dumps(x))
    elif kind=='source':
     p=base/'green-sources.tar.xz';p.write_bytes(p.read_bytes()[:-100])
    elif kind=='resource':
     index=json.loads((base/'evidence.json').read_text());p=base/'blobs'/index['runs']['leftright-green']['rcc'];p.write_bytes(p.read_bytes()+b'tampered')
    elif kind=='case':
     p=base/'runs/leftright-green/case.qml';p.write_text(p.read_text().replace('expectedTotal: 6','expectedTotal: 0'))
    elif kind=='screenshot':
     p=base/'runs/leftright-green/initial.png';p.write_bytes(b'empty')
    elif kind=='return':
     p=base/'runs/leftright-red/tool-status.json';x=json.loads(p.read_text());x['exit_code']=0;p.write_text(json.dumps(x))
    else:
     p=base/'evidence.json';x=json.loads(p.read_text());x['runs']={};p.write_text(json.dumps(x))
    reseal(base)
    try:audit(base)
    except (ValueError,EOFError,KeyError):pass
    else:self.fail('Tamper accepted: '+kind)
 def test_coherent_catalogue_replacement_cannot_reseal_history(self):
  with tempfile.TemporaryDirectory() as temporary:
   base=Path(temporary)/'evidence';shutil.copytree(BASE,base)
   coherent_catalogue_replacement(base)
   with self.assertRaisesRegex(ValueError,'Historical archive index'):
    audit(base)
if __name__=='__main__':unittest.main()
