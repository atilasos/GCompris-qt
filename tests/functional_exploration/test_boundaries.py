# SPDX-License-Identifier: GPL-3.0-or-later
"""Python filesystem/process fixtures, not native game-completion evidence."""
import hashlib,json,subprocess,tempfile,unittest
from pathlib import Path
from unittest.mock import patch
import run as runner
from phase import verify

def bytes_under(root):return {str(p.relative_to(root)):p.read_bytes() for p in root.rglob('*') if p.is_file()}
class ExecutionBoundaries(unittest.TestCase):
 def test_existing_output_preserves_all_old_bytes_before_launch(self):
  with tempfile.TemporaryDirectory() as temporary:
   root=Path(temporary);output=root/'accepted';output.mkdir();(output/'tool-status.json').write_bytes(b'accepted status');(output/'result.json').write_bytes(b'accepted receipt');(root/'accepted.parent.log').write_bytes(b'accepted parent log');before=bytes_under(root)
   with patch.object(runner.subprocess,'run') as launch:
    with self.assertRaises(FileExistsError):runner.run('explore_monuments','absent',root/'absent.qml',output)
    launch.assert_not_called()
   self.assertEqual(bytes_under(root),before)
 def test_case_freeze_keeps_original_bytes_after_author_edits(self):
  with tempfile.TemporaryDirectory() as temporary:
   root=Path(temporary);case=root/'case.qml';case.write_bytes(b'TestCase { name: "original" }')
   with patch.object(runner,'ROOT',root):frozen=runner.freeze_case(case)
   original=frozen.read_bytes();case.write_bytes(b'changed during a future authoring step')
   self.assertEqual(frozen.read_bytes(),original);self.assertEqual(frozen.stem,hashlib.sha256(original).hexdigest());self.assertFalse(frozen.is_symlink())
 def test_frozen_source_corruption_refuses_execution(self):
  with tempfile.TemporaryDirectory() as temporary:
   root=Path(temporary);(root/'data').write_bytes(b'original');(root/'source-manifest.json').write_text(json.dumps({'data':hashlib.sha256(b'original').hexdigest()}));verify(root);(root/'data').write_bytes(b'changed')
   with self.assertRaises(ValueError):verify(root)
 def test_cases_do_not_inspect_hidden_answer_models(self):
  folder=Path(__file__).parent
  for name in ['gameplay.qml','controls.qml','language-exact.qml','supplement.qml','supplement2.qml']:
   text=(folder/name).read_text()
   for hidden in ['questionOrder','questionId','currentQuestion','dataModel','dataset.item','Activity.items','items.buttonsBlocked']:
    self.assertNotIn(hidden,text,name)
if __name__=='__main__':unittest.main()
