# SPDX-License-Identifier: GPL-3.0-or-later
"""Selection errors and launcher failures must not certify a campaign."""
import json,shutil,subprocess,sys,tempfile,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
RUN=ROOT/'tests/functional_vertical/run.py'
class CampaignCLI(unittest.TestCase):
 def test_invalid_and_empty_selections_do_not_prepare_outputs(self):
  with tempfile.TemporaryDirectory() as tmp:
   output=Path(tmp)/'new'
   for start,levels,puzzles in [(0,1,10),(13,1,10),(1,0,10),(12,2,10),(1,-1,10),(1,1,0),(1,1,11)]:
    with self.subTest(start=start,levels=levels,puzzles=puzzles):
     p=subprocess.run([sys.executable,str(RUN),'--activity','vertical_addition','--snapshot','missing','--output',str(output),'--start-level',str(start),'--levels',str(levels),'--puzzles',str(puzzles)],capture_output=True)
     self.assertNotEqual(p.returncode,0);self.assertFalse(output.exists())
 def test_existing_archive_is_preserved(self):
  with tempfile.TemporaryDirectory() as tmp:
   output=Path(tmp);(output/'case.qml').write_bytes(b'accepted case\x00');(output/'sentinel').write_bytes(b'accepted receipt')
   before={p.name:p.read_bytes() for p in output.iterdir()}
   p=subprocess.run([sys.executable,str(RUN),'--activity','vertical_addition','--snapshot','missing','--output',str(output)],capture_output=True)
   self.assertNotEqual(p.returncode,0);self.assertEqual(before,{p.name:p.read_bytes() for p in output.iterdir()})
 def test_launcher_and_native_result_must_both_succeed(self):
  with tempfile.TemporaryDirectory() as tmp:
   root=Path(tmp);suite=root/'tests/functional_vertical';suite.mkdir(parents=True);(root/'tools').mkdir()
   for name in ['run.py','gameplay.qml','oracle.qml']:shutil.copyfile(RUN.parent/name,suite/name)
   launcher=root/'tools/run-native-qml-case.py'
   for code,passed,expected in [(1,True,1),(0,False,1),(0,True,0)]:
    with self.subTest(code=code,passed=passed):
     launcher.write_text('import sys,json\nfrom pathlib import Path\no=Path(sys.argv[sys.argv.index("--output")+1]);o.mkdir(exist_ok=True)\n'+f'(o/"result.json").write_text(json.dumps({{"passed":{passed!r},"exit_code":0,"case_result":{{"completed":[{{}}]*10}}}}))\nsys.exit({code})\n')
     output=root/f'run-{code}-{passed}'
     p=subprocess.run([sys.executable,str(suite/'run.py'),'--activity','vertical_addition','--snapshot','unused','--output',str(output)],capture_output=True,text=True)
     self.assertEqual(p.returncode,expected,p.stderr)
if __name__=='__main__':unittest.main()
