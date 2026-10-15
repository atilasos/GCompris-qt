# SPDX-License-Identifier: GPL-3.0-or-later
"""Check archived evidence ownership through ordinary CLI subprocesses."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
LAUNCHER = '''import json,os,pathlib,sys
args=sys.argv
output=pathlib.Path(args[args.index('--output')+1])
case=pathlib.Path(args[args.index('--case')+1])
pathlib.Path(os.environ['SCALES_FIXTURE_MARKER']).write_text(json.dumps({'case':str(case),'bytes':case.read_text()}))
if output.exists() and any(output.iterdir()):sys.exit(2)
output.mkdir(parents=True,exist_ok=True)
(output/'result.json').write_text('{}')
sys.exit(int(os.environ.get('SCALES_FIXTURE_EXIT','0')))
'''


class ScalesOutputCLI(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix='scales-output-cli-')
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        folder = self.root/'tests/functional_scales'
        folder.mkdir(parents=True)
        shutil.copy2(ROOT/'tests/functional_scales/run.py', folder/'run.py')
        for name in ('controls.qml','gameplay.qml'):
            (folder/name).write_text('fixture __SCALES_ORACLE__ __LEVEL_LIMIT__ __VIRTUAL_KEYBOARD__')
        (folder/'oracle.js').write_text('oracle')
        launcher = self.root/'tools/run-native-qml-case.py'
        launcher.parent.mkdir()
        launcher.write_text(LAUNCHER)
        self.output = self.root/'output'
        self.marker = self.root/'launcher.json'

    def invoke(self, exit_code=0):
        return subprocess.run([sys.executable,str(self.root/'tests/functional_scales/run.py'),
            '--activity','scalesboard','--resource-snapshot',str(self.root/'snapshot'),
            '--output',str(self.output),'--controls'],text=True,capture_output=True,timeout=10,
            env={**os.environ,'SCALES_FIXTURE_MARKER':str(self.marker),'SCALES_FIXTURE_EXIT':str(exit_code)})

    def bytes_in_output(self):
        if self.output.is_file():return {'<file>':self.output.read_bytes()}
        return {path.relative_to(self.output).as_posix():path.read_bytes()
                for path in self.output.rglob('*') if path.is_file()}

    def test_existing_output_is_rejected_before_preparation_and_preserves_every_byte(self):
        for kind in ('archive','empty-directory','file'):
            with self.subTest(kind=kind):
                self.output = self.root/('output-'+kind)
                self.marker = self.root/('launcher-'+kind+'.json')
                if kind == 'file':self.output.write_bytes(b'archived output file\x00')
                else:self.output.mkdir()
                if kind == 'archive':
                    (self.output/'case.qml').write_bytes(b'original case\x00')
                    (self.output/'result.json').write_bytes(b'{"original":true}')
                    nested = self.output/'nested';nested.mkdir()
                    (nested/'screen.bin').write_bytes(bytes(range(256)))
                before = self.bytes_in_output()
                result = self.invoke()
                self.assertEqual(self.bytes_in_output(),before,'All archived bytes must survive refusal')
                self.assertEqual(result.returncode,2,result.stdout+result.stderr)
                self.assertIn('Use a new output directory',result.stderr)
                self.assertFalse(self.marker.exists(),'Existing output must be rejected before launching')
                self.assertFalse((self.root/'build').exists(),'Existing output must be rejected before generating cases')
                if self.output.is_dir():shutil.rmtree(self.output)
                else:self.output.unlink()

    def test_owned_output_preserves_its_private_case_for_success_and_launcher_failure(self):
        generated_paths=[]
        for code in (0,2):
            with self.subTest(exit_code=code):
                self.output = self.root/('owned-'+str(code))
                self.marker = self.root/('launcher-owned-'+str(code)+'.json')
                result = self.invoke(code)
                self.assertEqual(result.returncode,code,result.stdout+result.stderr)
                record = json.loads(self.marker.read_text())
                self.assertEqual((self.output/'case.qml').read_text(),record['bytes'])
                generated = Path(record['case']);generated_paths.append(generated)
                self.assertFalse(generated.exists(),'Private generated case must be cleaned')
                self.assertFalse((self.root/'build').exists(),'No shared per-activity generated case')
                shutil.rmtree(self.output)
        self.assertNotEqual(generated_paths[0],generated_paths[1])


if __name__ == '__main__':unittest.main()
