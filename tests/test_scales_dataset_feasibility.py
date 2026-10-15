# SPDX-License-Identifier: GPL-3.0-or-later
import importlib.util
from pathlib import Path
import shutil
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('scales_datasets', ROOT / 'tests/functional_scales/check_datasets.py')
DATASETS = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(DATASETS)


class DatasetFeasibility(unittest.TestCase):
    def test_all_twenty_datasets_have_reachable_targets(self):
        report = DATASETS.audit()
        self.assertEqual(sum(row['targets_reachable'] for row in report.values()), 666)

    def test_original_level_thirty_cannot_balance_five(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for activity in DATASETS.EXPECTED:
                source = ROOT / 'src/activities' / activity / 'resource'
                for path in source.glob('*/Data.qml'):
                    target = root / path.relative_to(ROOT)
                    target.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copyfile(path, target)
            path = root / 'src/activities/scalesboard/resource/6/Data.qml'
            fixed = '[[1, "1"], [8, "8"], [2, "2"], [2, "2"], [7, "7"], [9, "9"], [10, "10"]]'
            original = fixed.replace('[2, "2"], [7', '[1, "1"], [7')
            self.assertEqual(path.read_text().count(fixed), 1)
            path.write_text(path.read_text().replace(fixed, original))
            with self.assertRaisesRegex(AssertionError, r'row 8: unreachable.*5'):
                DATASETS.audit(root)
