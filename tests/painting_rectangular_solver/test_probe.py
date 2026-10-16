# SPDX-License-Identifier: GPL-3.0-or-later
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

MODULE = Path(__file__).resolve().parent


class PhysicalProbe(unittest.TestCase):
    def run_probe(self, module, optimized=False):
        return subprocess.run([sys.executable, '-I', *(['-O'] if optimized else []),
                               str(module/'probe.py')], cwd=module.parent,
                              capture_output=True, text=True)

    def test_copied_probe_recomputes_all_seams_with_normal_and_optimized_python(self):
        with tempfile.TemporaryDirectory() as directory:
            copied = Path(directory)/'painting_rectangular_solver'
            shutil.copytree(MODULE, copied, ignore=shutil.ignore_patterns('__pycache__'))
            for optimized in (False, True):
                run = self.run_probe(copied, optimized)
                self.assertEqual(run.returncode, 0, run.stderr)
                result = json.loads(run.stdout)
                self.assertEqual(result['result']['diagnostics']['grid'], [3, 2])
                self.assertEqual(result['result']['diagnostics']['adjacencies'], 7)
                self.assertEqual(result['result']['diagnostics']['permutations_per_strip'], 720)
                self.assertEqual(len(result['result']['mapping']), 6)
                self.assertEqual(result['source_sha256']['solver.py'],
                                 hashlib.sha256((copied/'solver.py').read_bytes()).hexdigest())
                # No frozen mapping is read as truth: probe recomputes from six physical files.
                self.assertNotIn(str(MODULE), run.stdout)

    def test_pixel_geometry_and_resealed_manifest_tampering_are_rejected(self):
        for target, reseal in [('piece-0.webp', False), ('public-geometry.json', False),
                               ('public-geometry.json', True), ('manifest.json', False)]:
            with self.subTest(target=target, reseal=reseal), tempfile.TemporaryDirectory() as directory:
                copied = Path(directory)/'painting_rectangular_solver'
                shutil.copytree(MODULE, copied, ignore=shutil.ignore_patterns('__pycache__'))
                base = copied/'fixtures/bazille'
                path = base/target
                path.write_bytes(path.read_bytes()+b' ')
                if reseal:
                    manifest = json.loads((base/'manifest.json').read_text())
                    manifest['files'][target] = hashlib.sha256(path.read_bytes()).hexdigest()
                    (base/'manifest.json').write_text(json.dumps(manifest))
                for optimized in (False, True):
                    run = self.run_probe(copied, optimized)
                    self.assertNotEqual(run.returncode, 0)
                    self.assertIn('identity mismatch', run.stderr)


if __name__ == '__main__':
    unittest.main()
