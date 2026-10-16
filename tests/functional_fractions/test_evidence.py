# SPDX-License-Identifier: GPL-3.0-or-later
"""Exercise the copied standalone CLI and material mutations with rehashed receipts."""
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

EVIDENCE=Path(__file__).resolve().parents[2]/'.scratch/pt-pt/functional-fractions'


def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()


class FrozenEvidenceCLI(unittest.TestCase):
    def setUp(self):
        self.workspace=tempfile.TemporaryDirectory()
        self.root=Path(self.workspace.name)/'proof'
        self.root.mkdir()
        for name in ('archive','final','auditor','history','wording-red-final','wording-green'):shutil.copytree(EVIDENCE/name,self.root/name)
        shutil.copyfile(EVIDENCE/'lock.json',self.root/'lock.json')

    def tearDown(self):self.workspace.cleanup()

    def refresh_hashes(self,*paths):
        lock=json.loads((self.root/'lock.json').read_text())
        for relative in paths:lock['files'][relative]=sha(self.root/relative)
        (self.root/'lock.json').write_text(json.dumps(lock))

    def run_auditor(self):
        return subprocess.run([sys.executable,'-B',str(self.root/'auditor/audit.py'),'--evidence',str(self.root)],
                              cwd=self.workspace.name,capture_output=True,text=True)

    def test_copy_runs_without_original_checkout_paths(self):
        result=self.run_auditor()
        self.assertEqual(result.returncode,0,result.stderr)
        report=json.loads(result.stdout)
        self.assertEqual((report['levels'],report['questions'],report['pixel_verified_images']),(30,138,276))

    def test_rejects_relabelled_receipt_copied_between_activities(self):
        source=json.loads((self.root/'final/fractions_create-gameplay/result.json').read_text())
        target=self.root/'final/fractions_find-gameplay/result.json'
        original=json.loads(target.read_text())
        source['activity']='fractions_find'
        source['screenshots']=original['screenshots']
        target.write_text(json.dumps(source))
        self.refresh_hashes('final/fractions_find-gameplay/result.json')
        self.assertNotEqual(self.run_auditor().returncode,0)

    def test_rejects_changed_answer_even_with_updated_file_hash(self):
        target=self.root/'final/fractions_create-gameplay/result.json'
        record=json.loads(target.read_text())
        record['case_result']['completed'][0]['answerNumerator']+=1
        target.write_text(json.dumps(record))
        self.refresh_hashes('final/fractions_create-gameplay/result.json')
        self.assertNotEqual(self.run_auditor().returncode,0)

    def test_rejects_copied_empty_diagram_even_with_updated_hashes(self):
        target=self.root/'final/fractions_create-gameplay/result.json'
        record=json.loads(target.read_text());row=record['case_result']['completed'][0]
        image=target.parent/row['answerFile'];shutil.copyfile(target.parent/row['questionFile'],image)
        for screenshot in record['screenshots']:
            if screenshot['file']==row['answerFile']:screenshot['sha256']=sha(image)
        target.write_text(json.dumps(record))
        self.refresh_hashes('final/fractions_create-gameplay/result.json','final/fractions_create-gameplay/'+row['answerFile'])
        self.assertNotEqual(self.run_auditor().returncode,0)

    def test_rejects_rehashed_source_against_immutable_archive_identity(self):
        relative='src/activities/fractions_create/FractionsCreate.qml'
        target=self.root/'archive/files'/relative;target.write_text(target.read_text()+'\n// altered input\n')
        manifest_path=self.root/'archive/manifest.json';manifest=json.loads(manifest_path.read_text())
        manifest['files'][relative]['sha256']=sha(target);manifest['files'][relative]['bytes']=target.stat().st_size
        manifest_path.write_text(json.dumps(manifest))
        self.refresh_hashes('archive/files/'+relative,'archive/manifest.json')
        lock=json.loads((self.root/'lock.json').read_text());lock['archive_manifest_sha256']=sha(manifest_path)
        (self.root/'lock.json').write_text(json.dumps(lock))
        self.assertNotEqual(self.run_auditor().returncode,0)
