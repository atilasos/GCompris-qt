# SPDX-License-Identifier: GPL-3.0-or-later
import json,subprocess,sys,tempfile,unittest
from pathlib import Path
from prepare import render
HERE=Path(__file__).resolve().parent
class VisiblePolygonCases(unittest.TestCase):
 def inputs(self):return json.loads((HERE/'proposals.json').read_text()),json.loads((HERE/'observed-instructions.json').read_text())
 def test_nine_instructions_generate_separate_pilot_and_full_case(self):
  proposals,inventory=self.inputs();cases=render(proposals,inventory)
  self.assertEqual(set(cases),{'pilot.qml','tutorial-nine.qml','controls-free.qml'})
  self.assertIn('[[2,4],[5,4],[8,4]]',cases['pilot.qml'])
  self.assertNotIn('__',cases['tutorial-nine.qml'].replace('__QA_OUTPUT__',''))
 def test_unknown_visible_instruction_is_rejected(self):
  proposals,inventory=self.inputs();inventory['instructions'][0]='Instrução não inventariada'
  with self.assertRaises(ValueError):render(proposals,inventory)
 def test_nonmatching_inventory_identity_is_rejected(self):
  proposals,inventory=self.inputs();proposals['inventory_sha256']='0'*64
  with self.assertRaises(ValueError):render(proposals,inventory)
 def test_proposal_cannot_relabel_a_square_as_generic_polygon(self):
  proposals,inventory=self.inputs();proposals['questions']['Desenha um quadrado.']['property']='polygon'
  with self.assertRaises(ValueError):render(proposals,inventory)
 def test_existing_output_is_not_modified(self):
  with tempfile.TemporaryDirectory() as directory:
   root=Path(directory);sentinel=root/'pilot.qml';sentinel.write_bytes(b'original')
   result=subprocess.run([sys.executable,str(HERE/'prepare.py'),'--output',str(root)],capture_output=True)
   self.assertEqual(result.returncode,2);self.assertEqual(sentinel.read_bytes(),b'original');self.assertEqual(list(root.iterdir()),[sentinel])
 def test_bad_candidate_is_rejected_by_independent_geometry(self):
  proposals,inventory=self.inputs();proposals['questions']['Desenha um quadrado.']['vertices']=[[2,4],[5,4],[8,4]]
  with self.assertRaises(ValueError):render(proposals,inventory)
if __name__=='__main__':unittest.main()
