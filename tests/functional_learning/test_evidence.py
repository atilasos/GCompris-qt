# SPDX-License-Identifier: GPL-3.0-or-later
"""Run the copied CLI and reject material mutations even when hashes are recalculated."""
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

EVIDENCE=Path(__file__).resolve().parents[2]/'.scratch/pt-pt/functional-learning'


def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()


class HistoricalProof(unittest.TestCase):
    def setUp(self):
        self.workspace=tempfile.TemporaryDirectory();self.root=Path(self.workspace.name)/'proof';self.root.mkdir()
        for name in ('archive','final','auditor','resources'):shutil.copytree(EVIDENCE/name,self.root/name)
        for name in ('lock.json','resources.json','resource-exporter.cpp','resource-decoder.py','hands-contact.png'):shutil.copyfile(EVIDENCE/name,self.root/name)

    def tearDown(self):self.workspace.cleanup()

    def reseal(self,*paths):
        lock=json.loads((self.root/'lock.json').read_text())
        for relative in paths:lock['files'][relative]=sha(self.root/relative)
        (self.root/'lock.json').write_text(json.dumps(lock))

    def write_receipt(self,name,record):
        relative='final/'+name+'/result.json';path=self.root/relative;path.write_text(json.dumps(record))
        status_relative='final/'+name+'/launcher-status.json';status=self.root/status_relative;value=json.loads(status.read_text());value['native_receipt_sha256']=sha(path);status.write_text(json.dumps(value))
        self.reseal(relative,status_relative)

    def audit(self):
        return subprocess.run([sys.executable,'-B',str(self.root/'auditor/audit.py'),'--evidence',str(self.root)],cwd=self.workspace.name,capture_output=True,text=True)

    def test_independent_copy_without_checkout(self):
        result=self.audit();self.assertEqual(result.returncode,0,result.stderr)
        report=json.loads(result.stdout);self.assertEqual((report['questions'],report['supervised_cases'],report['pixel_images']),(220,11,220))

    def test_rejects_wrong_integer_despite_rehashed_receipt_and_status(self):
        name='learn_additions-gameplay-1';record=json.loads((self.root/'final'/name/'result.json').read_text());record['case_result']['completed'][0]['target']['answer']+=1
        self.write_receipt(name,record);self.assertNotEqual(self.audit().returncode,0)

    def test_rejects_observed_outer_failure_despite_rehashed_status(self):
        relative='final/learn_digits-gameplay-1/launcher-status.json';path=self.root/relative;record=json.loads(path.read_text());record['exit_code']=1;path.write_text(json.dumps(record));self.reseal(relative)
        self.assertNotEqual(self.audit().returncode,0)

    def test_rejects_resealed_supervisor_source(self):
        relative='archive/files/tools/run-native-qml-supervised.py';path=self.root/relative;path.write_text(path.read_text()+'\n# changed supervision\n')
        manifest=self.root/'archive/manifest.json';value=json.loads(manifest.read_text());value['files']['tools/run-native-qml-supervised.py']={'sha256':sha(path),'bytes':path.stat().st_size};manifest.write_text(json.dumps(value))
        self.reseal(relative,'archive/manifest.json');lock=self.root/'lock.json';value=json.loads(lock.read_text());value['archive_sha256']=sha(manifest);lock.write_text(json.dumps(value))
        self.assertNotEqual(self.audit().returncode,0)

    def test_rejects_empty_completed_route_with_rehashed_receipt(self):
        name='learn_subtractions-gameplay-1';record=json.loads((self.root/'final'/name/'result.json').read_text());record['case_result']['completed']=[];record['case_result']['wins']=0;record['case_result']['wrong']=0
        self.write_receipt(name,record);self.assertNotEqual(self.audit().returncode,0)

    def test_rejects_rendered_circle_mutation_even_when_resealed(self):
        from PIL import Image
        name='learn_digits-gameplay-1';directory=self.root/'final'/name;record=json.loads((directory/'result.json').read_text());row=next(row for row in record['case_result']['completed'] if row['target']['answer']>0);circle=next(c for c in row['circles'] if c['filled']);path=directory/row['screenshot']
        image=Image.open(path).convert('RGB');image.putpixel((round(circle['x']),round(circle['y'])),(255,255,255));image.save(path)
        for shot in record['screenshots']:
            if shot['file']==row['screenshot']:shot['sha256']=sha(path)
        self.reseal(path.relative_to(self.root).as_posix());self.write_receipt(name,record);self.assertNotEqual(self.audit().returncode,0)
