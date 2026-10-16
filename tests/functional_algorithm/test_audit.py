# SPDX-License-Identifier: GPL-3.0-or-later
import importlib.util
import json
from pathlib import Path
import shutil
import tempfile
import unittest

SPEC=importlib.util.spec_from_file_location('algorithm_auditor',Path(__file__).with_name('audit.py'))
MODULE=importlib.util.module_from_spec(SPEC);SPEC.loader.exec_module(MODULE)


class FrozenEvidence(unittest.TestCase):
    def setUp(self):
        self.temporary=tempfile.TemporaryDirectory();self.addCleanup(self.temporary.cleanup)
        self.evidence=Path(self.temporary.name)/'copied';self.evidence.mkdir()
        names=['source-identity.json','resource-snapshot.json','data.json','supervisor.py','wav-software-decode.json']
        for case in ['full','controls','resources']:names.extend([case,case+'.qml'])
        for name in names:
            source=MODULE.HERE/name;target=self.evidence/name
            if source.is_dir():shutil.copytree(source,target)
            else:shutil.copyfile(source,target)

    def alter(self,name,change):
        target=self.evidence/name;data=json.loads(target.read_text());change(data);target.write_text(json.dumps(data))

    def test_relocated_proof_needs_no_original_runtime_paths(self):
        self.assertEqual(MODULE.audit(self.evidence)['puzzles'],21)

    def test_missing_required_source_rejected(self):
        self.alter('source-identity.json',lambda d:d['files'].pop(MODULE.QML))
        with self.assertRaises(AssertionError):MODULE.audit(self.evidence)

    def test_resealed_catalogue_identity_rejected(self):
        self.alter('source-identity.json',lambda d:d['files'].update({MODULE.CAT:'0'*64}))
        self.alter('full/result.json',lambda d:d.update({'portuguese_catalogue_sha256':'0'*64}))
        self.alter('full/launcher-status.json',lambda d:d.update({'native_receipt_sha256':MODULE.sha((self.evidence/'full/result.json').read_bytes())}))
        with self.assertRaises(AssertionError):MODULE.audit(self.evidence)

    def test_native_green_does_not_override_failed_external_launcher(self):
        self.alter('full/launcher-status.json',lambda d:d.update({'exit_code':1}))
        with self.assertRaises(AssertionError):MODULE.audit(self.evidence)

    def test_changed_case_rejected(self):
        path=self.evidence/'full.qml';path.write_bytes(path.read_bytes()+b'changed')
        with self.assertRaises(AssertionError):MODULE.audit(self.evidence)

    def test_changed_visible_resource_rejected(self):
        path=self.evidence/'resources/resources/src/activities/enumerate/resource/apple.svg'
        path.chmod(0o600);path.write_bytes(path.read_bytes()+b'changed')
        with self.assertRaises(AssertionError):MODULE.audit(self.evidence)


if __name__=='__main__':unittest.main()
