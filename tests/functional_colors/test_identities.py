# SPDX-License-Identifier: GPL-3.0-or-later
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ROOT/'.scratch/pt-pt/functional-colors'


class HistoricalColorsIdentities(unittest.TestCase):
    def invoke(self, evidence, output, script=None, cwd=None):
        return subprocess.run([sys.executable, str(script or Path(__file__).with_name('audit.py')),
                               '--evidence', str(evidence), '--output', str(output)],
                              cwd=cwd, capture_output=True, text=True)

    def rejected(self, filename, change):
        with tempfile.TemporaryDirectory() as directory:
            evidence = Path(directory)/'moved-evidence'
            shutil.copytree(EVIDENCE, evidence)
            path = evidence/filename
            value = json.loads(path.read_text())
            change(value)
            path.write_text(json.dumps(value))
            output = Path(directory)/'index.json'
            process = self.invoke(evidence, output)
            self.assertEqual(process.returncode, 1, process.stderr)
            self.assertIn('AssertionError', process.stderr)
            self.assertFalse(output.exists())

    def test_original_proof_accepts_all_19_cases_after_moving_evidence(self):
        with tempfile.TemporaryDirectory() as directory:
            evidence = Path(directory)/'moved-evidence'
            shutil.copytree(EVIDENCE, evidence)
            output = Path(directory)/'index.json'
            process = self.invoke(evidence, output, cwd=directory)
            self.assertEqual(process.returncode, 0, process.stderr)
            value = json.loads(output.read_text())
            self.assertEqual(value['main_questions'], 254)
            self.assertEqual(len(value['cases']), 19)
            self.assertEqual(value['historical_inputs']['source_files'], 330)

    def test_corrupted_source_hash_is_rejected(self):
        def change(value):
            value['color_mix']['files'][0]['sha256'] = '0'*64
        self.rejected('source-identity.json', change)

    def test_wrong_or_missing_source_path_is_rejected(self):
        for operation in ['rename', 'remove', 'duplicate']:
            with self.subTest(operation=operation):
                def change(value):
                    rows = value['color_mix']['files']
                    if operation == 'rename':
                        rows[0]['path'] = ':/gcompris/src/activities/color_mix/not-tested.qml'
                    elif operation == 'remove':
                        rows.pop()
                    else:
                        rows.append(rows[0])
                self.rejected('source-identity.json', change)

    def test_corrupted_canonical_rcc_hash_is_rejected(self):
        self.rejected('source-identity.json', lambda value: value['color_mix'].update(rcc_sha256='0'*64))

    def test_each_snapshot_stage_rejects_changed_hashes(self):
        for stage in ['colors-current', 'colors-fixed', 'colors-final']:
            with self.subTest(stage=stage):
                def change(value):
                    value['files']['share/gcompris-qt/rcc/color_mix.rcc'] = '0'*64
                self.rejected(stage+'-manifest.json', change)

    def test_receipt_identity_fields_cannot_be_changed(self):
        for field in ['source_sha256', 'runner_sha256', 'portuguese_catalogue_sha256', 'private_rcc_sha256',
                      'private_qm_sha256', 'binary_sha256', 'resource_manifest_sha256']:
            with self.subTest(field=field):
                self.rejected('advanced-complete/result.json', lambda value: value.update({field: '0'*64}))
        self.rejected('basic-complete/result.json', lambda value: value['resource_files_sha256'].update({'different/path.rcc': '0'*64}))

    def test_early_catalogue_cannot_be_replaced_by_final_fulva_catalogue(self):
        late = json.loads((EVIDENCE/'fulva-level5-green/result.json').read_text())['portuguese_catalogue_sha256']
        self.rejected('advanced-complete/result.json', lambda value: value.update(portuguese_catalogue_sha256=late))

    def test_inventory_and_audio_captures_cannot_be_rebased(self):
        self.rejected('inventory.json', lambda value: value['source_files'].update({'src/core/not-tested.qml': '0'*64}))
        self.rejected('audio-identity.json', lambda value: next(iter(value.values())).update(sha256='0'*64))

    def test_changed_current_sources_and_runner_are_not_historical_inputs(self):
        with tempfile.TemporaryDirectory() as directory:
            checkout = Path(directory)/'different-checkout'
            scripts = checkout/'tests/functional_colors'
            scripts.mkdir(parents=True)
            for name in ['audit.py', 'identities.py', 'oracle.py']:
                shutil.copyfile(Path(__file__).with_name(name), scripts/name)
            common = subprocess.check_output(['git', '-C', str(ROOT), 'rev-parse', '--git-common-dir'], text=True).strip()
            common = (ROOT/common).resolve()
            (checkout/'.git').write_text('gitdir: '+str(common)+'\n')
            for relative in ['src/activities/colors/FindIt.qml', 'src/core/ParticleSystemStar.qml',
                             'poqm/pt/gcompris_qt.po', 'tools/run-native-qml-case.py']:
                path = checkout/relative
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text('Deliberately different current content, never a tested input.\n')
            evidence = Path(directory)/'moved-evidence'
            shutil.copytree(EVIDENCE, evidence)
            output = Path(directory)/'index.json'
            process = self.invoke(evidence, output, script=scripts/'audit.py', cwd=checkout)
            self.assertEqual(process.returncode, 0, process.stderr)
            self.assertEqual(json.loads(output.read_text())['main_questions'], 254)
