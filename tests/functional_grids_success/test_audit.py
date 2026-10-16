import hashlib,json,shutil,subprocess,sys,tempfile,unittest,zipfile
from pathlib import Path
HERE=Path(__file__).resolve().parent
BASE=HERE.parents[1]/'.scratch/pt-pt/functional-grids-success/capsule'
class SuccessMenu(unittest.TestCase):
 def setUp(self):
  self.temp=tempfile.TemporaryDirectory();self.addCleanup(self.temp.cleanup);self.root=Path(self.temp.name);self.caps=self.root/'capsule';shutil.copytree(BASE,self.caps)
  for file in ['audit.py','oracle.py']:shutil.copyfile(HERE/file,self.root/file)
 def run_audit(self,opt=False):return subprocess.run([sys.executable,*(['-O'] if opt else []),str(self.root/'audit.py'),'--capsule',str(self.caps)],capture_output=True,text=True,cwd=self.root)
 def test_physical_copy_success(self):
  r=self.run_audit();self.assertEqual(r.returncode,0,r.stderr);self.assertEqual(json.loads(r.stdout)['boards_repeated'],25)
 def test_corrupt_physical_bytes(self):
  z=self.caps/'objects.zip'
  with zipfile.ZipFile(z) as f:objects={n:f.read(n) for n in f.namelist()}
  for n in objects:
   if objects[n].startswith(b'qres'):objects[n]+=b'forged';break
  with zipfile.ZipFile(z,'w') as f:
   for n,raw in objects.items():f.writestr(n,raw)
  self.assertNotEqual(self.run_audit().returncode,0)
 def test_coherent_reseal_rejected(self):
  p=self.caps/'capture.json';v=json.loads(p.read_text());v['menu_after_success']=False;p.write_text(json.dumps(v));self.assertNotEqual(self.run_audit().returncode,0)
 def test_coherent_false_menu_receipt_and_statuses_resealed_rejected(self):
  path=self.caps/'capture.json';capture=json.loads(path.read_text())
  with zipfile.ZipFile(self.caps/'objects.zip') as z:objects={s:z.read('objects/'+s) for s in capture['objects']}
  def replace(name,value):
   raw=json.dumps(value).encode();digest=hashlib.sha256(raw).hexdigest();objects[digest]=raw;capture['files'][name]=digest;return digest
  pre='cases/sudoku/';r=json.loads(objects[capture['files'][pre+'result.json']]);r['case_result']['evidence']['menu']['isMenu']=False;receipt=replace(pre+'result.json',r)
  s=json.loads(objects[capture['files'][pre+'launcher-status.json']]);s['native_receipt_sha256']=receipt;status=replace(pre+'launcher-status.json',s)
  for n in ['supervisor-exit.json','tool-exit.json']:
   v=json.loads(objects[capture['files'][pre+n]]);v['native_receipt_sha256']=receipt;v['launcher_status_sha256']=status;replace(pre+n,v)
  required=set(capture['files'].values())|set(capture['phase']['source']['files'].values())|{capture['phase']['snapshot_manifest']}
  for r in capture['phase']['canonical'].values():required.add(r['rcc_sha256']);required.update(row['sha256'] for row in r['files'])
  capture['objects']=sorted(required);path.write_text(json.dumps(capture,indent=2)+'\n')
  with zipfile.ZipFile(self.caps/'objects.zip','w') as z:
   for s in required:z.writestr('objects/'+s,objects[s])
  r=self.run_audit();self.assertNotEqual(r.returncode,0);self.assertIn('Immutable success capsule changed',r.stderr)
 def test_physical_qm_and_extraction_tampering(self):
  for artifact in ['resources/gcompris_qt_pt.qm','resources/extracted/gcompris/src/activities/sudoku/Sudoku.qml']:
   with self.subTest(artifact=artifact):
    capture=json.loads((self.caps/'capture.json').read_text());digest=capture['files']['cases/sudoku/'+artifact];zpath=self.caps/'objects.zip'
    with zipfile.ZipFile(BASE/'objects.zip') as z:objects={n:z.read(n) for n in z.namelist()}
    objects['objects/'+digest]+=b'forged'
    with zipfile.ZipFile(zpath,'w') as z:
     for n,raw in objects.items():z.writestr(n,raw)
    self.assertNotEqual(self.run_audit().returncode,0)
 def test_optimized_refused(self):
  r=self.run_audit(True);self.assertNotEqual(r.returncode,0);self.assertIn('assertions',r.stderr)
if __name__=='__main__':unittest.main()
