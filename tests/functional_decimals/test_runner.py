# SPDX-License-Identifier: GPL-3.0-or-later
"""Exercise the runner CLI against a normal subprocess launcher fixture."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
LAUNCHER = '''import json, os, pathlib, sys
output = pathlib.Path(sys.argv[sys.argv.index('--output')+1])
output.mkdir(parents=True)
report = {'passed': os.environ['DECIMAL_FIXTURE_QT_PASSED']=='yes',
          'case_result': {'completed': []}}
(output/'result.json').write_text(json.dumps(report))
print('Normal launcher fixture finished and wrote its report', flush=True)
sys.exit(int(os.environ['DECIMAL_FIXTURE_LAUNCHER_EXIT']))
'''


class RunnerAcceptanceTest(unittest.TestCase):
    def invoke_runner(self, launcher_exit, qt_passed):
        with tempfile.TemporaryDirectory(prefix='decimal-runner-boundary-') as directory:
            project = Path(directory)
            tests = project/'tests/functional_decimals'
            tests.mkdir(parents=True)
            for name in ('run.py','inventory.py','audit.py','controls.qml'):
                shutil.copyfile(ROOT/'tests/functional_decimals'/name, tests/name)
            # Dataset inventory remains real and read-only; no Qt deployment exists.
            (project/'src').symlink_to(ROOT/'src', target_is_directory=True)
            (project/'tools').mkdir()
            (project/'tools/run-native-qml-case.py').write_text(LAUNCHER)
            output = project/'results'
            env = dict(os.environ, DECIMAL_FIXTURE_LAUNCHER_EXIT=str(launcher_exit),
                       DECIMAL_FIXTURE_QT_PASSED='yes' if qt_passed else 'no')
            result = subprocess.run([sys.executable,str(tests/'run.py'),
                '--snapshot',str(project/'unused-snapshot'),'--output',str(output),
                '--activity','learn_decimals','--case','controls','--jobs','1'],
                env=env,text=True,capture_output=True)
            self.assertEqual(result.stderr,'')
            summary = json.loads((output/'summary.json').read_text())
            self.assertEqual(len(summary),1)
            self.assertEqual(summary[0]['exit_code'],launcher_exit)
            print('RUNNER_FIXTURE',json.dumps({'launcher_exit':launcher_exit,
                'qt_passed':qt_passed,'runner_exit':result.returncode,
                'summary_passed':summary[0]['passed']}),flush=True)
            return result.returncode, summary[0]['passed']

    def test_green_json_cannot_override_failed_launcher(self):
        self.assertEqual(self.invoke_runner(1,True),(1,False))

    def test_zero_launcher_exit_cannot_override_failed_qt_report(self):
        self.assertEqual(self.invoke_runner(0,False),(1,False))

    def test_zero_launcher_exit_and_green_report_are_accepted(self):
        self.assertEqual(self.invoke_runner(0,True),(0,True))


if __name__=='__main__':
    unittest.main()
