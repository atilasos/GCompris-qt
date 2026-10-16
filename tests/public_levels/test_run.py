# SPDX-License-Identifier: GPL-3.0-or-later
"""Refused destinations preserve every previous byte without launching Qt."""
import json,subprocess,tempfile,unittest
from pathlib import Path
from unittest.mock import patch
import run as runner

def bytes_under(root):
 return {str(p.relative_to(root)):p.read_bytes() for p in root.rglob('*') if p.is_file()}

class ExistingOutput(unittest.TestCase):
 def test_existing_output_is_rejected_without_any_filesystem_changes(self):
  with tempfile.TemporaryDirectory() as temporary:
   base=Path(temporary)
   source=base/'sources/green';source.mkdir(parents=True);(source/'manifest.json').write_text('{}')
   (source/'tools').mkdir();(source/'tools/run-native-qml-supervised.py').write_text('# fixture supervisor')
   (base/'cases').mkdir();(base/'cases/leftright.qml').write_bytes(b'// accepted case\n')
   output=base/'runs/leftright-green';output.mkdir(parents=True)
   (output/'result.json').write_text(json.dumps({'passed':True,'case_result':{}}))
   (output/'tool-status.json').write_bytes(b'original accepted tool status\n')
   (output.parent/'leftright-green.log').write_bytes(b'original parent log\n')
   before=bytes_under(base)
   with patch.object(runner,'BASE',base),patch.object(runner.subprocess,'run',return_value=subprocess.CompletedProcess([],2)) as launch:
    with self.assertRaises(FileExistsError):
     runner.run('green','leftright','leftright/Leftright.qml',6)
   self.assertEqual(bytes_under(base),before)
   launch.assert_not_called()

if __name__=='__main__':unittest.main()
