# SPDX-License-Identifier: GPL-3.0-or-later
import hashlib
import importlib.util
from pathlib import Path
import tempfile
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('candidate_assets', ROOT / 'tools/windows/fetch-assets.py')
assets = importlib.util.module_from_spec(spec)
spec.loader.exec_module(assets)


class LockedAssetsTest(unittest.TestCase):
    def test_mismatched_download_cannot_become_packaged_resource(self):
        with tempfile.TemporaryDirectory() as temporary:
            target = Path(temporary) / 'data3'
            source = Path(temporary) / 'source.rcc'
            source.write_bytes(b'changed resource')
            entry = {'path': 'words/words.rcc', 'url': source.as_uri(),
                     'sha256': hashlib.sha256(b'approved resource').hexdigest(), 'bytes': 17}
            with self.assertRaises(ValueError):
                assets.fetch([entry], target)
            self.assertFalse((target / 'words/words.rcc').exists())

    def test_verified_asset_is_available_at_the_runtime_relative_path(self):
        with tempfile.TemporaryDirectory() as temporary:
            source = Path(temporary) / 'source.rcc'
            content = b'approved resource'
            source.write_bytes(content)
            entry = {'path': 'voices-ogg/voices-pt.rcc', 'url': source.as_uri(),
                     'sha256': hashlib.sha256(content).hexdigest(), 'bytes': len(content)}
            target = Path(temporary) / 'data3'
            assets.fetch([entry], target)
            self.assertEqual((target / entry['path']).read_bytes(), content)

class PackagedRuntimeTest(unittest.TestCase):
    def test_empty_stage_cannot_pass_offline_readiness(self):
        runtime_spec = importlib.util.spec_from_file_location('verify_package', ROOT / 'tools/windows/verify-package.py')
        runtime = importlib.util.module_from_spec(runtime_spec)
        runtime_spec.loader.exec_module(runtime)
        with tempfile.TemporaryDirectory() as temporary:
            result = runtime.check(Path(temporary), ['click_on_letter'], [])
            self.assertFalse(result['passed'])
            self.assertIn('bin/GCompris.exe', result['missing'])
            self.assertIn('share/GCompris/rcc/click_on_letter.rcc', result['missing'])


class WindowsTranslationTest(unittest.TestCase):
    @unittest.skipUnless(sys.platform == 'linux' and Path('/usr/lib/qt6/bin/lconvert').exists(),
                         'Native QTranslator probe runs against the Linux Qt installation')
    def test_windows_catalog_uses_european_zero_one_two_plural_rules(self):
        # Reuse the native QTranslator probe, then replace its QM via the Windows
        # build's own converter. This checks the produced artifact, not flag text.
        from test_translation_build import TranslationBuildTest
        fixture = TranslationBuildTest('test_european_portuguese_compiled_zero_one_two_plurals')
        self.addCleanup(fixture.doCleanups)
        fixture.setUp()
        module_spec = importlib.util.spec_from_file_location('compile_portuguese', ROOT / 'tools/windows/compile-portuguese.py')
        compiler = importlib.util.module_from_spec(module_spec)
        module_spec.loader.exec_module(compiler)
        compiler.compile_catalog(Path('/usr/lib/qt6'), fixture.catalog, fixture.ts, fixture.qm)
        output = fixture.run_command([str(fixture.build / 'probe'), str(fixture.qm)])
        self.assertEqual(output.splitlines(), ['0 maçãs', '1 maçã', '2 maçãs'])


if __name__ == '__main__':
    unittest.main()
