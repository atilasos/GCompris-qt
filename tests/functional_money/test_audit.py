# SPDX-License-Identifier: GPL-3.0-or-later
"""Exercise the public auditor CLI against moved and materially changed evidence."""
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[2]
BASE=ROOT/'.scratch/pt-pt/functional-money'
CLI=ROOT/'tests/functional_money/audit.py'


class HistoricalMoneyEvidence(unittest.TestCase):
    def setUp(self):
        self.directory=tempfile.TemporaryDirectory(prefix='money proof ')
        self.addCleanup(self.directory.cleanup)
        self.copy=Path(self.directory.name)/'moved evidence'
        shutil.copytree(BASE,self.copy,ignore=shutil.ignore_patterns('.native-qml-*'))

    def run_auditor(self,path):
        return subprocess.run([sys.executable,str(CLI),'--evidence',str(path),'--repository',str(ROOT)],cwd=self.directory.name,capture_output=True,text=True)

    def change_json(self,path,change,reindex=False):
        full=self.copy/path;value=json.loads(full.read_text());change(value);full.write_text(json.dumps(value,indent=2)+'\n')
        if reindex:
            index=json.loads((self.copy/'index.json').read_text());index['files'][path]=hashlib.sha256(full.read_bytes()).hexdigest();(self.copy/'index.json').write_text(json.dumps(index,indent=2)+'\n')

    def rejected(self):
        completed=self.run_auditor(self.copy)
        self.assertEqual(completed.returncode,1,completed.stdout+completed.stderr)
        self.assertIn('Money evidence rejected',completed.stderr)

    def test_original_and_independent_moved_copy_are_valid(self):
        for path in [BASE,self.copy]:
            completed=self.run_auditor(path)
            self.assertEqual(completed.returncode,0,completed.stdout+completed.stderr)
            report=json.loads(completed.stdout);self.assertEqual(report['puzzles'],206);self.assertEqual(report['cases'],18)

    def status(self,code):
        native=self.copy/'money-auto/result.json';d=json.loads(native.read_text())
        status={'format':1,'kind':'observed-subprocess-exit','exit_code':code,
                'native_receipt_sha256':hashlib.sha256(native.read_bytes()).hexdigest(),
                'case_sha256':d['case_sha256'],'launcher_sha256':d['runner_sha256']}
        (native.parent/'launcher-status.json').write_text(json.dumps(status))

    def test_green_native_receipt_with_failed_launcher_is_rejected(self):
        self.status(0)
        passed=self.run_auditor(self.copy);self.assertEqual(passed.returncode,0,passed.stderr)
        self.status(1);self.rejected()

    def test_index_refuses_failed_launcher_without_overwriting_old_index(self):
        self.status(1);original=(self.copy/'index.json').read_bytes()
        run=subprocess.run([sys.executable,str(CLI.with_name('index.py')),'--evidence',str(self.copy)],capture_output=True,text=True)
        self.assertNotEqual(run.returncode,0,run.stdout)
        self.assertIn('Native launcher did not finish',run.stderr)
        self.assertEqual((self.copy/'index.json').read_bytes(),original)

    def test_retrospective_observations_are_immutable(self):
        self.change_json('supervisor-observations.json',lambda d:d['observations'][0].update(launcher_exit_code=0))
        self.rejected()

    def test_receipt_source_hash_cannot_be_laundered_through_a_new_index(self):
        self.change_json('money-auto/result.json',lambda value:value.update(source_sha256='0'*64),reindex=True)
        self.rejected()

    def test_receipt_catalogue_identity_is_bound_to_tested_revision(self):
        self.change_json('money-auto/result.json',lambda value:value.update(portuguese_catalogue_sha256='0'*64))
        self.rejected()

    def test_source_map_path_replacement_is_rejected(self):
        def change(value):
            path=next(iter(value['files']));value['files']['src/activities/money/forged.qml']=value['files'].pop(path)
        self.change_json('phases/final/source-manifest.json',change,reindex=True)
        self.rejected()

    def test_captured_rcc_identity_is_not_an_approval_baseline(self):
        self.change_json('phases/final/rcc-identities.json',lambda value:value['money'].update(rcc_sha256='0'*64))
        self.rejected()

    def test_source_identity_hash_tampering_is_rejected(self):
        self.change_json('phases/final/rcc-identities.json',lambda value:value['money']['files'][0].update(sha256='0'*64),reindex=True)
        self.rejected()

    def test_snapshot_file_hash_tampering_is_rejected(self):
        self.change_json('phases/final/snapshot-manifest.json',lambda value:value['files'].update({'bin/gcompris-qt':'0'*64}))
        self.rejected()

    def test_copied_case_bytes_are_independent_and_tampering_is_rejected(self):
        original=(BASE/'money-auto/case.qml').read_bytes()
        with (self.copy/'money-auto/case.qml').open('ab') as stream:stream.write(b'\n// changed copied input\n')
        self.assertEqual((BASE/'money-auto/case.qml').read_bytes(),original)
        self.rejected()

    def test_altered_native_result_arithmetic_is_rejected(self):
        self.change_json('money-auto/result.json',lambda value:value['case_result']['observations'][0].update(targetCents=999999))
        self.rejected()
