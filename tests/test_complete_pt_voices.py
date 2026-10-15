# SPDX-License-Identifier: GPL-3.0-or-later
"""Test the real resource packaging command, not a synthetic merge dictionary."""
import hashlib
import importlib.util
import json
from pathlib import Path
import shlex
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
RCC = '/usr/lib/qt6/libexec/rcc'


class CompleteVoicesTest(unittest.TestCase):
    def test_packaging_preserves_original_audio_and_selects_complete_rcc(self):
        with tempfile.TemporaryDirectory() as directory:
            folder = Path(directory)
            original = folder / 'voices-pt-original.rcc'
            (folder / 'old.ogg').write_bytes(b'OggSoriginal-recording')
            (folder / 'original.qrc').write_text('''<RCC><qresource prefix="/gcompris/data/voices-ogg/pt">
<file alias="alphabet/U0061.ogg">old.ogg</file></qresource></RCC>''')
            subprocess.run([RCC, '--binary', str(folder / 'original.qrc'), '-o', str(original)], check=True)
            additions = folder / 'additions'
            (additions / 'intro').mkdir(parents=True)
            new = additions / 'intro/polygons.ogg'
            new.write_bytes(b'OggSnew-recording')
            manifest = {'format': 1, 'source_rcc': original.name,
                        'source_rcc_sha256': hashlib.sha256(original.read_bytes()).hexdigest(),
                        'source_files': 1, 'recordings': [{'file': 'intro/polygons.ogg',
                            'sha256': hashlib.sha256(new.read_bytes()).hexdigest(), 'bytes': new.stat().st_size}]}
            (additions / 'manifest.json').write_text(json.dumps(manifest))
            (folder / 'Contents').write_text('oldhash  voices-pt-original.rcc\notherhash  voices-fr-existing.rcc\n')
            utility = folder / 'inventory'
            flags = shlex.split(subprocess.check_output(['pkg-config', '--cflags', '--libs', 'Qt6Core'], text=True))
            subprocess.run(['c++', '-std=c++17', '-fPIC', str(ROOT / 'tools/pt-pt-audio/rcc_inventory.cpp'),
                            *flags, '-o', str(utility)], check=True)
            command = ['python3', str(ROOT / 'tools/pt-pt-audio/complete_voices.py'),
                       '--voices-dir', str(folder), '--additions', str(additions),
                       '--inventory-tool', str(utility), '--rcc-tool', RCC]
            subprocess.run(command, check=True)
            completed = folder / 'voices-pt-2026-10-15-00-00-00.rcc'
            actual = {row['path']: row for row in json.loads(subprocess.check_output([str(utility), str(completed)]))}
            self.assertEqual(len(actual), 2)
            self.assertEqual(actual[':/gcompris/data/voices-ogg/pt/alphabet/U0061.ogg']['sha256'],
                             hashlib.sha256(b'OggSoriginal-recording').hexdigest())
            self.assertEqual(actual[':/gcompris/data/voices-ogg/pt/intro/polygons.ogg']['sha256'],
                             hashlib.sha256(b'OggSnew-recording').hexdigest())
            self.assertIn('otherhash  voices-fr-existing.rcc', (folder / 'Contents').read_text())
            self.assertNotIn('voices-pt-original.rcc', (folder / 'Contents').read_text())
            before = completed.read_bytes()
            subprocess.run(command, check=True)
            self.assertEqual(completed.read_bytes(), before)

            manifest['recordings'][0]['text'] = 'Nova gravação'
            manifest['teacher_review'] = {'recordings': {
                row['file']: {'text': row['text'], 'sha256': row['sha256']}
                for row in manifest['recordings']}}
            (additions / 'manifest.json').write_text(json.dumps(manifest))
            subprocess.run(command, check=True, capture_output=True)
            metadata = json.loads((folder / 'completion.json').read_text())
            self.assertEqual(metadata['pronunciation'], 'approved-new-recordings')
            self.assertEqual(completed.read_bytes(), before)
            manifest['recordings'][0]['text'] = 'Texto alterado depois da aprovação'
            (additions / 'manifest.json').write_text(json.dumps(manifest))
            subprocess.run(command, check=True, capture_output=True)
            metadata = json.loads((folder / 'completion.json').read_text())
            self.assertEqual(metadata['pronunciation'], 'pending-final-teacher-review')
            self.assertEqual(completed.read_bytes(), before)

            new.write_bytes(b'OggSchanged-recording')
            damaged = subprocess.run(command, capture_output=True, text=True)
            self.assertNotEqual(damaged.returncode, 0)
            self.assertIn('Addition recording is missing, damaged or changed', damaged.stderr)
            self.assertEqual(completed.read_bytes(), before)
            new.write_bytes(b'OggSnew-recording')

            manifest['recordings'][0]['file'] = 'alphabet/U0061.ogg'
            (additions / 'manifest.json').write_text(json.dumps(manifest))
            collision = subprocess.run(command, capture_output=True, text=True)
            self.assertNotEqual(collision.returncode, 0)
            self.assertIn('overwrite original recording', collision.stderr)
            self.assertEqual(completed.read_bytes(), before)

            original.write_bytes(original.read_bytes() + b'changed')
            changed_source = subprocess.run(command, capture_output=True, text=True)
            self.assertNotEqual(changed_source.returncode, 0)
            self.assertIn('Original voices RCC differs from pinned source', changed_source.stderr)
            self.assertEqual(completed.read_bytes(), before)

    def test_new_recordings_cover_only_the_32_original_gaps(self):
        baseline = json.loads((ROOT / '.scratch/pt-pt/audio/coverage.json').read_text())
        expected = set().union(*(set(group) for group in baseline['missing'].values()))
        manifest = json.loads((ROOT / 'resources/pt-pt-voices/manifest.json').read_text())
        self.assertEqual(len(expected), 32)
        self.assertEqual({row['file'] for row in manifest['recordings']}, expected)
        for row in manifest['recordings']:
            path = ROOT / 'resources/pt-pt-voices' / row['file']
            with self.subTest(recording=row['file']):
                self.assertEqual(hashlib.sha256(path.read_bytes()).hexdigest(), row['sha256'])
                subprocess.run(['gst-launch-1.0', '-q', 'filesrc', f'location={path}',
                                '!', 'decodebin', '!', 'audioconvert', '!', 'fakesink'], check=True)

    def test_country_and_region_names_match_the_spoken_portuguese_labels(self):
        spec = importlib.util.spec_from_file_location('audit', ROOT / 'tools/audit-pt-pt.py')
        audit = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(audit)
        translations = {(row.get('msgctxt'), row['msgid']): row.get('msgstr')
                        for row in audit.read_po(ROOT / 'poqm/pt/gcompris_qt.po')}
        self.assertEqual(translations[('board1_0|', 'Hauts de France')], 'Altos de França')
        self.assertEqual(translations[('board1_0|', 'Bourgogne-Franche-Comté')], 'Borgonha-Franco-Condado')
        manifest = json.loads((ROOT / 'resources/pt-pt-voices/manifest.json').read_text())
        voices = {row['file']: row['text'] for row in manifest['recordings']}
        self.assertEqual(voices['geography/bahrain.ogg'], 'Barém')
        self.assertEqual(translations[('board9_0|', 'Bahrain')], 'Barém')


if __name__ == '__main__':
    unittest.main()
