# SPDX-License-Identifier: GPL-3.0-or-later
"""Exercise both public CLI boundaries against the authoritative activity list.

A missing executable/case is a sentinel: reaching that later error proves the
ID was accepted without deploying anything or launching an application.
"""
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class ActivityIdentifierBoundary(unittest.TestCase):
    def run_cli(self, tool, activity, folder):
        command = [sys.executable, '-B', str(ROOT / 'tools' / tool),
                   '--binary', str(folder / 'missing-binary'), '--output', str(folder / 'results')]
        if tool == 'smoke-activity.py':
            command += activity if isinstance(activity, list) else [activity]
        else:
            command += ['--activity=' + activity, '--qml-file',
                        str(ROOT / 'src/activities/programmingMaze/ProgrammingMaze.qml'),
                        '--case', str(folder / 'missing-case.qml')]
        return subprocess.run(command, capture_output=True, text=True, timeout=10)

    def test_every_checked_in_activity_id_passes_both_cli_boundaries(self):
        activities = [line.split('#', 1)[0].strip() for line in
                      (ROOT / 'src/activities/activities.txt').read_text().splitlines()]
        activities = [name for name in activities if name]
        self.assertIn('programmingMaze', activities)
        with tempfile.TemporaryDirectory() as directory:
            folder = Path(directory)
            smoke = self.run_cli('smoke-activity.py', activities, folder)
            self.assertEqual(smoke.returncode, 2)
            self.assertIn('Binary and source root must exist', smoke.stderr)
            for activity in activities:
                with self.subTest(activity=activity):
                    native = self.run_cli('run-native-qml-case.py', activity, folder)
                    self.assertEqual(native.returncode, 2)
                    self.assertIn('Binary, case and positive timeout are required', native.stderr)
            self.assertFalse((folder / 'results').exists())

    def test_both_clis_reject_path_traversal_and_unsafe_names_before_deployment(self):
        with tempfile.TemporaryDirectory() as directory:
            folder = Path(directory)
            for activity in ['../outside', 'path/name', 'path\\name', '.', '..', 'two words', 'a;touch', 'x.ogg']:
                for tool in ['smoke-activity.py', 'run-native-qml-case.py']:
                    with self.subTest(activity=activity, tool=tool):
                        result = self.run_cli(tool, activity, folder)
                        self.assertEqual(result.returncode, 2)
                        expected = ('Use a positive duration and activity identifiers' if tool == 'smoke-activity.py'
                                    else 'Invalid activity or QML source path')
                        self.assertIn(expected, result.stderr)
            self.assertFalse((folder / 'results').exists())


if __name__ == '__main__':
    unittest.main()
