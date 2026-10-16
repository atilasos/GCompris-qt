# SPDX-License-Identifier: GPL-3.0-or-later
"""Exercise publication against a real Git source and concurrent readers."""
import subprocess
import tempfile
import threading
import unittest
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
from unittest.mock import patch

import phase


class FrozenSourceTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        subprocess.run(['git', 'init', '-q', str(self.root)], check=True)
        (self.root / 'CMakeLists.txt').write_text('immutable source\n')
        subprocess.run(['git', 'add', '.'], cwd=self.root, check=True)
        subprocess.run(['git', '-c', 'user.name=Fixture', '-c', 'user.email=fixture@example.invalid',
                        'commit', '-qm', 'source'], cwd=self.root, check=True)
        self.revision = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=self.root, text=True).strip()
        self.root_patch = patch.object(phase, 'ROOT', self.root)
        self.root_patch.start()
        self.addCleanup(self.root_patch.stop)

    def test_concurrent_freeze_never_reads_an_unfinished_write(self):
        writing, release = threading.Event(), threading.Event()
        original = Path.write_bytes
        lock = threading.Lock()
        paused = False

        def write(path, data):
            nonlocal paused
            with lock:
                pause = path.name == 'CMakeLists.txt' and not paused
                if pause:
                    paused = True
            if pause:
                with path.open('wb') as stream:
                    writing.set()
                    if not release.wait(10):
                        raise TimeoutError('test did not release paused source writer')
                    return stream.write(data)
            return original(path, data)

        with patch.object(Path, 'write_bytes', write), ThreadPoolExecutor(2) as pool:
            first = pool.submit(phase.freeze, self.revision)
            self.assertTrue(writing.wait(10))
            second = pool.submit(phase.freeze, self.revision)
            try:
                second_path = second.result(timeout=10)
            finally:
                release.set()
            self.assertEqual(first.result(timeout=10), second_path)
        self.assertEqual((second_path / 'CMakeLists.txt').read_text(), 'immutable source\n')
        manifest = (second_path / 'source-manifest.json').read_bytes()
        self.assertEqual(phase.freeze(self.revision), second_path)
        self.assertEqual((second_path / 'source-manifest.json').read_bytes(), manifest)

    def test_interrupted_preparation_is_not_published_and_can_retry(self):
        original = Path.write_bytes

        def fail(path, data):
            if path.name == 'CMakeLists.txt':
                original(path, data[:3])
                raise OSError('interrupted source write')
            return original(path, data)

        with patch.object(Path, 'write_bytes', fail):
            with self.assertRaisesRegex(OSError, 'interrupted source write'):
                phase.freeze(self.revision)
        output = self.root / 'build/functional-sharing/sources' / self.revision
        self.assertFalse(output.exists())
        self.assertEqual((phase.freeze(self.revision) / 'CMakeLists.txt').read_text(), 'immutable source\n')

    def test_corrupt_published_source_is_rejected_without_resealing(self):
        output = phase.freeze(self.revision)
        manifest = (output / 'source-manifest.json').read_bytes()
        (output / 'CMakeLists.txt').write_text('partial')
        with self.assertRaises((AssertionError, ValueError)):
            phase.freeze(self.revision)
        self.assertEqual((output / 'source-manifest.json').read_bytes(), manifest)


if __name__ == '__main__':
    unittest.main()
