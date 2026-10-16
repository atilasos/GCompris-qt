# SPDX-License-Identifier: GPL-3.0-or-later
import json,re,shutil,tempfile,unittest
from pathlib import Path
from guard import ROOT,violations
class StartupPublication(unittest.TestCase):
 def test_repaired_sources_reject_the_original_pattern(self):
  self.assertEqual(violations(ROOT),[])
  inventory=json.loads((ROOT/'tests/public_levels/inventory.json').read_text())
  with tempfile.TemporaryDirectory() as temporary:
   target=Path(temporary)
   for _,relative,_ in inventory:
    src=ROOT/'src/activities'/relative;dst=target/'src/activities'/relative;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(src,dst)
    for script in src.parent.glob('*.js'):shutil.copyfile(script,dst.parent/script.name)
   p=target/'src/activities/submarine/Submarine.qml';text=p.read_text();text=re.sub(r'activity\.numberOfLevel = items.numberOfLevel;','',text);p.write_text(text)
   self.assertEqual(violations(target),['submarine/Submarine.qml'])
 def test_private_counts_cannot_lose_their_initial_publication(self):
  inventory=json.loads((ROOT/'tests/public_levels/inventory.json').read_text())
  with tempfile.TemporaryDirectory() as temporary:
   target=Path(temporary)
   for _,relative,_ in inventory:
    src=ROOT/'src/activities'/relative;dst=target/'src/activities'/relative;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(src,dst)
    for script in src.parent.glob('*.js'):shutil.copyfile(script,dst.parent/script.name)
   for name,expression in [('leftright','levels.length'),('superbrain','maxLevel'),('traffic','maxLevel')]:
    p=target/'src/activities'/name/(name+'.js');text=p.read_text();p.write_text(text.replace('items.numberOfLevel = '+expression,''))
   self.assertEqual(violations(target),['leftright/Leftright.qml','superbrain/Superbrain.qml','traffic/Traffic.qml'])
if __name__=='__main__':unittest.main()
