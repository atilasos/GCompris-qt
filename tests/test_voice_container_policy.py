# SPDX-License-Identifier: GPL-3.0-or-later
"""Different real Qt RCC layouts require explicitly pinned complete pairs."""
import copy
import hashlib
import importlib.util
import json
from pathlib import Path
import shlex
import shutil
import subprocess
import tempfile
import unittest
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('verify_package', ROOT / 'tools/windows/verify-package.py')
package = importlib.util.module_from_spec(spec)
spec.loader.exec_module(package)


def identity(path):
    return {'path': path.name, 'bytes': path.stat().st_size,
            'sha256': hashlib.sha256(path.read_bytes()).hexdigest()}


class ContainerPolicyTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temporary = tempfile.TemporaryDirectory()
        cls.folder = Path(cls.temporary.name)
        utility = cls.folder / 'inventory'
        flags = shlex.split(subprocess.check_output(['pkg-config', '--cflags', '--libs', 'Qt6Core'], text=True))
        subprocess.run(['c++', '-std=c++17', '-fPIC', str(ROOT / 'tools/pt-pt-audio/rcc_inventory.cpp'),
                        *flags, '-o', str(utility)], check=True)
        cls.variants = []
        inventories = []
        for i in range(64):
            (cls.folder / f'voice{i:03}.ogg').write_bytes(b'OggS' + bytes([i]) * 31)
        for label, order in [('forward', range(64)), ('reverse', reversed(range(64)))]:
            folder = cls.folder / label
            folder.mkdir()
            qrc = ET.Element('RCC')
            resource = ET.SubElement(qrc, 'qresource', prefix='/gcompris/data/voices-ogg/pt')
            for i in order:
                ET.SubElement(resource, 'file', alias=f'intro/voice{i:03}.ogg').text = str(cls.folder / f'voice{i:03}.ogg')
            ET.ElementTree(qrc).write(folder / 'input.qrc')
            rcc = folder / 'completed.rcc'
            subprocess.run(['/usr/lib/qt6/libexec/rcc', '--binary', '--no-compress', '--format-version', '1',
                            str(folder / 'input.qrc'), '-o', str(rcc)], check=True)
            rows = json.loads(subprocess.check_output([str(utility), str(rcc)]))
            inventories.append({r['path']: r['sha256'] for r in rows})
            (folder / 'Contents').write_bytes((hashlib.md5(rcc.read_bytes()).hexdigest() + '  completed.rcc\n').encode())
            cls.variants.append({'name': label, 'files': [identity(rcc), identity(folder / 'Contents')]})
        cls.inventories = inventories

    @classmethod
    def tearDownClass(cls):
        cls.temporary.cleanup()

    def setUp(self):
        self.output = tempfile.TemporaryDirectory()
        self.addCleanup(self.output.cleanup)
        self.stage = Path(self.output.name)
        self.voices = self.stage / 'share/GCompris/rcc/data3/voices-ogg'
        self.voices.mkdir(parents=True)
        (self.voices / 'provenance.json').write_bytes(b'fixed approval')
        self.policy = {'format': 2, 'total_files': 64, 'substitutions': [],
                       'files': self.variants[0]['files'], 'provenance_files': [identity(self.voices / 'provenance.json')]}

    def install(self, index):
        for row in self.variants[index]['files']:
            shutil.copyfile(self.folder / self.variants[index]['name'] / row['path'], self.voices / row['path'])
        return dict(self.policy, files=copy.deepcopy(self.variants[index]['files']))

    def check(self, completion):
        return package.check(self.stage, [], [], completion=completion, voice_policy=self.policy,
                             voice_container_variants=self.variants)

    def test_same_qt_resources_in_distinct_pinned_containers_are_accepted(self):
        self.assertEqual(self.inventories[0], self.inventories[1])
        self.assertEqual(len(self.inventories[0]), 64)
        self.assertNotEqual(self.variants[0]['files'][0]['sha256'], self.variants[1]['files'][0]['sha256'])
        for index in (0, 1):
            with self.subTest(index=index):
                self.assertEqual(self.check(self.install(index))['corrupt'], [])

    def test_equal_content_does_not_approve_an_unlisted_container(self):
        completion = self.install(1)
        result = package.check(self.stage, [], [], completion=completion, voice_policy=self.policy,
                               voice_container_variants=self.variants[:1])
        self.assertIn('voice-completion-manifest', result['corrupt'])

    def test_mixed_pair_is_rejected_even_when_both_components_are_known(self):
        completion = self.install(0)
        shutil.copyfile(self.folder / 'reverse/Contents', self.voices / 'Contents')
        completion['files'][1] = self.variants[1]['files'][1]
        self.assertIn('voice-completion-manifest', self.check(completion)['corrupt'])

    def test_tamper_and_coherent_reseal_are_rejected(self):
        completion = self.install(1)
        path = self.voices / 'completed.rcc'
        path.write_bytes(path.read_bytes() + b'changed')
        self.assertIn('share/GCompris/rcc/data3/voices-ogg/completed.rcc', self.check(completion)['corrupt'])
        completion['files'][0] = identity(path)
        self.assertIn('voice-completion-manifest', self.check(completion)['corrupt'])
        completion = self.install(1)
        completion['total_files'] = 65
        self.assertIn('voice-completion-manifest', self.check(completion)['corrupt'])


if __name__ == '__main__':
    unittest.main()
