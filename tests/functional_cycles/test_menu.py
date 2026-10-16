# SPDX-License-Identifier: GPL-3.0-or-later
import copy,hashlib,json,shutil,tempfile,unittest
from pathlib import Path
from audit_menu import audit,check_menu
ROOT=Path(__file__).resolve().parents[2]
class PostSuccessMenu(unittest.TestCase):
 def test_three_actual_post_success_menus(self):self.assertEqual(audit(ROOT/'.scratch/pt-pt/functional-cycles-menu',ROOT/'.scratch/pt-pt/functional-cycles')['menus_after_success'],3)
 def test_visible_menu_required(self):
  evidence=json.loads((ROOT/'.scratch/pt-pt/functional-cycles-menu/water/result.json').read_text())['case_result']['evidence'];check_menu(evidence);broken=copy.deepcopy(evidence);broken['menuAfterSuccess']['isMenu']=False
  with self.assertRaises(ValueError):check_menu(broken)
 def test_transition_must_have_completed(self):
  evidence={'menuAfterSuccess':{'isMenu':True,'depth':1,'busy':True,'timestamp':1}}
  with self.assertRaises(ValueError):check_menu(evidence)
 def test_resealed_false_menu_refused(self):
  primary=ROOT/'.scratch/pt-pt/functional-cycles';original=ROOT/'.scratch/pt-pt/functional-cycles-menu'
  with tempfile.TemporaryDirectory() as tmp:
   target=Path(tmp);index=json.loads((original/'index.json').read_text())
   for relative in ['index.json',*index['files']]:
    path=target/relative;path.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(original/relative,path)
   receipt=target/'water/result.json';data=json.loads(receipt.read_text());data['case_result']['evidence']['menuAfterSuccess']['isMenu']=False;receipt.write_text(json.dumps(data));digest=hashlib.sha256(receipt.read_bytes()).hexdigest()
   for name in ['launcher-status.json','tool-status.json']:
    path=target/'water'/name;status=json.loads(path.read_text());status['native_receipt_sha256']=digest
    if name=='tool-status.json':status['launcher_status_sha256']=hashlib.sha256((target/'water/launcher-status.json').read_bytes()).hexdigest()
    path.write_text(json.dumps(status))
   for relative in index['files']:index['files'][relative]=hashlib.sha256((target/relative).read_bytes()).hexdigest()
   (target/'index.json').write_text(json.dumps(index))
   with self.assertRaisesRegex(ValueError,'Immutable supplement index'):audit(target,primary)
if __name__=='__main__':unittest.main()
