# SPDX-License-Identifier: GPL-3.0-or-later
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[2]
BASE=ROOT/'.scratch/pt-pt/functional-magic-hat'
CLI=ROOT/'tests/functional_magic_hat/audit.py'


class HistoricalVisibleStars(unittest.TestCase):
    def setUp(self):
        self.directory=tempfile.TemporaryDirectory(prefix='magic proof ');self.addCleanup(self.directory.cleanup);self.copy=Path(self.directory.name)/'moved evidence';shutil.copytree(BASE,self.copy,ignore=shutil.ignore_patterns('.native-qml-*'))

    def invoke(self,path,optimized=False):return subprocess.run([sys.executable,*(['-O'] if optimized else []),str(CLI),'--evidence',str(path),'--repository',str(ROOT)],capture_output=True,text=True,cwd=self.directory.name)

    def change(self,path,callback):
        file=self.copy/path;value=json.loads(file.read_text());callback(value);file.write_text(json.dumps(value,indent=2)+'\n')

    def reseal(self):
        index=json.loads((self.copy/'index.json').read_text())
        for path in index['files']:index['files'][path]=hashlib.sha256((self.copy/path).read_bytes()).hexdigest()
        (self.copy/'index.json').write_text(json.dumps(index,indent=2)+'\n')

    def reject(self):
        result=self.invoke(self.copy);self.assertEqual(result.returncode,1,result.stdout+result.stderr);self.assertIn('Magic hat evidence rejected',result.stderr)

    def test_original_and_independent_moved_copy_pass(self):
        for path in [BASE,self.copy]:
            result=self.invoke(path);self.assertEqual(result.returncode,0,result.stdout+result.stderr);report=json.loads(result.stdout);self.assertEqual(report['levels'],82);self.assertEqual(report['wrong_repaired'],82)

    def test_optimized_python_cannot_approve_original_valid_evidence(self):
        result=self.invoke(BASE,True);self.assertNotEqual(result.returncode,0);self.assertIn('assertions',result.stderr)

    def test_changed_phase_star_count_and_resealed_receipt_chain_is_rejected(self):
        self.change('minus-complete/result.json',lambda value:value['case_result']['observations'][0]['second'][0].update(count=9));sha=hashlib.sha256((self.copy/'minus-complete/result.json').read_bytes()).hexdigest()
        self.change('minus-complete/launcher-status.json',lambda value:value.update(native_receipt_sha256=sha));self.change('minus-complete/supervisor-exit.json',lambda value:value.update(native_receipt_sha256=sha));self.reseal();self.reject()

    def test_copied_case_and_resealed_receipt_chain_is_rejected(self):
        original=(BASE/'plus-complete/case.qml').read_bytes();file=self.copy/'plus-complete/case.qml';file.write_bytes(original+b'\n// changed copied case\n');sha=hashlib.sha256(file.read_bytes()).hexdigest()
        self.change('plus-complete/result.json',lambda value:value.update(case_sha256=sha));receipt=hashlib.sha256((self.copy/'plus-complete/result.json').read_bytes()).hexdigest()
        self.change('plus-complete/launcher-status.json',lambda value:value.update(case_sha256=sha,native_receipt_sha256=receipt));self.change('plus-complete/supervisor-exit.json',lambda value:value.update(case_sha256=sha,native_receipt_sha256=receipt));self.reseal();self.reject();self.assertEqual((BASE/'plus-complete/case.qml').read_bytes(),original)

    def test_coherent_rcc_and_snapshot_reseal_is_rejected(self):
        self.change('identities/resources.json',lambda value:value['canonical']['magic-hat-minus'].update(rcc_sha256='0'*64));self.change('identities/snapshot-manifest.json',lambda value:value['files'].update({'share/gcompris-qt/rcc/magic-hat-minus.rcc':'0'*64}));self.reseal();self.reject()

    def test_source_hash_and_path_reseal_is_rejected(self):
        def change(value):
            path=next(iter(value['files']));value['files']['src/activities/magic-hat-minus/forged.qml']=value['files'].pop(path)
        self.change('identities/source-manifest.json',change);self.reseal();self.reject()

    def test_supervisor_identity_reseal_is_rejected(self):
        self.change('plus-complete/supervisor-exit.json',lambda value:value.update(supervisor_sha256='0'*64));self.reseal();self.reject()

    def test_catalogue_hash_and_resealed_status_chain_is_rejected(self):
        self.change('plus-complete/result.json',lambda value:value.update(portuguese_catalogue_sha256='0'*64));receipt=hashlib.sha256((self.copy/'plus-complete/result.json').read_bytes()).hexdigest()
        self.change('plus-complete/launcher-status.json',lambda value:value.update(native_receipt_sha256=receipt));status=hashlib.sha256((self.copy/'plus-complete/launcher-status.json').read_bytes()).hexdigest()
        self.change('plus-complete/supervisor-exit.json',lambda value:value.update(native_receipt_sha256=receipt,launcher_status_sha256=status));self.change('tool-outer-observations.json',lambda value:value['observations']['plus-complete'].update(native_receipt_sha256=receipt));self.reseal();self.reject()

    def test_forged_successful_tool_completion_is_rejected(self):
        self.change('tool-outer-observations.json',lambda value:value['observations']['help-vocabulary-diagnostic'].update(tool_exit_code=0));self.reseal();self.reject()

    def test_failed_outer_status_is_rejected_despite_native_green(self):
        self.change('minus-complete/launcher-status.json',lambda value:value.update(exit_code=1));self.reseal();self.reject()
