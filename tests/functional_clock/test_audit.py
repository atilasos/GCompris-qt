# SPDX-License-Identifier: GPL-3.0-or-later
import hashlib
import io
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest
import zipfile
from audit import HERE,ROOT,audit


def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def write(path,data):path.write_text(json.dumps(data,indent=2)+'\n')


class FrozenClockEvidence(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory();self.addCleanup(self.temp.cleanup);self.copy=Path(self.temp.name)/'detached-proof';shutil.copytree(HERE,self.copy,ignore=shutil.ignore_patterns('snapshot','.native-qml-*','__pycache__'))

    def reseal(self):
        capture=json.loads((self.copy/'capture.json').read_text())
        for name in capture['files']:
            path=self.copy/name
            if path.exists():capture['files'][name]=sha(path)
        write(self.copy/'capture.json',capture)

    def altered_receipt(self,change):
        directory=self.copy/'twelve-complete';path=directory/'result.json';result=json.loads(path.read_text());change(result);write(path,result)
        path=directory/'launcher-status.json';status=json.loads(path.read_text());status['native_receipt_sha256']=sha(directory/'result.json');write(path,status)
        path=directory/'tool-status.json';tool=json.loads(path.read_text());tool['native_receipt_sha256']=sha(directory/'result.json');tool['launcher_status_sha256']=sha(directory/'launcher-status.json');write(path,tool)
        self.reseal()

    def test_copied_proof_requires_no_old_worktree_or_git(self):
        result=audit(self.copy);self.assertEqual((result['questions'],result['levels'],result['wrong']),(100,20,100))

    def test_forged_answer_with_all_observation_hashes_recalculated(self):
        self.altered_receipt(lambda r:r['case_result']['questions'][0]['answer'].__setitem__(0,11))
        with self.assertRaises(AssertionError):audit(self.copy)

    def test_missing_campaign_cannot_be_resealed_as_empty_success(self):
        self.altered_receipt(lambda r:r['case_result'].__setitem__('questions',[]))
        with self.assertRaises(AssertionError):audit(self.copy)

    def test_external_tool143_cannot_be_hidden_by_resealing(self):
        p=self.copy/'twelve-complete/tool-status.json';r=json.loads(p.read_text());r['exit_code']=143;write(p,r);self.reseal()
        with self.assertRaises(AssertionError):audit(self.copy)

    def test_modified_native_case_is_rejected_after_reseal(self):
        p=self.copy/'twelve-complete.qml';p.write_text(p.read_text().replace('question<5','question<0'));self.reseal()
        with self.assertRaises(AssertionError):audit(self.copy)

    def test_modified_catalogue_and_resealed_source_archive_are_rejected(self):
        path=self.copy/'source-tree.zip'
        with zipfile.ZipFile(path) as old:files={name:old.read(name) for name in old.namelist()}
        name='poqm/pt/gcompris_qt.po';files[name]=files[name].replace(b'Acertar o',b'Alterar o',1)
        with zipfile.ZipFile(path,'w',zipfile.ZIP_DEFLATED) as new:
            for name,data in files.items():new.writestr(name,data)
        manifest=json.loads((self.copy/'source-manifest.json').read_text());manifest['zip_sha256']=sha(path)
        for name,data in files.items():manifest['files'][name]=hashlib.sha256(data).hexdigest()
        write(self.copy/'source-manifest.json',manifest);self.reseal()
        with self.assertRaises(AssertionError):audit(self.copy)

    def test_changed_picture_with_resealed_capture_is_rejected(self):
        p=self.copy/'twelve-complete/level-1.png';data=bytearray(p.read_bytes());data[-20]^=1;p.write_bytes(data);self.reseal()
        with self.assertRaises(AssertionError):audit(self.copy)

    def test_optimized_python_cannot_disable_verification(self):
        run=subprocess.run([sys.executable,'-O',str(ROOT/'tests/functional_clock/audit.py'),'--evidence',str(self.copy)],capture_output=True,text=True)
        self.assertNotEqual(run.returncode,0);self.assertIn('requires Python assertions',run.stderr)
