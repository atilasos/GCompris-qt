# SPDX-License-Identifier: GPL-3.0-or-later
import os,subprocess,sys,tempfile,unittest,hashlib,json
from pathlib import Path
CLI=Path(__file__).with_name('prepare.py')
class FrozenInputBoundary(unittest.TestCase):
 def test_missing_frozen_source_is_rejected_before_publishing_snapshot(self):
  with tempfile.TemporaryDirectory() as temp:
   root=Path(temp);output=root/'must not exist';origin=root/'valid tiny snapshot';files={}
   for name in ['bin/gcompris-qt','share/gcompris-qt/rcc/core.rcc','share/gcompris-qt/rcc/fifteen.rcc','share/gcompris-qt/rcc/sixteen.rcc']:
    path=origin/name;path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(b'tiny fixture');files[name]=hashlib.sha256(path.read_bytes()).hexdigest()
   (origin/'manifest.json').write_text(json.dumps({'version':1,'files':files,'directories':sorted(path.relative_to(origin).as_posix() for path in origin.rglob('*') if path.is_dir())}))
   result=subprocess.run([sys.executable,str(CLI),'--source-root',str(root/'missing'),'--origin-snapshot',str(origin),'--output',str(output)],capture_output=True,text=True,env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1'));self.assertNotEqual(result.returncode,0);self.assertIn('source-manifest.json',result.stderr);self.assertFalse(output.exists())
