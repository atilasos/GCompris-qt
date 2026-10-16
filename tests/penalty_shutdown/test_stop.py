# SPDX-License-Identifier: GPL-3.0-or-later
"""Exercise the real matrix CLI with a finite, non-Qt supervisor fixture."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
HEALTHY = dict(signals=[], native_exit_code=0, identity_observed=True,
               cmdline_matches_binary=True, gdb_pid_namespace='pid:[1]',
               qt_pid_namespace='pid:[1]')


class MatrixStop(unittest.TestCase):
    def run_fixture(self, changes=None, failed_at=1, wrapper=0):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            tests = root / 'tests/penalty_shutdown'
            tests.mkdir(parents=True)
            shutil.copyfile(ROOT / 'tests/penalty_shutdown/run.py', tests / 'run.py')
            (tests / 'gdb-observe.py').write_text('# fixture, never executed\n')
            (tests / 'phase.py').write_text(
                'from pathlib import Path\nROOT=Path(__file__).resolve().parents[2]\n'
                'def freeze(revision):\n'
                ' return ROOT/"sources"/("baseline" if revision.startswith("597") else "final")\n')
            history = root / '.scratch/pt-pt/penalty-shutdown/history/penalty-complete'
            history.mkdir(parents=True)
            (history / 'result.json').write_text(json.dumps({'case_result': {'levels': list(range(9))}}))
            snapshot = root / 'snapshot'
            snapshot.mkdir()
            (snapshot / 'manifest.json').write_text('{}')
            for phase in ('baseline', 'final'):
                tools = root / 'sources' / phase / 'tools'
                tools.mkdir(parents=True)
                (tools / 'run-native-qml-case.py').write_text(
                    "    container = None\n'--network', 'none', '--read-only'\n")
                (tools / 'native_qml_resources.py').write_text('# fixture\n')
                (tools / 'run-native-qml-supervised.py').write_text('''import json,os,sys
from pathlib import Path
out=Path(sys.argv[sys.argv.index('--output')+1]);out.mkdir()
ledger=Path(os.environ['FIXTURE_LEDGER'])
names=ledger.read_text().splitlines() if ledger.exists() else []
names.append(out.name);ledger.write_text('\\n'.join(names)+'\\n')
status=json.loads(os.environ['FIXTURE_HEALTHY'])
failed=len(names)==int(os.environ['FIXTURE_FAILED_AT'])
if failed:
 for key,value in json.loads(os.environ['FIXTURE_CHANGES']).items():
  if value is None:status.pop(key,None)
  else:status[key]=value
for name,data in [('inferior-status.json',status),('result.json',{}),('launcher-status.json',{})]:
 (out/name).write_text(json.dumps(data))
sys.exit(int(os.environ['FIXTURE_WRAPPER']) if failed else 0)
''')
            ledger = root / 'launches'
            env = dict(os.environ, FIXTURE_LEDGER=str(ledger),
                       FIXTURE_HEALTHY=json.dumps(HEALTHY),
                       FIXTURE_CHANGES=json.dumps(changes or {}),
                       FIXTURE_FAILED_AT=str(failed_at), FIXTURE_WRAPPER=str(wrapper))
            output = root / 'output'
            completed = subprocess.run([sys.executable, str(tests / 'run.py'),
                                       '--snapshot', str(snapshot), '--output', str(output)],
                                      env=env, capture_output=True, text=True)
            self.assertTrue((output / 'observations.json').is_file(), completed.stderr)
            observations = json.loads((output / 'observations.json').read_text())
            return completed.returncode, ledger.read_text().splitlines(), observations

    def test_sigsegv_with_successful_wrapper_stops_both_phase_loops(self):
        code, launches, observations = self.run_fixture({'signals': ['SIGSEGV'], 'native_exit_code': None})
        self.assertEqual(code, 1)
        self.assertEqual(launches, ['baseline-bare'])
        self.assertEqual(observations['actual'], 1)

    def test_failed_inferior_or_identity_never_starts_a_later_probe(self):
        failures = [({'native_exit_code': 139}, 0), ({'native_exit_code': 1}, 0),
                    ({'signals': ['SIGABRT']}, 0), ({'identity_observed': None}, 0),
                    ({'cmdline_matches_binary': False}, 0),
                    ({'gdb_pid_namespace': 'pid:[2]'}, 0),
                    ({'gdb_pid_namespace': None, 'qt_pid_namespace': None}, 0),
                    ({'signals': None}, 0), ({}, 1)]
        for changes, wrapper in failures:
            with self.subTest(changes=changes, wrapper=wrapper):
                code, launches, observations = self.run_fixture(changes, failed_at=3, wrapper=wrapper)
                self.assertEqual(code, 1)
                self.assertEqual(launches, ['baseline-bare', 'baseline-retained', 'baseline-logged'])
                self.assertEqual(observations['actual'], 3)

    def test_healthy_fixture_runs_exactly_the_six_planned_probes(self):
        code, launches, observations = self.run_fixture(failed_at=99)
        self.assertEqual(code, 0)
        self.assertEqual(launches, ['baseline-bare', 'baseline-retained', 'baseline-logged',
                                  'final-bare', 'final-retained', 'final-logged'])
        self.assertEqual(observations['actual'], 6)


if __name__ == '__main__':
    unittest.main()
