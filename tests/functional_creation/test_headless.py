import importlib.util,subprocess,sys,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
class PrivateHeadless(unittest.TestCase):
 def test_private_environment_replaces_user_display_and_forces_mesa(self):
  spec=importlib.util.spec_from_file_location('headless',ROOT/'tools/native_qml_headless.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
  actual=m.environment({'DISPLAY':':0.0','XAUTHORITY':'/run/user/session.auth','QT_QUICK_BACKEND':'software','XDG_DATA_HOME':'/private/data'})
  self.assertEqual(actual['DISPLAY'],':99');self.assertEqual(actual['LIBGL_ALWAYS_SOFTWARE'],'1');self.assertEqual(actual['QT_QPA_PLATFORM'],'offscreen');self.assertEqual(actual['XDG_DATA_HOME'],'/private/data');self.assertNotIn('XAUTHORITY',actual);self.assertNotIn('QT_QUICK_BACKEND',actual)
 def test_renderer_options_reject_missing_private_xvfb_before_setup(self):
  r=subprocess.run([sys.executable,str(ROOT/'tools/run-native-qml-case.py'),'--activity','sketch','--qml-file','absent','--case','absent','--output','absent','--renderer','opengl','--offline'],capture_output=True,text=True)
  self.assertEqual(r.returncode,2);self.assertIn('requires --offline and --xvfb',r.stderr)
if __name__=='__main__':unittest.main()
