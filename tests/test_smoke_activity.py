# SPDX-License-Identifier: GPL-3.0-or-later
"""Test the public runner CLI with controllable executable and deployed assets."""
from pathlib import Path
import json
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class StartupRunner(unittest.TestCase):
    def test_resuming_preserves_results_and_refuses_changed_deployed_resources(self):
        with tempfile.TemporaryDirectory() as directory:
            folder = Path(directory)
            (folder / 'bin').mkdir()
            binary = folder / 'bin/gcompris-qt'
            binary.write_text('''#!/usr/bin/env python3
import sys,time
name=sys.argv[sys.argv.index('--launch')+1]
print('qml: Start activity '+name+'/Game.qml at level -1',flush=True)
if name=='broken': print("qrc:/game.js:56: TypeError: Cannot read property 'subLevels' of undefined",flush=True)
time.sleep(5)
''')
            binary.chmod(0o755)
            source = folder / 'source'; source.mkdir()
            (source / 'game.qml').write_text('initial source')
            deployed = folder / 'share/gcompris-qt/rcc'; deployed.mkdir(parents=True)
            (deployed / 'game.rcc').write_bytes(b'initial RCC bytes')
            output = folder / 'results'
            command = ['python3', str(ROOT / 'tools/smoke-activity.py'), '--binary', str(binary),
                       '--source-root', str(source), '--output', str(output), '--seconds', '0.2', 'programmingMaze', 'broken']
            first = subprocess.run(command, capture_output=True, text=True)
            self.assertEqual(first.returncode, 1, first.stderr)
            rows = json.loads((output / 'results.json').read_text())
            self.assertEqual([row['startup_check'] for row in rows], ['passed', 'failed'])
            self.assertIn('subLevels', rows[1]['qml_errors'][0])
            before = (output / 'programmingMaze.log').stat().st_mtime_ns
            resumed = subprocess.run(command + ['--resume'], capture_output=True, text=True)
            self.assertEqual(resumed.returncode, 1, resumed.stderr)
            self.assertEqual((output / 'programmingMaze.log').stat().st_mtime_ns, before)
            (source / 'game.qml').write_text('changed source')
            changed_source = subprocess.run(command + ['--resume'], capture_output=True, text=True)
            self.assertNotEqual(changed_source.returncode, 0)
            self.assertIn('fingerprint', changed_source.stderr)
            (source / 'game.qml').write_text('initial source')
            (deployed / 'game.rcc').write_bytes(b'new RCC bytes')
            changed = subprocess.run(command + ['--resume'], capture_output=True, text=True)
            self.assertNotEqual(changed.returncode, 0)
            self.assertIn('fingerprint', changed.stderr)
            self.assertEqual((output / 'programmingMaze.log').stat().st_mtime_ns, before)

    def test_resume_refuses_changed_checked_in_voice_resources(self):
        with tempfile.TemporaryDirectory() as directory:
            folder = Path(directory)
            binary = folder / 'bin/gcompris-qt'
            binary.parent.mkdir()
            binary.write_text("#!/usr/bin/env python3\nimport time\nprint('qml: Start activity gletters/Game.qml at level -1',flush=True)\ntime.sleep(5)\n")
            binary.chmod(0o755)
            source = folder / 'source'
            (source / 'src').mkdir(parents=True)
            (source / 'src/Game.qml').write_text('unchanged game source')
            voice = source / 'resources/pt-pt-voices/alphabet/U00E7.ogg'
            voice.parent.mkdir(parents=True)
            voice.write_bytes(b'original checked-in voice')
            command = ['python3', str(ROOT / 'tools/smoke-activity.py'), '--binary', str(binary),
                       '--source-root', str(source), '--output', str(folder / 'results'), '--seconds', '0.2', 'gletters']
            first = subprocess.run(command, capture_output=True, text=True)
            self.assertEqual(first.returncode, 0, first.stderr)
            voice.write_bytes(b'revised checked-in voice')
            resumed = subprocess.run(command + ['--resume'], capture_output=True, text=True)
            self.assertNotEqual(resumed.returncode, 0)
            self.assertIn('fingerprint', resumed.stderr)


if __name__ == '__main__':
    unittest.main()
