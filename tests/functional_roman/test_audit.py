# SPDX-License-Identifier: GPL-3.0-or-later
import hashlib
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

def write(path,value):path.write_text(json.dumps(value,indent=2)+'\n')


class PreservedRomanResults(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory();self.addCleanup(self.temp.cleanup);self.copy=Path(self.temp.name)/'copied-proof';shutil.copytree(HERE,self.copy,ignore=shutil.ignore_patterns('snapshot','.native-qml-*','__pycache__'))

    def reseal(self):
        path=self.copy/'capture.json';capture=json.loads(path.read_text())
        for name in capture['files']:
            item=self.copy/name
            if item.exists():capture['files'][name]=sha(item)
        write(path,capture)

    def change_receipt(self,case,change):
        d=self.copy/case;p=d/'result.json';r=json.loads(p.read_text());change(r);write(p,r)
        p=d/'launcher-status.json';r=json.loads(p.read_text());r['native_receipt_sha256']=sha(d/'result.json');write(p,r)
        p=d/'tool-status.json';r=json.loads(p.read_text());r['native_receipt_sha256']=sha(d/'result.json');r['launcher_status_sha256']=sha(d/'launcher-status.json');write(p,r);self.reseal()

    def test_standalone_copy_checks_final_and_historical_phases(self):
        result=audit(self.copy);self.assertEqual((result['questions'],result['levels'],result['positive'],result['expected_red']),(102,14,7,3))

    def test_changed_answer_cannot_be_accepted_after_recalculating_local_hashes(self):
        self.change_receipt('complete-final',lambda r:r['case_result']['questions'][0].__setitem__('answer','999'))
        with self.assertRaises(AssertionError):audit(self.copy)

    def test_empty_sample_list_cannot_count_as_random_level_coverage(self):
        self.change_receipt('reset-green',lambda r:r['case_result'].__setitem__('samples',[]))
        with self.assertRaises(AssertionError):audit(self.copy)

    def test_external143_is_rejected_separately_from_native0(self):
        p=self.copy/'complete-final/tool-status.json';r=json.loads(p.read_text());r['exit_code']=143;write(p,r);self.reseal()
        with self.assertRaises(AssertionError):audit(self.copy)

    def test_changed_case_is_rejected_after_recalculating_capture(self):
        p=self.copy/'complete.qml';text=p.read_text();self.assertIn('puzzle<count',text);p.write_text(text.replace('puzzle<count','puzzle<0'));self.reseal()
        with self.assertRaises(AssertionError):audit(self.copy)

    def test_changed_historical_source_and_rebuilt_archive_are_rejected(self):
        path=self.copy/'source-tree.zip'
        with zipfile.ZipFile(path) as old:files={name:old.read(name) for name in old.namelist()}
        target='baseline/src/activities/roman_numerals/RomanNumerals.qml';files[target]+=b'\n// changed historical source\n'
        with zipfile.ZipFile(path,'w',zipfile.ZIP_DEFLATED) as new:
            for name,data in files.items():new.writestr(name,data)
        p=self.copy/'source-manifest.json';m=json.loads(p.read_text());m['zip_sha256']=sha(path)
        for name,data in files.items():m['files'][name]=hashlib.sha256(data).hexdigest()
        write(p,m);self.reseal()
        with self.assertRaises(AssertionError):audit(self.copy)

    def test_changed_catalogue_and_rebuilt_archive_are_rejected(self):
        path=self.copy/'source-tree.zip'
        with zipfile.ZipFile(path) as old:files={name:old.read(name) for name in old.namelist()}
        target='final/poqm/pt/gcompris_qt.po';files[target]=files[target].replace(b'Converter o',b'Alterar o',1)
        with zipfile.ZipFile(path,'w',zipfile.ZIP_DEFLATED) as new:
            for name,data in files.items():new.writestr(name,data)
        p=self.copy/'source-manifest.json';m=json.loads(p.read_text());m['zip_sha256']=sha(path)
        for name,data in files.items():m['files'][name]=hashlib.sha256(data).hexdigest()
        write(p,m);self.reseal()
        with self.assertRaises(AssertionError):audit(self.copy)

    def test_changed_saved_picture_is_rejected(self):
        p=self.copy/'complete-final/level-1.png';data=bytearray(p.read_bytes());data[-20]^=1;p.write_bytes(data);self.reseal()
        with self.assertRaises(AssertionError):audit(self.copy)

    def test_optimized_python_cannot_disable_checks(self):
        run=subprocess.run([sys.executable,'-O',str(ROOT/'tests/functional_roman/audit.py'),'--evidence',str(self.copy)],capture_output=True,text=True)
        self.assertNotEqual(run.returncode,0);self.assertIn('requires Python assertions',run.stderr)
