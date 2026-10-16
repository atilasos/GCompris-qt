# SPDX-License-Identifier: GPL-3.0-or-later
import hashlib
import json
from pathlib import Path
import tempfile
import unittest
from phase import verify_source


class FrozenNativeInputs(unittest.TestCase):
    def setUp(self):
        self.directory=tempfile.TemporaryDirectory();self.addCleanup(self.directory.cleanup);self.root=Path(self.directory.name)
        (self.root/'input.qml').write_text('visible original\n');self.manifest={'revision':'a'*40,'files':{'input.qml':hashlib.sha256((self.root/'input.qml').read_bytes()).hexdigest()}}
        (self.root/'source-manifest.json').write_text(json.dumps(self.manifest))

    def test_original_files_are_verified(self):self.assertEqual(verify_source(self.root),self.manifest)

    def test_extra_input_is_rejected(self):
        (self.root/'extra.qml').write_text('unrecorded')
        with self.assertRaises(AssertionError):verify_source(self.root)

    def test_changed_original_input_is_rejected(self):
        (self.root/'input.qml').write_text('changed')
        with self.assertRaises(AssertionError):verify_source(self.root)

    def test_source_path_escape_is_rejected(self):
        self.manifest['files']={'../outside.qml':'0'*64};(self.root/'source-manifest.json').write_text(json.dumps(self.manifest))
        with self.assertRaises(AssertionError):verify_source(self.root)

    def test_symlink_to_unsealed_input_is_rejected(self):
        (self.root/'input.qml').rename(self.root/'actual.qml');(self.root/'input.qml').symlink_to('actual.qml')
        with self.assertRaises(AssertionError):verify_source(self.root)
