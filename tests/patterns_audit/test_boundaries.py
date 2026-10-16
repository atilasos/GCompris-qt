# SPDX-License-Identifier: GPL-3.0-or-later
import json,sys,tempfile,unittest
from pathlib import Path
from unittest.mock import patch
from store import Writer,Reader,sha
import portable

class PhysicalBoundaries(unittest.TestCase):
 def test_partition_preserves_zip_bytes_and_rejects_changed_chunk(self):
  with tempfile.TemporaryDirectory() as temporary:
   root=Path(temporary);source=root/'source';source.write_bytes(b'visible pixels');writer=Writer(root/'capsule');writer.file('pixels',source);anchor=writer.finish({});capsule=root/'capsule';raw=(capsule/'objects.zip').read_bytes();chunks=[]
   for i,part in enumerate([raw[:19],raw[19:]]):
    name=f'objects.zip.part{i:03d}';(capsule/name).write_bytes(part);chunks.append({'file':name,'bytes':len(part),'sha256':sha(part)})
   (capsule/'archive.json').write_text(json.dumps({'bytes':len(raw),'sha256':sha(raw),'chunks':chunks}));(capsule/'objects.zip').unlink();self.assertEqual(Reader(capsule,anchor,sha(raw)).artifact('pixels'),b'visible pixels')
   (capsule/chunks[0]['file']).write_bytes(b'x'*19)
   with self.assertRaisesRegex(ValueError,'chunk bytes'):Reader(capsule,anchor,sha(raw))
 def test_portable_existing_report_is_preserved_before_missing_dependencies(self):
  with tempfile.TemporaryDirectory() as temporary:
   report=Path(temporary)/'report.json';report.write_bytes(b'previous raw tool observation\x00');before=report.read_bytes()
   with patch.object(sys,'argv',['portable.py','--evidence','/missing/proof','--wheel','/missing/wheel','--output',str(report)]),patch.object(portable.subprocess,'run') as run:
    with self.assertRaises(FileExistsError):portable.main()
    run.assert_not_called()
   self.assertEqual(report.read_bytes(),before)
if __name__=='__main__':unittest.main()
