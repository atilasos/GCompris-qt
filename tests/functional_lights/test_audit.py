# SPDX-License-Identifier: GPL-3.0-or-later
import hashlib,json,shutil,subprocess,sys,tempfile,unittest,zipfile
from pathlib import Path
from audit import HERE,ROOT,audit

def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def write(path,value):path.write_text(json.dumps(value,indent=2)+'\n')
class PreservedLightResults(unittest.TestCase):
 def setUp(self):
  self.temp=tempfile.TemporaryDirectory();self.addCleanup(self.temp.cleanup);self.copy=Path(self.temp.name)/'copied-proof';shutil.copytree(HERE,self.copy,ignore=shutil.ignore_patterns('snapshot','.native-qml-*','__pycache__'))
 def reseal(self):
  path=self.copy/'capture.json';capture=json.loads(path.read_text())
  for name in capture['files']:
   item=self.copy/name
   if item.exists():capture['files'][name]=sha(item)
  write(path,capture)
 def change_receipt(self,case,change):
  d=self.copy/case;p=d/'result.json';r=json.loads(p.read_text());change(r);write(p,r)
  p=d/'launcher-status.json';r=json.loads(p.read_text());r['native_receipt_sha256']=sha(d/'result.json');write(p,r)
  p=d/'tool-status.json';r=json.loads(p.read_text());r['native_receipt_sha256']=sha(d/'result.json');r['launcher_status_sha256']=sha(d/'launcher-status.json');write(p,r);self.reseal()
 def rejected(self):
  with self.assertRaises(AssertionError):audit(self.copy)
 def test_copy_is_independent_of_git_qt_and_old_runtime_paths(self):
  result=audit(self.copy);self.assertEqual((result['levels'],result['solver_clicks'],result['positive'],result['expected_red']),(99,1736,7,2))
  runner=Path(self.temp.name)/'standalone';runner.mkdir()
  for name in ['audit.py','oracle.py','inventory.py']:shutil.copyfile(ROOT/'tests/functional_lights'/name,runner/name)
  p=subprocess.run([sys.executable,str(runner/'audit.py'),'--evidence',str(self.copy)],cwd=runner,capture_output=True,text=True)
  self.assertEqual(p.returncode,0,p.stderr);self.assertEqual(json.loads(p.stdout)['datasets'],9)
 def test_altered_move_cannot_be_accepted_after_local_rehashes(self):
  self.change_receipt('complete',lambda r:r['case_result']['boards'][0]['moves'][0].__setitem__('cell',0));self.rejected()
 def test_empty_boards_cannot_count_as_completed_levels(self):
  self.change_receipt('complete',lambda r:r['case_result'].__setitem__('boards',[]));self.rejected()
 def test_external143_is_distinct_from_native0(self):
  p=self.copy/'complete/tool-status.json';r=json.loads(p.read_text());r['exit_code']=143;write(p,r);self.reseal();self.rejected()
 def test_changed_historical_engine_and_rebuilt_zip_are_rejected(self):
  p=self.copy/'source-tree.zip'
  with zipfile.ZipFile(p) as archive:files={name:archive.read(name) for name in archive.namelist()}
  files['baseline/src/activities/lightsoff/lightsoff.js']+=b'\n// altered history\n'
  with zipfile.ZipFile(p,'w',zipfile.ZIP_DEFLATED) as archive:
   for name,raw in files.items():archive.writestr(name,raw)
  m=self.copy/'source-manifest.json';r=json.loads(m.read_text());r['zip_sha256']=sha(p);r['files']={name:hashlib.sha256(raw).hexdigest() for name,raw in files.items()};write(m,r);self.reseal();self.rejected()
 def test_changed_effective_qt_engine_is_rejected(self):
  p=self.copy/'effective/effective-final/resources/gcompris/src/activities/lightsoff/lightsoff.js';p.write_bytes(p.read_bytes()+b'\n// changed effective input\n');self.reseal();self.rejected()
 def test_changed_saved_image_bytes_are_rejected(self):
  p=self.copy/'complete/level-1.png';data=bytearray(p.read_bytes());data[-20]^=1;p.write_bytes(data);self.reseal();self.rejected()
 def test_empty_restart_tracer_does_not_count_as_150_samples(self):
  self.change_receipt('restarts-green',lambda r:r['case_result']['evidence'].__setitem__('samples',[]));self.rejected()
 def test_optimized_python_cannot_remove_guards(self):
  p=subprocess.run([sys.executable,'-O',str(ROOT/'tests/functional_lights/audit.py'),'--evidence',str(self.copy)],capture_output=True,text=True)
  self.assertNotEqual(p.returncode,0);self.assertIn('Python -O is rejected',p.stderr)
 def test_changed_case_cannot_skip_native_levels(self):
  p=self.copy/'complete.qml';s=p.read_text();self.assertIn('targetLevels: 99',s);p.write_text(s.replace('targetLevels: 99','targetLevels: 0'));self.reseal();self.rejected()
