# SPDX-License-Identifier: GPL-3.0-or-later
"""Exact approval boundaries and the distribution policy, without synthesis."""
import copy
import hashlib
import importlib.util
import json
from pathlib import Path
import shutil
import shlex
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]

def load(name, path):
    spec = importlib.util.spec_from_file_location(name, ROOT / path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

completion = load('completion', 'tools/pt-pt-audio/complete_voices.py')
package = load('package', 'tools/windows/verify-package.py')

class ApprovedLegacyWords(unittest.TestCase):
    def test_approved_names_replace_only_the_two_legacy_labels(self):
        words = json.loads((ROOT / 'src/activities/lang/resource/content-pt.json').read_text())
        self.assertEqual(words['fawn.ogg'], 'cervato')
        self.assertEqual(words['tick.ogg'], 'carraça')

class ApprovedReplacementBoundary(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.additions = Path(self.temporary.name) / 'additions'
        shutil.copytree(ROOT / 'resources/pt-pt-voices', self.additions)
        self.expected = {completion.PREFIX + name: row['original_sha256']
                         for name, row in completion.APPROVED_LEGACY.items()}

    def mutate_manifest(self, action):
        path = self.additions / 'replacements.json'
        data = json.loads(path.read_text())
        action(data)
        path.write_text(json.dumps(data))

    def test_exact_two_approved_replacements_are_accepted(self):
        rows = completion.approved_replacements(self.additions, self.expected)
        self.assertEqual({r['file'] for r in rows}, {'words/fawn.ogg', 'words/tick.ogg'})

    def test_third_unapproved_substitution_is_rejected(self):
        self.mutate_manifest(lambda d: d['recordings'].append(dict(d['recordings'][0], file='words/other.ogg')))
        with self.assertRaisesRegex(ValueError, 'two allowlisted'):
            completion.approved_replacements(self.additions, self.expected)

    def test_changed_approval_wav_text_original_and_missing_recording_are_rejected(self):
        for field in ('human_approval_sha256', 'wav_sha256', 'text', 'original_sha256', 'missing'):
            with self.subTest(field=field):
                path = self.additions / 'replacements.json'
                path.write_bytes((ROOT / 'resources/pt-pt-voices/replacements.json').read_bytes())
                if field == 'human_approval_sha256':
                    self.mutate_manifest(lambda d: d.update(human_approval_sha256='0' * 64))
                elif field == 'missing':
                    (self.additions / 'words/fawn.ogg').unlink()
                else:
                    self.mutate_manifest(lambda d: d['recordings'][0].update({field: 'changed'}))
                with self.assertRaises(ValueError):
                    completion.approved_replacements(self.additions, self.expected)

class PinnedCompletionPolicy(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.stage = Path(self.temporary.name)
        self.voices = self.stage / 'share/GCompris/rcc/data3/voices-ogg'
        self.voices.mkdir(parents=True)
        def entry(name, data):
            (self.voices / name).write_bytes(data)
            return {'path': name, 'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}
        original = entry('original.rcc', b'original')
        files = [entry('completed.rcc', b'completed'), entry('Contents', b'new index')]
        provenance = [entry('replacements-manifest.json', b'exact provenance')]
        self.entries = [dict(original, path='voices-ogg/original.rcc')]
        self.policy = {'format': 2, 'source_rcc': 'original.rcc', 'source_rcc_sha256': original['sha256'],
                       'original_files': 1578, 'added_files': 32, 'total_files': 1610,
                       'original_bytes_preserved': False, 'preserved_original_files': 1576,
                       'replaced_files': 2, 'substitutions': [{'file': 'words/fawn.ogg'}, {'file': 'words/tick.ogg'}],
                       'files': files, 'provenance_files': provenance}

    def check(self, result):
        return package.check(self.stage, [], self.entries, completion=result, voice_policy=self.policy)

    def test_original_pinned_policy_accepts_physical_bytes(self):
        self.assertEqual(self.check(copy.deepcopy(self.policy))['corrupt'], [])

    def test_third_substitution_and_resealed_hash_and_absent_completion_are_rejected(self):
        altered = copy.deepcopy(self.policy)
        altered['substitutions'].append({'file': 'words/third.ogg'})
        self.assertIn('voice-completion-manifest', self.check(altered)['corrupt'])
        altered = copy.deepcopy(self.policy)
        (self.voices / 'completed.rcc').write_bytes(b'forged')
        altered['files'][0].update(bytes=6, sha256=hashlib.sha256(b'forged').hexdigest())
        self.assertIn('voice-completion-manifest', self.check(altered)['corrupt'])
        self.assertIn('voice-completion-manifest', self.check(None)['corrupt'])

    def test_missing_or_corrupt_physical_provenance_and_rcc_are_rejected(self):
        (self.voices / 'replacements-manifest.json').write_bytes(b'changed')
        self.assertIn('share/GCompris/rcc/data3/voices-ogg/replacements-manifest.json', self.check(self.policy)['corrupt'])
        (self.voices / 'completed.rcc').unlink()
        self.assertIn('share/GCompris/rcc/data3/voices-ogg/completed.rcc', self.check(self.policy)['missing'])

class RealLegacyRcc(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temporary = tempfile.TemporaryDirectory()
        cls.folder = Path(cls.temporary.name)
        cls.utility = cls.folder / 'inventory'
        flags = shlex.split(subprocess.check_output(['pkg-config', '--cflags', '--libs', 'Qt6Core'], text=True))
        subprocess.run(['c++', '-std=c++17', '-fPIC', str(ROOT / 'tools/pt-pt-audio/rcc_inventory.cpp'),
                        *flags, '-o', str(cls.utility)], check=True)

    @classmethod
    def tearDownClass(cls):
        cls.temporary.cleanup()

    def test_real_rcc_allows_only_two_substitutions_preserves_additions_and_refuses_damage(self):
        folder = self.folder
        additions = folder / 'additions'
        shutil.copytree(ROOT / 'resources/pt-pt-voices', additions)
        voices = folder / 'voices'
        voices.mkdir()
        samples = ROOT / '.scratch/pt-pt/legacy-word-review/samples'
        for word in ('fawn', 'tick'):
            shutil.copyfile(samples / (word + '-original.ogg'), voices / (word + '.ogg'))
        (voices / 'old.ogg').write_bytes(b'OggSuntouched')
        (voices / 'original.qrc').write_text('<RCC><qresource prefix="/gcompris/data/voices-ogg/pt">'
            '<file alias="words/fawn.ogg">fawn.ogg</file><file alias="words/tick.ogg">tick.ogg</file>'
            '<file alias="alphabet/old.ogg">old.ogg</file></qresource></RCC>')
        original = voices / 'source.rcc'
        subprocess.run(['/usr/lib/qt6/libexec/rcc', '--binary', str(voices / 'original.qrc'), '-o', str(original)], check=True)
        original_bytes = original.read_bytes()
        (voices / 'Contents').write_text('oldhash  voices-pt-original.rcc\nfrhash  voices-fr.rcc\n')
        manifest_path = additions / 'manifest.json'
        manifest = json.loads(manifest_path.read_text())
        manifest.update(source_rcc=original.name, source_rcc_sha256=hashlib.sha256(original_bytes).hexdigest(), source_files=3)
        manifest_path.write_text(json.dumps(manifest))
        result = completion.complete(voices, additions, self.utility, Path('/usr/lib/qt6/libexec/rcc'))
        self.assertEqual((result['added_files'], result['replaced_files'], result['preserved_original_files'], result['total_files']), (32, 2, 1, 35))
        self.assertFalse(result['original_bytes_preserved'])
        self.assertEqual(original.read_bytes(), original_bytes)
        actual = {r['path']: r['sha256'] for r in completion.inventory(self.utility, voices / completion.OUTPUT)}
        for row in manifest['recordings']:
            self.assertEqual(actual[completion.PREFIX + row['file']], row['sha256'])
        before = {p.name: p.read_bytes() for p in (voices / completion.OUTPUT, voices / 'Contents', voices / 'completion.json')}
        for damage in ('changed32', 'missing32', 'missingReplacement', 'third', 'remove32', 'resealed32'):
            with self.subTest(damage=damage):
                shutil.rmtree(additions)
                shutil.copytree(ROOT / 'resources/pt-pt-voices', additions)
                manifest_path.write_text(json.dumps(manifest))
                new = additions / manifest['recordings'][0]['file']
                if damage == 'changed32': new.write_bytes(b'OggSchanged')
                elif damage == 'missing32': new.unlink()
                elif damage == 'missingReplacement': (additions / 'words/fawn.ogg').unlink()
                elif damage == 'remove32':
                    altered = copy.deepcopy(manifest)
                    altered['recordings'].pop()
                    manifest_path.write_text(json.dumps(altered))
                elif damage == 'resealed32':
                    altered = copy.deepcopy(manifest)
                    new.write_bytes(b'OggSchanged')
                    row = altered['recordings'][0]
                    row.update(sha256=hashlib.sha256(new.read_bytes()).hexdigest(), bytes=new.stat().st_size)
                    altered['teacher_review']['recordings'][row['file']]['sha256'] = row['sha256']
                    manifest_path.write_text(json.dumps(altered))
                else:
                    path = additions / 'replacements.json'
                    altered = json.loads(path.read_text())
                    altered['recordings'].append(dict(altered['recordings'][0], file='words/third.ogg'))
                    path.write_text(json.dumps(altered))
                with self.assertRaises(ValueError):
                    completion.complete(voices, additions, self.utility, Path('/usr/lib/qt6/libexec/rcc'))
                for name, data in before.items(): self.assertEqual((voices / name).read_bytes(), data)

class EncodingApprovalBoundary(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        sys.path.insert(0, str(ROOT / 'tools/pt-pt-audio'))
        try:
            cls.encoder = load('approved_encoder', 'tools/pt-pt-audio/encode_approved_legacy.py')
        finally:
            sys.path.pop(0)

    def test_changed_wav_and_approval_refused_before_output_created(self):
        with tempfile.TemporaryDirectory() as temporary:
            folder = Path(temporary)
            samples = folder / 'samples'
            shutil.copytree(ROOT / '.scratch/pt-pt/legacy-word-review/samples', samples)
            approval = ROOT / '.scratch/pt-pt/legacy-word-review/human-approval.json'
            (samples / 'fawn-proposta.wav').write_bytes(b'changed WAV')
            with self.assertRaisesRegex(ValueError, 'WAV bytes changed'):
                self.encoder.encode(approval, samples, folder / 'output')
            self.assertFalse((folder / 'output').exists())
            forged = folder / 'approval.json'
            forged.write_bytes(approval.read_bytes() + b' ')
            with self.assertRaisesRegex(ValueError, 'approval identity'):
                self.encoder.encode(forged, samples, folder / 'output')
            self.assertFalse((folder / 'output').exists())

    def test_existing_and_dangling_symlink_outputs_refused_without_writes(self):
        with tempfile.TemporaryDirectory() as temporary:
            folder = Path(temporary)
            existing = folder / 'existing'
            existing.mkdir()
            marker = existing / 'marker'
            marker.write_bytes(b'preserve')
            link = folder / 'link'
            link.symlink_to(folder / 'missing')
            for output in (existing, link):
                with self.subTest(output=output), self.assertRaisesRegex(ValueError, 'New encoding output'):
                    self.encoder.encode(Path('absent'), Path('absent'), output)
            self.assertEqual(marker.read_bytes(), b'preserve')
            self.assertFalse((folder / 'missing').exists())

if __name__ == '__main__':
    unittest.main()
