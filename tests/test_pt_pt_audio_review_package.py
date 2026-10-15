# SPDX-License-Identifier: GPL-3.0-or-later
import csv
import hashlib
import io
import json
from pathlib import Path
import subprocess
import shutil
import sys
import tempfile
import unittest
import zipfile

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / 'tools/pt-pt-audio/package-review.py'
SOURCE = ROOT / 'resources/pt-pt-voices'


class AudioReviewPackageTests(unittest.TestCase):
    def test_zip_contains_only_32_manifest_recordings_and_pending_review(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / 'review.zip'
            subprocess.run([sys.executable, str(SCRIPT), '--source', str(SOURCE),
                            '--output', str(output)], check=True, capture_output=True)
            manifest_bytes = (SOURCE / 'manifest.json').read_bytes()
            manifest = json.loads(manifest_bytes)
            recordings = manifest['recordings']
            self.assertEqual(len(recordings), 32)
            with zipfile.ZipFile(output) as archive:
                self.assertEqual(set(archive.namelist()),
                                 {row['file'] for row in recordings}
                                 | {'index.html', 'manifest.json', 'NOTICE.md', 'review.csv'})
                self.assertEqual(len(archive.namelist()), 36)
                self.assertEqual(archive.read('manifest.json'), manifest_bytes)
                self.assertEqual(archive.read('NOTICE.md'), (SOURCE / 'NOTICE.md').read_bytes())
                for row in recordings:
                    self.assertEqual(hashlib.sha256(archive.read(row['file'])).hexdigest(), row['sha256'])
                review = list(csv.DictReader(io.StringIO(archive.read('review.csv').decode('utf-8-sig')), delimiter=';'))
                self.assertEqual(len(review), 32)
                self.assertEqual([row['ficheiro'] for row in review], [row['file'] for row in recordings])
                self.assertEqual([row['transcricao'] for row in review], [row['text'] for row in recordings])
                self.assertEqual({row['estado'] for row in review}, {'pending'})
                self.assertEqual({row['grupo'] for row in review}, {'Caracteres', 'Topónimos', 'Instruções'})
                self.assertEqual([row['numero'] for row in review], [f'{number:02d}' for number in range(1, 33)])
                self.assertTrue(all(row['correcoes'] == '' for row in review))
                html = archive.read('index.html').decode('utf-8')
                self.assertEqual(html.count('<audio '), 32)
                self.assertEqual(html.count(' controls'), 32)
                self.assertIn('lang="pt-PT"', html)
                self.assertNotIn('<script', html)
                for row in recordings:
                    self.assertIn('src="' + row['file'] + '"', html)


    def test_transcriptions_are_escaped_in_html_and_preserved_in_csv(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / 'voices'
            shutil.copytree(SOURCE, source)
            manifest_path = source / 'manifest.json'
            manifest = json.loads(manifest_path.read_text())
            transcription = '<img src=x onerror="alert(1)"> & voz'
            manifest['recordings'][0]['text'] = transcription
            manifest_path.write_text(json.dumps(manifest, ensure_ascii=False))
            output = root / 'review.zip'
            subprocess.run([sys.executable, str(SCRIPT), '--source', str(source),
                            '--output', str(output)], check=True, capture_output=True)
            with zipfile.ZipFile(output) as archive:
                html = archive.read('index.html').decode('utf-8')
                self.assertIn('&lt;img src=x onerror=&quot;alert(1)&quot;&gt; &amp; voz', html)
                self.assertNotIn('<img', html)
                review = list(csv.DictReader(io.StringIO(archive.read('review.csv').decode('utf-8-sig')), delimiter=';'))
                self.assertEqual(review[0]['transcricao'], transcription)

    def test_invalid_manifest_or_modified_audio_produces_no_zip(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / 'voices'
            shutil.copytree(SOURCE, source)
            manifest_path = source / 'manifest.json'
            original = json.loads(manifest_path.read_text())
            for problem in ['count', 'hash', 'duplicate', 'outside']:
                with self.subTest(problem=problem):
                    manifest = json.loads(json.dumps(original))
                    if problem == 'count':
                        manifest['recordings'].pop()
                    elif problem == 'hash':
                        manifest['recordings'][0]['sha256'] = '0' * 64
                    elif problem == 'duplicate':
                        manifest['recordings'][1] = manifest['recordings'][0]
                    else:
                        manifest['recordings'][0]['file'] = '../outside.ogg'
                    manifest_path.write_text(json.dumps(manifest))
                    output = root / (problem + '.zip')
                    result = subprocess.run([sys.executable, str(SCRIPT), '--source', str(source),
                                             '--output', str(output)], capture_output=True)
                    self.assertNotEqual(result.returncode, 0)
                    self.assertFalse(output.exists())


if __name__ == '__main__':
    unittest.main()
