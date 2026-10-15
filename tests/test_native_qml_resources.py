# SPDX-License-Identifier: GPL-3.0-or-later
import importlib.util
from pathlib import Path
import tempfile
import json
import shutil
import os
from unittest.mock import patch
import unittest

SPEC = importlib.util.spec_from_file_location('resources', Path(__file__).resolve().parents[1] / 'tools/native_qml_resources.py')
resources = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(resources)


class ResourceSnapshotTests(unittest.TestCase):
    def test_snapshot_copies_binary_share_and_local_qml_without_source_links(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            build = root / 'build'
            binary = build / 'bin/gcompris-qt'
            binary.parent.mkdir(parents=True)
            binary.write_bytes(b'fixture executable')
            external = root / 'external'
            external.mkdir()
            (external / 'voice.ogg').write_bytes(b'voice fixture')
            share = build / 'share/gcompris-qt'
            (share / 'rcc').mkdir(parents=True)
            (share / 'translations').mkdir()
            (share / 'rcc/core.rcc').write_bytes(b'rcc fixture')
            (share / 'voices').symlink_to(external, target_is_directory=True)
            qml = build / 'lib/qml/Local/Test'
            qml.mkdir(parents=True)
            (qml / 'qmldir').write_text('module Local.Test\n')
            snapshot = root / 'snapshot'
            resources.create_snapshot(binary, snapshot)
            (external / 'voice.ogg').write_bytes(b'changed afterwards')
            binary.write_bytes(b'changed binary')
            (qml / 'qmldir').unlink()
            resources.verify_snapshot(snapshot)
            self.assertEqual((snapshot / 'bin/gcompris-qt').read_bytes(), b'fixture executable')
            self.assertEqual((snapshot / 'share/gcompris-qt/voices/voice.ogg').read_bytes(), b'voice fixture')
            self.assertTrue((snapshot / 'lib/qml/Local/Test/qmldir').is_file())
            self.assertTrue((snapshot / 'share/gcompris-qt/translations').is_dir())
            self.assertFalse(any(path.is_symlink() for path in snapshot.rglob('*')))


    def test_verification_rejects_tampered_file_manifest_and_symlink(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            binary = root / 'build/bin/gcompris-qt'
            binary.parent.mkdir(parents=True)
            binary.write_bytes(b'fixture executable')
            (root / 'build/share/gcompris-qt').mkdir(parents=True)
            snapshot = root / 'snapshot'
            resources.create_snapshot(binary, snapshot)
            copied = snapshot / 'bin/gcompris-qt'
            copied.write_bytes(b'tampered')
            with self.assertRaisesRegex(RuntimeError, 'manifest'):
                resources.verify_snapshot(snapshot)
            copied.write_bytes(b'fixture executable')
            manifest_path = snapshot / 'manifest.json'
            manifest = json.loads(manifest_path.read_text())
            manifest['files']['bin/gcompris-qt'] = '0' * 64
            manifest_path.write_text(json.dumps(manifest))
            with self.assertRaisesRegex(RuntimeError, 'manifest'):
                resources.verify_snapshot(snapshot)
            copied.unlink()
            copied.symlink_to(binary)
            with self.assertRaisesRegex(ValueError, 'symlinks'):
                resources.verify_snapshot(snapshot)

    def test_source_timestamp_change_during_copy_is_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            binary = root / 'build/bin/gcompris-qt'
            binary.parent.mkdir(parents=True)
            binary.write_bytes(b'fixture executable')
            (root / 'build/share/gcompris-qt').mkdir(parents=True)
            copy = shutil.copy2

            def copy_then_touch(source, target, **kwargs):
                result = copy(source, target, **kwargs)
                stat = source.stat()
                os.utime(source, ns=(stat.st_atime_ns, stat.st_mtime_ns + 1000000000))
                return result

            with patch.object(shutil, 'copy2', side_effect=copy_then_touch):
                with self.assertRaisesRegex(RuntimeError, 'changed while copying'):
                    resources.create_snapshot(binary, root / 'snapshot')

    def test_source_changes_during_copy_are_rejected_and_partial_output_removed(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            binary = root / 'build/bin/gcompris-qt'
            binary.parent.mkdir(parents=True)
            binary.write_bytes(b'fixture executable')
            (root / 'build/share/gcompris-qt').mkdir(parents=True)
            snapshot = root / 'snapshot'
            copy = shutil.copy2

            def copy_then_change(source, target, **kwargs):
                result = copy(source, target, **kwargs)
                source.write_bytes(b'changed during copy')
                return result

            with patch.object(shutil, 'copy2', side_effect=copy_then_change):
                with self.assertRaisesRegex(RuntimeError, 'changed while copying'):
                    resources.create_snapshot(binary, snapshot)
            self.assertFalse(snapshot.exists())


if __name__ == '__main__':
    unittest.main()
