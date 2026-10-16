# SPDX-License-Identifier: GPL-3.0-or-later
import json,os,shutil,subprocess,sys,tempfile,unittest
from pathlib import Path
from review_audit import Capture,audit,check_wheel,compare_preserved,compare_undo_redo,load_wheel
HERE=Path(__file__).resolve().parent
CAPSULE=HERE.parents[1]/'.scratch/pt-pt/functional-creation/portable-capsule'
class HistoricalCreationImages(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  capture=Capture(CAPSULE)
  try:cls.wheel=load_wheel(capture,1)
  finally:capture.close()
 def white(self):
  width,height=self.wheel['physical_png'][:2];return (width,height,b'\xff'*(width*height*3))
 def test_saved_png_reopen_undo_redo_and_cancel(self):
  result=audit(CAPSULE);self.assertEqual(len(result['wheels']),2);self.assertEqual(len(result['preserved']),3);self.assertEqual(len(result['saved_png_files']),10)
 def test_wrong_png_even_with_matching_saved_scene_is_rejected(self):
  observation=dict(self.wheel,frames=dict(self.wheel['frames']));observation['physical_png']=self.white();observation['frames']['saved']=self.white()
  with self.assertRaisesRegex(ValueError,'nonempty saved drawing'):check_wheel(observation)
 def test_empty_or_wrong_reopened_drawing_is_rejected(self):
  for reopened in [self.white(),self.wheel['frames']['undo']]:
   observation=dict(self.wheel,frames=dict(self.wheel['frames']));observation['frames']['opened']=reopened
   with self.subTest(reopened=reopened is self.wheel['frames']['undo']):
    with self.assertRaises(ValueError):check_wheel(observation)
 def test_ineffective_redo_is_rejected(self):
  frames=self.wheel['frames']
  with self.assertRaisesRegex(ValueError,'Redo'):compare_undo_redo(frames['completed'],frames['undo'],frames['undo'])
 def test_ineffective_undo_is_rejected(self):
  frames=self.wheel['frames']
  with self.assertRaisesRegex(ValueError,'Undo'):compare_undo_redo(frames['completed'],frames['completed'],frames['redo'])
 def test_cancel_that_loses_work_is_rejected(self):
  with self.assertRaisesRegex(ValueError,'Cancelled operation'):compare_preserved(self.wheel['frames']['saved'],self.white())
 def test_altered_capture_identity_is_rejected(self):
  with tempfile.TemporaryDirectory() as directory:
   root=Path(directory);capture=json.loads((CAPSULE/'capture.json').read_text());capture['cases']['wheels-levels-v4']['saved_after_wait'][0]['sha256']='0'*64;(root/'capture.json').write_text(json.dumps(capture))
   with self.assertRaisesRegex(ValueError,'literal anchor'):Capture(root)
 def test_isolated_copy_without_git_qt_or_checkout(self):
  with tempfile.TemporaryDirectory() as directory:
   root=Path(directory);capsule=root/'capsule';shutil.copytree(CAPSULE,capsule)
   for name in ['review_audit.py','pixels.py','curves.py']:shutil.copyfile(HERE/name,root/name)
   result=subprocess.run([sys.executable,str(root/'review_audit.py'),'--capsule',str(capsule)],cwd=root,env=dict(os.environ,PATH='',PYTHONDONTWRITEBYTECODE='1'),capture_output=True,text=True)
   self.assertEqual(result.returncode,0,result.stderr);self.assertEqual(json.loads(result.stdout)['new_native_runs'],0)
 def test_optimized_audit_is_explicitly_rejected(self):
  result=subprocess.run([sys.executable,'-O',str(HERE/'review_audit.py'),'--capsule',str(CAPSULE)],capture_output=True)
  self.assertNotEqual(result.returncode,0);self.assertIn(b'rejects Python -O',result.stderr)
if __name__=='__main__':unittest.main()
