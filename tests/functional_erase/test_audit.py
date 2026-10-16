# SPDX-License-Identifier: GPL-3.0-or-later
"""A completion receipt must not turn an unchanged screenshot into reveal proof."""
from pathlib import Path
import shutil
import tempfile
import unittest

import audit_evidence
import catalogue_compatibility


class RenderedMaskProof(unittest.TestCase):
    def test_rejects_identical_masked_and_revealed_pixels(self):
        original = (audit_evidence.HERE / 'full/erase_clic-automatic/level-1-masked.png')
        with tempfile.TemporaryDirectory() as directory:
            target = Path(directory)
            shutil.copyfile(original, target / 'level-1-masked.png')
            shutil.copyfile(original, target / 'level-1-revealed.png')
            with self.assertRaises(AssertionError):
                audit_evidence.mask_pixels(target, 1)


class CatalogueScopeProof(unittest.TestCase):
    def test_rejects_english_title_in_exercised_qt_catalogue(self):
        current = (catalogue_compatibility.ROOT / 'poqm/pt/gcompris_qt.po').read_text()
        target = 'msgstr "Carregar ou tocar"'
        self.assertEqual(current.count(target), 1)
        with tempfile.TemporaryDirectory() as directory:
            changed = Path(directory) / 'changed.po'
            changed.write_text(current.replace(target, 'msgstr "Click or tap"'))
            with self.assertRaises(AssertionError):
                catalogue_compatibility.verify(changed)
