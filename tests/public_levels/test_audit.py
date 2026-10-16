# SPDX-License-Identifier: GPL-3.0-or-later
"""Reject evidence tampering even when its outer seal is recalculated."""
import hashlib,json,shutil,subprocess,tempfile,unittest
from pathlib import Path
from audit import audit
ROOT=Path(__file__).resolve().parents[2];BASE=ROOT/'.scratch/pt-pt/public-level-contracts/archive'
def reseal(base):
 files={str(p.relative_to(base)):hashlib.sha256(p.read_bytes()).hexdigest() for p in base.rglob('*') if p.is_file() and p.name!='sealed.json'}
 (base/'sealed.json').write_text(json.dumps(files))
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
if __name__=='__main__':unittest.main()
