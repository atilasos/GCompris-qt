# SPDX-License-Identifier: GPL-3.0-or-later
"""Run the audio auditor against actual compiled resource fixtures."""
import json
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class AudioResourceAudit(unittest.TestCase):
    def test_missing_recordings_and_wrong_formats_are_reported(self):
        with tempfile.TemporaryDirectory() as directory:
            folder = Path(directory)
            (folder / 'voice.ogg').write_bytes(b'OggSfixture')
            (folder / 'bad.ogg').write_bytes(b'not an Ogg recording')
            (folder / 'fixture.qrc').write_text('''<RCC><qresource prefix="/gcompris/data/voices-ogg/pt">
<file alias="alphabet/U0061.ogg">voice.ogg</file>
<file alias="intro/colors.ogg">bad.ogg</file>
</qresource></RCC>''')
            subprocess.run(['/usr/lib/qt6/libexec/rcc', '--binary', str(folder / 'fixture.qrc'),
                            '-o', str(folder / 'fixture.rcc')], check=True)
            output = folder / 'result.json'
            subprocess.run(['python3', str(ROOT / 'tools/audit-pt-pt-audio.py'),
                            '--rcc', str(folder / 'fixture.rcc'), '--output', str(output)], check=True)
            report = json.loads(output.read_text())
            self.assertEqual(report['resource_files'], 2)
            self.assertIn('intro/colors.ogg', report['invalid_ogg'])
            self.assertNotIn('alphabet/U0061.ogg', report['missing']['alphabet'])
            self.assertIn('alphabet/U007A.ogg', report['missing']['alphabet'])
            self.assertIn('intro/compass.ogg', report['missing']['introductions'])
            self.assertIn('alphabet/10.ogg', report['missing']['active_wordset'])
            self.assertNotIn('words/10.ogg', report['missing']['active_wordset'])
            self.assertEqual(report['decode']['status'], 'not-run')


if __name__ == '__main__':
    unittest.main()
