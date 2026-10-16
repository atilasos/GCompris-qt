# SPDX-License-Identifier: GPL-3.0-or-later
"""Exercise immutable physical evidence boundaries, independent of the checkout."""
import hashlib,io,json,os,shutil,subprocess,sys,tempfile,unittest,zipfile
from pathlib import Path
from audit import audit,CAPTURE_SHA
HERE=Path(__file__).resolve().parent
CAPSULE=HERE.parents[1]/'.scratch/pt-pt/functional-creation/portable-capsule'
def sha(raw):return hashlib.sha256(raw).hexdigest()
class CreationAudit(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  cls.capture=json.loads((CAPSULE/'capture.json').read_text());cls.raw=b''.join(p.read_bytes() for p in sorted(CAPSULE.glob('objects.zip.*')))
 def capsule(self,d,raw=None,capture=None):
  p=Path(d)/'capsule';p.mkdir();(p/'capture.json').write_bytes(capture if capture is not None else (CAPSULE/'capture.json').read_bytes());(p/'objects.zip').write_bytes(self.raw if raw is None else raw);return p
 def test_original_valid_from_isolated_copy_without_git_or_qt(self):
  with tempfile.TemporaryDirectory() as d:
   p=self.capsule(d)
   for name in ['audit.py','pixels.py','curves.py']:shutil.copyfile(HERE/name,Path(d)/name)
   result=subprocess.run([sys.executable,str(Path(d)/'audit.py'),'--capsule',str(p)],cwd=d,env=dict(os.environ,PATH='',PYTHONDONTWRITEBYTECODE='1'),capture_output=True,text=True)
   self.assertEqual(result.returncode,0,result.stderr);self.assertEqual(json.loads(result.stdout)['simplepaint_levels'],31)
 def test_physical_rcc_qm_extraction_scene_and_svg_tampering_rejected(self):
  files=self.capture['files'];targets=[next(p for p in files if p.endswith('/resources/sketch.rcc')),next(p for p in files if p.endswith('/resources/gcompris_qt_pt.qm')),next(p for p in files if '/resources/extracted/' in p and p.endswith('Sketch.qml')),next(p for p in files if p.endswith('/route-0-after.png'))]
  vectors=next(v['sha256'] for v in self.capture['cases']['wheels-levels-v4']['saved_after_wait'] if v['name']=='RODAS1.svg');digests=[files[p] for p in targets]+[vectors]
  with zipfile.ZipFile(io.BytesIO(self.raw)) as archive:
   for digest in digests:
    with self.subTest(digest=digest),tempfile.TemporaryDirectory() as d:
     info=archive.getinfo('objects/'+digest);offset=info.header_offset+30+len(info.filename.encode())+len(info.extra);bad=bytearray(self.raw);bad[offset]^=1
     with self.assertRaisesRegex(AssertionError,'Physical archive'):audit(self.capsule(d,bytes(bad)))
 def test_coherent_reseal_cannot_replace_literal_external_anchor(self):
  with zipfile.ZipFile(io.BytesIO(self.raw)) as archive:objects={p[8:]:archive.read(p) for p in archive.namelist()}
  replacements={};new={}
  # Change catalogue and physical QM bytes, then propagate content identities
  # through source manifests, receipts, launcher/supervisor/tool states and seal.
  for digest,raw in objects.items():
   if b'msgstr "Paleta de cores"' in raw:changed=raw.replace(b'msgstr "Paleta de cores"',b'msgstr "PALAVRA ADULTERADA"')
   elif raw.startswith(bytes.fromhex('3cb86418caef9c95cd211cbf60a1bddd')):changed=raw+b'coherent attack'
   else:continue
   replacements[digest]=sha(changed);new[replacements[digest]]=changed
  self.assertTrue(replacements)
  bases=set(replacements)
  for iteration in range(20):
   updated=False
   for digest,raw in objects.items():
    if digest in bases:continue
    if raw.startswith(b'{'):
     changed=raw
     for before,after in replacements.copy().items():changed=changed.replace(before.encode(),after.encode())
     if changed!=raw and replacements.get(digest)!=sha(changed):replacements[digest]=sha(changed);new[replacements[digest]]=changed;updated=True
   if not updated:break
  def replace(v):
   if isinstance(v,str):return replacements.get(v,v)
   if isinstance(v,list):return [replace(x) for x in v]
   if isinstance(v,dict):return {replacements.get(k,k):replace(x) for k,x in v.items()}
   return v
  capture=replace(self.capture);capture['objects']=sorted(replacements.get(d,d) for d in objects);stream=io.BytesIO()
  with zipfile.ZipFile(stream,'w',zipfile.ZIP_DEFLATED) as archive:
   for digest,raw in objects.items():target=replacements.get(digest,digest);archive.writestr('objects/'+target,new.get(target,raw))
  capture_raw=(json.dumps(capture,indent=2)+'\n').encode();self.assertNotEqual(sha(capture_raw),CAPTURE_SHA)
  with tempfile.TemporaryDirectory() as d:
   with self.assertRaisesRegex(AssertionError,'Immutable creation anchor'):audit(self.capsule(d,stream.getvalue(),capture_raw))
 def test_empty_coverage_and_changed_path_rejected(self):
  for field in ['cases','files']:
   capture=dict(self.capture);capture[field]={}
   with self.subTest(field=field),tempfile.TemporaryDirectory() as d:
    with self.assertRaisesRegex(AssertionError,'Immutable creation anchor'):audit(self.capsule(d,capture=json.dumps(capture).encode()))
 def test_changed_resource_path_is_rejected(self):
  capture=json.loads(json.dumps(self.capture));key=next(k for k in capture['files'] if '/resources/extracted/' in k);capture['files'][key.replace('/extracted/','/forged/')]=capture['files'].pop(key)
  with tempfile.TemporaryDirectory() as d:
   with self.assertRaisesRegex(AssertionError,'Immutable creation anchor'):audit(self.capsule(d,capture=json.dumps(capture).encode()))
 def test_optimized_audit_is_explicitly_rejected(self):
  result=subprocess.run([sys.executable,'-O',str(HERE/'audit.py'),'--capsule',str(CAPSULE)],capture_output=True)
  self.assertNotEqual(result.returncode,0);self.assertIn(b'rejects Python -O',result.stderr)
if __name__=='__main__':unittest.main()
