# SPDX-License-Identifier: GPL-3.0-or-later
"""Publication failures must leave the previous offline voice package intact."""
import hashlib
import importlib.util
import json
from pathlib import Path
import shlex
import shutil
import subprocess
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('publish_voices', ROOT / 'tools/pt-pt-audio/complete_voices.py')
voices = importlib.util.module_from_spec(spec)
spec.loader.exec_module(voices)
RCC = Path('/usr/lib/qt6/libexec/rcc')


class PublicationTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.tool_directory = tempfile.TemporaryDirectory()
        cls.utility = Path(cls.tool_directory.name) / 'inventory'
        flags = shlex.split(subprocess.check_output(['pkg-config', '--cflags', '--libs', 'Qt6Core'], text=True))
        subprocess.run(['c++', '-std=c++17', '-fPIC', str(ROOT / 'tools/pt-pt-audio/rcc_inventory.cpp'),
                        *flags, '-o', str(cls.utility)], check=True)

    @classmethod
    def tearDownClass(cls):
        cls.tool_directory.cleanup()

    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        folder = Path(self.temporary.name)
        self.additions = folder / 'additions'
        shutil.copytree(ROOT / 'resources/pt-pt-voices', self.additions)
        self.output = folder / 'voices'
        self.output.mkdir()
        samples = ROOT / '.scratch/pt-pt/legacy-word-review/samples'
        for word in ('fawn', 'tick'):
            shutil.copyfile(samples / (word + '-original.ogg'), self.output / (word + '.ogg'))
        (self.output / 'original.qrc').write_text('<RCC><qresource prefix="/gcompris/data/voices-ogg/pt">'
            '<file alias="words/fawn.ogg">fawn.ogg</file><file alias="words/tick.ogg">tick.ogg</file>'
            '</qresource></RCC>', encoding='utf-8')
        original = self.output / 'source.rcc'
        subprocess.run([str(RCC), '--binary', str(self.output / 'original.qrc'), '-o', str(original)], check=True)
        manifest_path = self.additions / 'manifest.json'
        manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
        manifest.update(source_rcc=original.name, source_rcc_sha256=hashlib.sha256(original.read_bytes()).hexdigest(), source_files=2)
        manifest_path.write_text(json.dumps(manifest), encoding='utf-8')
        (self.output / 'Contents').write_bytes(b'oldhash  voices-pt-old.rcc\r\nfrhash  voices-fr.rcc\r\n')
        for name in (voices.OUTPUT, 'completion.json', 'additions-manifest.json',
                     'replacements-manifest.json', 'pt-pt-additions-NOTICE.md'):
            (self.output / name).write_bytes(b'previous package: ' + name.encode())

    def snapshot(self):
        return {p.relative_to(self.output).as_posix(): p.read_bytes()
                for p in self.output.rglob('*') if p.is_file()}

    def complete(self):
        return voices.complete(self.output, self.additions, self.utility, RCC)

    def test_missing_notice_preserves_every_previous_published_byte(self):
        (self.additions / 'NOTICE.md').unlink()
        before = self.snapshot()
        with self.assertRaises(FileNotFoundError):
            self.complete()
        self.assertEqual(self.snapshot(), before)


    def test_copy_error_preserves_every_previous_published_byte(self):
        before = self.snapshot()
        copyfile = shutil.copyfile
        def fail_copy(source, destination, **kwargs):
            if Path(source).name == 'NOTICE.md':
                Path(destination).write_bytes(b'partial notice')
                raise OSError('simulated disk copy failure')
            return copyfile(source, destination, **kwargs)
        with mock.patch.object(voices.shutil, 'copyfile', side_effect=fail_copy):
            with self.assertRaisesRegex(OSError, 'simulated disk copy failure'):
                self.complete()
        self.assertEqual(self.snapshot(), before)

    def test_corrupt_provenance_copy_preserves_previous_package(self):
        before = self.snapshot()
        copyfile = shutil.copyfile
        def corrupt_copy(source, destination, **kwargs):
            result = copyfile(source, destination, **kwargs)
            if Path(source).name == 'NOTICE.md':
                Path(destination).write_bytes(b'corrupt notice')
            return result
        with mock.patch.object(voices.shutil, 'copyfile', side_effect=corrupt_copy):
            with self.assertRaisesRegex(ValueError, 'Staged provenance differs'):
                self.complete()
        self.assertEqual(self.snapshot(), before)

    def test_metadata_write_failure_preserves_previous_package(self):
        before = self.snapshot()
        write_bytes = Path.write_bytes
        def fail_metadata(path, data):
            if path.name == 'completion.json':
                write_bytes(path, b'partial metadata')
                raise OSError('simulated metadata failure')
            return write_bytes(path, data)
        with mock.patch.object(Path, 'write_bytes', fail_metadata):
            with self.assertRaisesRegex(OSError, 'simulated metadata failure'):
                self.complete()
        self.assertEqual(self.snapshot(), before)

    def test_windows_default_newlines_still_publish_lf_contents_and_metadata(self):
        original_open = Path.open
        def windows_open(path, mode='r', buffering=-1, encoding=None, errors=None, newline=None):
            if 'w' in mode and 'b' not in mode and newline is None:
                newline = '\r\n'
            return original_open(path, mode, buffering, encoding, errors, newline)
        # This adapter applies Windows' default text translation on Linux.
        with mock.patch.object(Path, 'open', windows_open):
            self.complete()
        contents = (self.output / 'Contents').read_bytes()
        self.assertNotIn(b'\r', contents)
        self.assertEqual(contents.count(b'\n'), 2)
        self.assertTrue(contents.startswith(b'frhash  voices-fr.rcc\n'))
        self.assertNotIn(b'\r', (self.output / 'completion.json').read_bytes())


class WindowsGitCheckoutTest(unittest.TestCase):
    def test_raw_byte_pinned_texts_keep_exact_hashes_with_crlf_checkout_defaults(self):
        expected = {
            'resources/pt-pt-voices/manifest.json': '7b877e58376bbbbe4c900446f9345e091aa68ab903d56ce4859f24919905170e',
            'resources/pt-pt-voices/replacements.json': '0011530fbe6d086a32a90ac6fc4bab66296492010f046d862c2e597983789a7b',
            'resources/pt-pt-voices/NOTICE.md': '885f026245eae433ceb7e04f55fa957916943e42e95e2da0a1d8105d86cc6a4a',
            '.scratch/pt-pt/legacy-word-review/human-approval.json': '7aaa494997f32a01661e5b6607d305dce353990bb7f4862166c60dc78ff4ad9c',
        }
        with tempfile.TemporaryDirectory() as temporary:
            folder = Path(temporary)
            repo = folder / 'repo'
            repo.mkdir()
            def git(*args):
                return subprocess.run(['git', '-C', str(repo), *args], check=True, capture_output=True)
            git('init', '--quiet')
            git('config', 'core.autocrlf', 'true')
            git('config', 'core.eol', 'crlf')
            for name in ['.gitattributes', *expected]:
                target = repo / name
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes((ROOT / name).read_bytes())
            git('add', '--force', '--', '.gitattributes', *expected)
            checkout = folder / 'checkout'
            git('checkout-index', '--all', '--prefix=' + str(checkout) + '/')
            for name, sha256 in expected.items():
                with self.subTest(path=name):
                    self.assertEqual(hashlib.sha256((checkout / name).read_bytes()).hexdigest(), sha256)

if __name__ == '__main__':
    unittest.main()
