# SPDX-License-Identifier: GPL-3.0-or-later
"""Run a copied auditor and reject material changes even after resealing manifests."""
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[2]
EVIDENCE=ROOT/'.scratch/pt-pt/functional-comparisons'
NAMES=['comparator-complete','adjacent-automatic-complete','adjacent-manual-complete-rerun',
       'comparator-controls','adjacent-controls','comparator-resources','adjacent_numbers-resources',
       'adjacent-contract-red','adjacent-contract-green2']


def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()


class CopiedEvidence(unittest.TestCase):
    def setUp(self):
        self.workspace=tempfile.TemporaryDirectory();self.root=Path(self.workspace.name)/'proof';self.root.mkdir()
        for name in ['archive','auditor',*NAMES]:shutil.copytree(EVIDENCE/name,self.root/name)
        for name in ('capture.json','audio-decode.json'):shutil.copyfile(EVIDENCE/name,self.root/name)

    def tearDown(self):self.workspace.cleanup()

    def reseal_capture(self,*paths):
        path=self.root/'capture.json';value=json.loads(path.read_text())
        for relative in paths:
            file=self.root/relative;value['files'][relative]={'sha256':sha(file),'bytes':file.stat().st_size}
        path.write_text(json.dumps(value))

    def reseal_source(self,relative):
        path=self.root/'archive/manifest.json';value=json.loads(path.read_text());file=self.root/'archive/files'/relative
        value['files'][relative]={'sha256':sha(file),'bytes':file.stat().st_size};path.write_text(json.dumps(value))

    def receipt(self,name,record):
        relative=name+'/result.json';path=self.root/relative;path.write_text(json.dumps(record))
        status_relative=name+'/launcher-status.json';status=self.root/status_relative;value=json.loads(status.read_text());value['native_receipt_sha256']=sha(path);status.write_text(json.dumps(value))
        tool_relative=name+'/tool-status.json';tool=self.root/tool_relative;value=json.loads(tool.read_text());value['native_receipt_sha256']=sha(path);value['launcher_status_sha256']=sha(status);tool.write_text(json.dumps(value));self.reseal_capture(relative,status_relative,tool_relative)

    def audit(self):
        return subprocess.run([sys.executable,'-B',str(self.root/'auditor/audit.py'),'--evidence',str(self.root)],cwd=self.workspace.name,capture_output=True,text=True)

    def test_copied_proof_is_independent_of_original_checkout(self):
        result=self.audit();self.assertEqual(result.returncode,0,result.stderr)
        report=json.loads(result.stdout);self.assertEqual((report['positive_cases'],report['comparisons'],report['adjacent_questions']),(8,650,250))

    def test_optimised_interpreter_cannot_disable_checks(self):
        result=subprocess.run([sys.executable,'-B','-O',str(self.root/'auditor/audit.py'),'--evidence',str(self.root)],cwd=self.workspace.name,capture_output=True,text=True)
        self.assertNotEqual(result.returncode,0)
        self.assertIn('without optimisation',result.stderr)

    def test_resealed_portuguese_catalogue_rejected(self):
        relative='poqm/pt/gcompris_qt.po';path=self.root/'archive/files'/relative;path.write_bytes(path.read_bytes()+b'\n# changed catalogue\n');self.reseal_source(relative)
        self.assertNotEqual(self.audit().returncode,0)

    def test_resealed_source_rejected(self):
        relative='src/activities/adjacent_numbers/Adjacent_numbers.qml';path=self.root/'archive/files'/relative;path.write_bytes(path.read_bytes()+b'\n// changed game\n');self.reseal_source(relative)
        self.assertNotEqual(self.audit().returncode,0)

    def test_resealed_outer_status_failure_rejected(self):
        relative='comparator-complete/launcher-status.json';path=self.root/relative;record=json.loads(path.read_text());record['exit_code']=1;path.write_text(json.dumps(record));self.reseal_capture(relative)
        self.assertNotEqual(self.audit().returncode,0)

    def test_resealed_external_tool_failure_rejected(self):
        relative='comparator-complete/tool-status.json';path=self.root/relative;record=json.loads(path.read_text());record['exit_code']=143;path.write_text(json.dumps(record));self.reseal_capture(relative)
        self.assertNotEqual(self.audit().returncode,0)

    def test_resealed_case_rejected(self):
        relative='.scratch/pt-pt/functional-comparisons/comparator-complete.qml';path=self.root/'archive/files'/relative;path.write_bytes(path.read_bytes()+b'\n// changed test\n');self.reseal_source(relative)
        self.assertNotEqual(self.audit().returncode,0)

    def test_resealed_decimal_comparison_answer_rejected(self):
        name='comparator-complete';record=json.loads((self.root/name/'result.json').read_text());row=record['case_result']['puzzles'][0]['rows'][0];row['sign']='>' if row['sign']!='>' else '<';self.receipt(name,record)
        self.assertNotEqual(self.audit().returncode,0)

    def test_resealed_empty_route_rejected(self):
        name='adjacent-manual-complete-rerun';record=json.loads((self.root/name/'result.json').read_text());record['case_result'].update(puzzles=[],completed=[],wrong=0);self.receipt(name,record)
        self.assertNotEqual(self.audit().returncode,0)

    def test_resealed_level_image_pixel_rejected(self):
        from PIL import Image
        name='comparator-complete';record=json.loads((self.root/name/'result.json').read_text());shot=record['screenshots'][0];path=self.root/name/shot['file'];image=Image.open(path).convert('RGB');pixel=image.getpixel((0,0));image.putpixel((0,0),tuple(255-channel for channel in pixel));image.save(path);shot['sha256']=sha(path)
        self.reseal_capture(name+'/'+shot['file']);self.receipt(name,record);self.assertNotEqual(self.audit().returncode,0)

    def test_resealed_adjacent_sequence_answer_rejected(self):
        name='adjacent-automatic-complete';record=json.loads((self.root/name/'result.json').read_text());record['case_result']['puzzles'][0]['expected'][0]+=1;self.receipt(name,record)
        self.assertNotEqual(self.audit().returncode,0)
