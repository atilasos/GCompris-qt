# SPDX-License-Identifier: GPL-3.0-or-later
import tempfile,unittest
from pathlib import Path
from store import Writer,Reader
class StorageBoundary(unittest.TestCase):
 def test_existing_output_preserves_every_byte(self):
  with tempfile.TemporaryDirectory() as tmp:
   out=Path(tmp)/'old';out.mkdir();(out/'capture.json').write_bytes(b'accepted history');before={p.name:p.read_bytes() for p in out.iterdir()}
   with self.assertRaises(FileExistsError):Writer(out)
   self.assertEqual({p.name:p.read_bytes() for p in out.iterdir()},before)
 def test_content_addressed_round_trip_relocates_and_deduplicates(self):
  with tempfile.TemporaryDirectory() as tmp:
   root=Path(tmp);source=root/'source';source.write_bytes(b'physical bytes');writer=Writer(root/'capsule');writer.file('a',source);writer.file('b',source);digest=writer.finish({'purpose':'literal fixture'});source.unlink();(root/'capsule').rename(root/'elsewhere')
   reader=Reader(root/'elsewhere',digest);self.assertEqual(reader.artifact('a'),b'physical bytes');self.assertEqual(reader.artifact('b'),b'physical bytes');self.assertEqual(len(reader.objects),1)
 def test_collector_refuses_old_output_before_even_reading_missing_inputs(self):
  from collect import collect
  with tempfile.TemporaryDirectory() as tmp:
   out=Path(tmp)/'old';out.mkdir();(out/'capture.json').write_bytes(b'accepted bytes')
   with self.assertRaises(FileExistsError):collect('/missing','/missing','/missing',[],[],out)
   self.assertEqual((out/'capture.json').read_bytes(),b'accepted bytes')
if __name__=='__main__':unittest.main()
