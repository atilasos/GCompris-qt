#!/usr/bin/env python3
# SPDX-FileCopyrightText: NONE
# SPDX-License-Identifier: CC0-1.0
"""Exercise the publication gates without uploading a release."""
import hashlib
import importlib.util
import json
import os
import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('release', ROOT / 'tools/windows/prepare-release.py')
release = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(release)


class ReleaseTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.folder = Path(temporary.name)
        self.artifacts = self.folder / 'artifacts'
        self.artifacts.mkdir()
        self.source = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()
        environment = patch.dict(os.environ, {'GITHUB_SHA': self.source, 'GITHUB_RUN_ID': '12345'})
        environment.start()
        self.addCleanup(environment.stop)
        self.count = sum(bool(line.strip()) and not line.lstrip().startswith('#')
                         for line in (ROOT / 'src/activities/activities.txt').read_text().splitlines())
        for name in ('package-check.json', 'installer-check.json'):
            (self.artifacts / name).write_text(json.dumps({
                'passed': True, 'native_list_checked': True, 'expected_activities': self.count,
            }))
        sums = []
        for name in ('GCompris-PT-PT-Windows-x64-candidate.exe', 'GCompris-PT-PT-Windows-x64-portable.zip'):
            content = ('fixture ' + name).encode()
            (self.artifacts / name).write_bytes(content)
            sums.append(hashlib.sha256(content).hexdigest() + '  ' + name)
        (self.artifacts / 'SHA256SUMS.txt').write_text('\n'.join(sums))

    def test_exact_verified_package_publishes_identity(self):
        release.prepare(self.folder)
        metadata = json.loads((self.artifacts / 'release.json').read_text())
        self.assertEqual(metadata['activities'], self.count)
        self.assertEqual(metadata['source'], self.source)
        self.assertIn('windows-12345', metadata['url'])

    def test_corrupt_installer_rejected(self):
        (self.artifacts / 'GCompris-PT-PT-Windows-x64-candidate.exe').write_bytes(b'tamper')
        with self.assertRaisesRegex(ValueError, 'Checksum'):
            release.prepare(self.folder)

    def test_failed_installed_check_rejected(self):
        path = self.artifacts / 'installer-check.json'
        report = json.loads(path.read_text())
        report['passed'] = False
        path.write_text(json.dumps(report))
        with self.assertRaisesRegex(ValueError, 'acceptance'):
            release.prepare(self.folder)

    def test_wrong_source_rejected(self):
        with patch.dict(os.environ, {'GITHUB_SHA': '0' * 40}):
            with self.assertRaisesRegex(ValueError, 'source'):
                release.prepare(self.folder)

    def test_missing_activity_rejected(self):
        path = self.artifacts / 'installer-check.json'
        report = json.loads(path.read_text())
        report['expected_activities'] = self.count - 1
        path.write_text(json.dumps(report))
        with self.assertRaisesRegex(ValueError, 'acceptance'):
            release.prepare(self.folder)


if __name__ == '__main__':
    unittest.main()
