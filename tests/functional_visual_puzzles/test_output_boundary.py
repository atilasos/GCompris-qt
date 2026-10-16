# SPDX-License-Identifier: GPL-3.0-or-later
"""An occupied output must be rejected before preparation or native launch."""
import contextlib,importlib.util,io,sys,tempfile,unittest
from pathlib import Path
from unittest.mock import patch
QA=Path(__file__).resolve().parent
sys.path.insert(0,str(QA))
def module(name):
 spec=importlib.util.spec_from_file_location('visual_boundary_'+name,QA/(name+'.py'));result=importlib.util.module_from_spec(spec);spec.loader.exec_module(result);return result

class OutputBoundary(unittest.TestCase):
 def check_occupied(self,entry,occupied):
  target=module(entry)
  with tempfile.TemporaryDirectory() as folder:
   root=Path(folder);case=root/'case.qml';case.write_text('TestCase {}');output=root/'output';log=root/'output.log';path=log if occupied=='dangling-log' else output
   if occupied.startswith('dangling'):path.symlink_to(root/'missing-target')
   elif occupied=='directory':path.mkdir();(path/'sentinel').write_bytes(b'preserve')
   else:path.write_bytes(b'preserve')
   before=sorted(str(p.relative_to(root)) for p in root.iterdir());args=[entry+'.py','--case',str(case),'--output',str(output)]
   if entry=='run':args+=['--revision','unused','--activity','details']
   with contextlib.ExitStack() as stack:
    stack.enter_context(patch.object(sys,'argv',args));launch=stack.enter_context(patch.object(target.subprocess,'run',side_effect=AssertionError('Native launch must not be attempted')))
    prepare=stack.enter_context(patch.object(target,'freeze',side_effect=AssertionError('Source preparation must not be attempted'))) if entry=='run' else None
    stack.enter_context(contextlib.redirect_stderr(io.StringIO()))
    with self.assertRaises(SystemExit) as error:target.main()
    self.assertEqual(error.exception.code,2);launch.assert_not_called()
    if prepare is not None:prepare.assert_not_called()
   self.assertEqual(sorted(str(p.relative_to(root)) for p in root.iterdir()),before)
   if occupied.startswith('dangling'):self.assertTrue(path.is_symlink());self.assertEqual(path.readlink(),root/'missing-target')
   elif occupied=='directory':self.assertEqual((path/'sentinel').read_bytes(),b'preserve')
   else:self.assertEqual(path.read_bytes(),b'preserve')
 def test_runner_occupied_output(self):
  for occupied in ['dangling-output','dangling-log','directory','file']:
   with self.subTest(occupied=occupied):self.check_occupied('run',occupied)
 def test_capture_occupied_output(self):
  for occupied in ['dangling-output','directory','file']:
   with self.subTest(occupied=occupied):self.check_occupied('capture',occupied)
if __name__=='__main__':unittest.main()
