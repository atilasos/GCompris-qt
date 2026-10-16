#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Reject incomplete or altered maze evidence without another Qt campaign."""
import importlib.util
import json
from pathlib import Path
import shutil
import tempfile
import unittest

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
EVIDENCE = ROOT / '.scratch/pt-pt/functional-mazes'
SPEC = importlib.util.spec_from_file_location('maze_evidence_audit', HERE / 'audit.py')
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class EvidenceContract(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        MODULE.audit(EVIDENCE)

    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.copy = Path(self.temporary.name) / 'copied-evidence'
        self.copy.mkdir()
        for name in ['full-settled', 'pointer', 'controls-maze', 'controls-mazeinvisible', 'controls-mazerelative']:
            shutil.copytree(EVIDENCE / name, self.copy / name, ignore=shutil.ignore_patterns('.native-qml-*'))
        for name in ['resource-snapshot.json', 'controls-case.qml']:
            shutil.copyfile(EVIDENCE / name, self.copy / name)

    def alter(self, relative, mutate):
        path = self.copy / relative
        data = json.loads(path.read_text())
        mutate(data)
        path.write_text(json.dumps(data))

    def test_copied_evidence_is_independent_of_original_runtime_paths(self):
        result = MODULE.audit(self.copy)
        self.assertTrue(result['passed'])
        self.assertEqual(result['main_level_completions'], 150)

    def test_missing_level_is_rejected(self):
        self.alter('full-settled/maze-normal/result.json', lambda data: data['case_result']['completed'].pop())
        with self.assertRaises(AssertionError): MODULE.audit(self.copy)

    def test_altered_visible_resource_is_rejected(self):
        path = self.copy / 'controls-maze/door.svg'
        path.chmod(0o600)
        with path.open('ab') as stream: stream.write(b'changed')
        with self.assertRaises(AssertionError): MODULE.audit(self.copy)

    def test_altered_case_is_rejected(self):
        with (self.copy / 'full-settled/maze-normal.qml').open('a') as stream: stream.write('\n// changed\n')
        with self.assertRaises(AssertionError): MODULE.audit(self.copy)

    def test_altered_frozen_source_identity_is_rejected(self):
        self.alter('full-settled/source-identity.json', lambda data: data.update({'src/activities/maze/maze.js': '0' * 64}))
        with self.assertRaises(AssertionError): MODULE.audit(self.copy)


if __name__ == '__main__':
    unittest.main()
