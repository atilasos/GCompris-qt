# SPDX-License-Identifier: GPL-3.0-or-later
import subprocess,sys,tempfile,unittest
from pathlib import Path
HERE=Path(__file__).resolve().parent
class CreationOutputBoundary(unittest.TestCase):
 def test_existing_output_is_untouched_before_source_read(self):
  with tempfile.TemporaryDirectory() as d:
   p=Path(d);sentinel=p/'tool-exit.json';sentinel.write_bytes(b'original')
   args=['--source-root',str(p/'missing'),'--snapshot',str(p/'missing'),'--activity','sketch','--exact-case',str(p/'missing'),'--output',str(p)]
   result=subprocess.run([sys.executable,str(HERE/'run.py'),*args],capture_output=True)
   self.assertEqual(result.returncode,2);self.assertIn(b'new output',result.stderr);self.assertEqual(sentinel.read_bytes(),b'original');self.assertEqual(list(p.iterdir()),[sentinel])
 def test_optimized_runner_rejected(self):
  result=subprocess.run([sys.executable,'-O',str(HERE/'run.py'),'--help'],capture_output=True)
  self.assertNotEqual(result.returncode,0);self.assertIn(b'-O',result.stderr)

class FutureCreationOutputRoots(unittest.TestCase):
 def command(self,name,output):
  missing=str(output.parent/'missing-source')
  if name=='run.py':args=['--source-root',missing,'--snapshot',missing,'--activity','sketch','--exact-case',missing]
  elif name=='capture_resources.py':args=['--source',missing,'--snapshot',missing]
  else:args=[]
  return [sys.executable,str(HERE/name),*args,'--output',str(output)]
 def test_dangling_symlink_is_rejected_before_resolving_output(self):
  with tempfile.TemporaryDirectory() as directory:
   root=Path(directory)
   for name in ['run.py','capture_resources.py','seal.py']:
    with self.subTest(tool=name):
     target=root/(name+'-absent');output=root/(name+'-link');output.symlink_to(target)
     before={p.name:p.readlink() if p.is_symlink() else p.read_bytes() for p in root.iterdir()}
     result=subprocess.run(self.command(name,output),capture_output=True)
     self.assertEqual(result.returncode,2,result.stderr.decode());self.assertIn(b'new output',result.stderr.lower());self.assertTrue(output.is_symlink());self.assertFalse(target.exists())
     after={p.name:p.readlink() if p.is_symlink() else p.read_bytes() for p in root.iterdir()};self.assertEqual(after,before)
 def test_each_existing_output_directory_and_bytes_are_untouched(self):
  with tempfile.TemporaryDirectory() as directory:
   root=Path(directory)
   for name in ['run.py','capture_resources.py','seal.py']:
    with self.subTest(tool=name):
     output=root/name;output.mkdir();sentinel=output/'tool-exit.json';sentinel.write_bytes(b'original status')
     result=subprocess.run(self.command(name,output),capture_output=True)
     self.assertEqual(result.returncode,2,result.stderr.decode());self.assertEqual(sentinel.read_bytes(),b'original status');self.assertEqual(list(output.iterdir()),[sentinel])
 def test_each_existing_file_output_is_untouched(self):
  with tempfile.TemporaryDirectory() as directory:
   root=Path(directory)
   for name in ['run.py','capture_resources.py','seal.py']:
    with self.subTest(tool=name):
     output=root/name;output.write_bytes(b'original file')
     result=subprocess.run(self.command(name,output),capture_output=True)
     self.assertEqual(result.returncode,2,result.stderr.decode());self.assertEqual(output.read_bytes(),b'original file')

if __name__=='__main__':unittest.main()
