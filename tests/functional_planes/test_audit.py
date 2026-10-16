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
BASE=ROOT/'.scratch/pt-pt/functional-planes'
CLI=ROOT/'tests/functional_planes/audit.py'


class ImmutableFlyingEvidence(unittest.TestCase):
    def setUp(self):
        self.directory=tempfile.TemporaryDirectory(prefix='flying proof ');self.addCleanup(self.directory.cleanup)
        self.copy=Path(self.directory.name)/'moved proof'
        shutil.copytree(BASE,self.copy,ignore=shutil.ignore_patterns('.native-qml-*'))

    def invoke(self,base):return subprocess.run([sys.executable,str(CLI),'--evidence',str(base),'--repository',str(ROOT)],cwd=self.directory.name,capture_output=True,text=True)

    def change(self,path,callback):
        full=self.copy/path;value=json.loads(full.read_text());callback(value);full.write_text(json.dumps(value,indent=2)+'\n')

    def reseal(self):
        index=json.loads((self.copy/'index.json').read_text())
        for path in index['files']:index['files'][path]=hashlib.sha256((self.copy/path).read_bytes()).hexdigest()
        (self.copy/'index.json').write_text(json.dumps(index,indent=2)+'\n')

    def reject(self):
        result=self.invoke(self.copy);self.assertEqual(result.returncode,1,result.stdout+result.stderr);self.assertIn('Flying sequence proof rejected',result.stderr)

    def test_original_and_moved_copy_pass_without_old_worktree_paths(self):
        for base in [BASE,self.copy]:
            result=self.invoke(base);self.assertEqual(result.returncode,0,result.stdout+result.stderr);report=json.loads(result.stdout);self.assertEqual(report['captures'],190);self.assertEqual(report['levels'],12)

    def test_green_native_receipt_does_not_approve_failed_outer_launcher(self):
        self.change('number-complete/launcher-status.json',lambda value:value.update(exit_code=1));self.reject()

    def test_missing_post_wait_status_rejects_green_native_receipt(self):
        (self.copy/'number-complete/launcher-status.json').unlink();self.reject()

    def test_changed_source_hash_with_resealed_index_is_rejected(self):
        self.change('identities/fixed-source-manifest.json',lambda value:value['files'].update({'src/activities/planegame/Planegame.qml':'0'*64}));self.reseal();self.reject()

    def test_replaced_source_map_path_with_resealed_index_is_rejected(self):
        def replace(value):
            path=next(iter(value['files']));value['files']['src/activities/planegame/forged.qml']=value['files'].pop(path)
        self.change('identities/source-manifest.json',replace);self.reseal();self.reject()

    def test_catalogue_receipt_and_outer_hash_cannot_be_resealed(self):
        self.change('alphabet-complete/result.json',lambda value:value.update(portuguese_catalogue_sha256='0'*64))
        sha=hashlib.sha256((self.copy/'alphabet-complete/result.json').read_bytes()).hexdigest()
        self.change('alphabet-complete/launcher-status.json',lambda value:value.update(native_receipt_sha256=sha));self.reseal();self.reject()

    def test_case_receipt_and_outer_status_cannot_be_resealed(self):
        path=self.copy/'number-complete/case.qml';original=(BASE/'number-complete/case.qml').read_bytes();path.write_bytes(original+b'\n// altered copied case\n');sha=hashlib.sha256(path.read_bytes()).hexdigest()
        self.change('number-complete/result.json',lambda value:value.update(case_sha256=sha));receipt=hashlib.sha256((self.copy/'number-complete/result.json').read_bytes()).hexdigest()
        self.change('number-complete/launcher-status.json',lambda value:value.update(case_sha256=sha,native_receipt_sha256=receipt));self.reseal();self.reject();self.assertEqual((BASE/'number-complete/case.qml').read_bytes(),original)

    def test_rcc_identity_and_snapshot_cannot_be_resealed(self):
        self.change('identities/resource-identities.json',lambda value:value['canonical']['core'].update(rcc_sha256='0'*64))
        self.change('identities/snapshot-manifest.json',lambda value:value['files'].update({'share/gcompris-qt/rcc/core.rcc':'0'*64}));self.reseal();self.reject()

    def test_forged_capture_order_rejects_even_with_new_receipt_hash(self):
        self.change('alphabet-complete/result.json',lambda value:value['case_result']['observations'][0]['captures'][10].update(drawn='l'))
        sha=hashlib.sha256((self.copy/'alphabet-complete/result.json').read_bytes()).hexdigest()
        self.change('alphabet-complete/launcher-status.json',lambda value:value.update(native_receipt_sha256=sha));self.reseal();self.reject()
