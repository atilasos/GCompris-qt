# SPDX-License-Identifier: GPL-3.0-or-later
"""Historical evidence survives relocation and rejects material tampering."""
import json
from pathlib import Path
import shutil
import tempfile
import unittest
import path_audit as auditor


class Contract(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory();self.addCleanup(self.temp.cleanup)
        self.evidence=Path(self.temp.name)/'copied'
        self.evidence.mkdir()
        names=['source-identity.json','wav-software-decode.json','resource-snapshot.json','full.qml','controls-fixed.qml','title-exact-red']
        for activity in auditor.ACTIVITIES:
            names.extend([f'{kind}-{activity}' for kind in ['full','controls-fixed','resources']])
            names.append(f'resources-{activity}.qml')
        for name in names:
            src=auditor.HERE/name;dst=self.evidence/name
            if src.is_dir():shutil.copytree(src,dst)
            else:shutil.copyfile(src,dst)

    def change_json(self,name,fn):
        file=self.evidence/name;data=json.loads(file.read_text());fn(data);file.write_text(json.dumps(data))

    def test_copy_without_original_runtime_paths(self):
        self.assertTrue(auditor.audit(self.evidence)['passed'])

    def test_missing_level_rejected(self):
        self.change_json('full-path_encoding/result.json',lambda d:d['case_result']['completed'].pop())
        with self.assertRaises(AssertionError):auditor.audit(self.evidence)

    def test_source_identity_rejected(self):
        self.change_json('source-identity.json',lambda d:d.pop(auditor.INJECTED))
        with self.assertRaises(AssertionError):auditor.audit(self.evidence)

    def test_changed_resource_rejected(self):
        file=self.evidence/'resources-path_encoding/resources/src/activities/path_encoding/resource/flag.svg'
        file.chmod(0o600);file.write_bytes(file.read_bytes()+b'changed')
        with self.assertRaises(AssertionError):auditor.audit(self.evidence)

    def test_changed_case_rejected(self):
        file=self.evidence/'full.qml';file.write_text(file.read_text()+'\n// changed')
        with self.assertRaises(AssertionError):auditor.audit(self.evidence)

    def test_changed_effective_snapshot_rejected(self):
        self.change_json('full-path_encoding/result.json',lambda d:d['resource_files_sha256'].pop('bin/gcompris-qt'))
        with self.assertRaises(AssertionError):auditor.audit(self.evidence)


if __name__=='__main__':unittest.main()
