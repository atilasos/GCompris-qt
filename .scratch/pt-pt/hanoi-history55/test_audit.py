import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[3]
EVIDENCE = ROOT / '.scratch/pt-pt/functional-hanoi'
SPEC = importlib.util.spec_from_file_location('historical_hanoi', EVIDENCE / 'audit.py')
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class HistoricalAudit(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.copy = Path(self.temp.name)
        for name in MODULE.CASES:
            shutil.copytree(EVIDENCE / name, self.copy / name)

    def test_original_34_artifacts_survive_unrelated_catalogue_change(self):
        original = json.loads(subprocess.check_output([
            'git', '-C', str(ROOT), 'show', '1c737b60b:.scratch/pt-pt/functional-hanoi/index.json']))
        current = MODULE.audit(self.copy)
        self.assertEqual(current['artifact_sha256'], original['artifact_sha256'])
        self.assertEqual(len(current['cases']), 6)

    def test_altered_resource_is_rejected(self):
        with (self.copy / 'controls-real-settled/disc_support.svg').open('ab') as stream:
            stream.write(b'altered')
        with self.assertRaises(AssertionError): MODULE.audit(self.copy)

    def test_receipt_with_changed_case_identity_is_rejected(self):
        path = self.copy / 'classic-visual-order/result.json'
        receipt = json.loads(path.read_text())
        receipt['case_sha256'] = '0' * 64
        path.write_text(json.dumps(receipt))
        with self.assertRaises(AssertionError): MODULE.audit(self.copy)


if __name__ == '__main__':
    unittest.main()
