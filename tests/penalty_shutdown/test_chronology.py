# SPDX-License-Identifier: GPL-3.0-or-later
import json,subprocess,sys,tempfile,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
class MissingHistoricalRuntime(unittest.TestCase):
 def test_missing_original_files_do_not_prove_inode_independence(self):
  with tempfile.TemporaryDirectory() as temporary:
   root=Path(temporary);output=root/'report.json';run=subprocess.run([sys.executable,str(ROOT/'tests/penalty_shutdown/reconstruct.py'),'--original-runtime',str(root/'missing-runtime'),'--main-prefix',str(root/'missing-main'),'--output',str(output)],capture_output=True,text=True);self.assertEqual(run.returncode,0,run.stderr);d=json.loads(output.read_text());self.assertEqual(d['original_snapshot_available_files'],0);self.assertIsNone(d['verified_no_shared_main_inode']);self.assertEqual(d['original_snapshot_files'],269)
if __name__=='__main__':unittest.main()
