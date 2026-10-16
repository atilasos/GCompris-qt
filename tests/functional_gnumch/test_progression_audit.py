# SPDX-License-Identifier: GPL-3.0-or-later
"""Reject source/visible goal mismatches through the CLI and real receipts."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[2]
EVIDENCE=ROOT/'.scratch/pt-pt/functional-gnumch'
AUDITOR=Path(os.environ.get('GNUMCH_AUDITOR',str(ROOT/'tests/functional_gnumch/audit.py')))

class GoalProgressionAudit(unittest.TestCase):
 def check_rejected(self,field,value):
  with tempfile.TemporaryDirectory(prefix='gnumch-audit-cli-') as tmp:
   evidence=Path(tmp)/'evidence'
   shutil.copytree(EVIDENCE,evidence,ignore=shutil.ignore_patterns('.native-qml-*'))
   file=evidence/'inventory.json';d=json.loads(file.read_text());d['activities']['gnumch-equality']['levels'][0][field]=value;file.write_text(json.dumps(d))
   run=subprocess.run([sys.executable,str(AUDITOR),str(evidence)],capture_output=True,text=True,timeout=30)
   self.assertNotEqual(run.returncode,0,'A claimed level goal/operation must agree with the actual drawn request and expressions')
 def test_altered_level_goal_is_rejected(self):self.check_rejected('goal',999)
 def test_altered_level_operator_is_rejected(self):self.check_rejected('operator',' * ')
if __name__=='__main__':unittest.main()
