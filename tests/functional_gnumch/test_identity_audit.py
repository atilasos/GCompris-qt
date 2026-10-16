# SPDX-License-Identifier: GPL-3.0-or-later
"""Historical input identities must remain verifiable through the audit CLI."""
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ROOT / '.scratch/pt-pt/functional-gnumch'
AUDITOR = ROOT / 'tests/functional_gnumch/audit.py'

class HistoricalInputAudit(unittest.TestCase):
 def test_changed_input_identities_are_rejected_in_each_phase(self):
  with tempfile.TemporaryDirectory(prefix='gnumch-identities-') as tmp:
   evidence = Path(tmp) / 'copied-evidence'
   shutil.copytree(EVIDENCE, evidence, ignore=shutil.ignore_patterns('.native-qml-*'))
   for folder in ('title-red', 'title-green', 'return-green', 'monster-green',
                  'full/gnumch-equality-01', 'final/gnumch-equality-01'):
    file = evidence / folder / 'result.json'
    original = file.read_bytes()
    for field in ('source_sha256', 'portuguese_catalogue_sha256'):
     with self.subTest(folder=folder, field=field):
      data = json.loads(original)
      data[field] = '0' * 64
      file.write_text(json.dumps(data))
      run = subprocess.run([sys.executable, str(AUDITOR), str(evidence)], capture_output=True, text=True, timeout=30)
      self.assertNotEqual(run.returncode, 0, f'Accepted changed {field} in {folder}')
      file.write_bytes(original)

@unittest.skipUnless(shutil.which('docker'), 'Copied-proof isolation requires Docker')
class PortableHistoricalInputs(unittest.TestCase):
 def test_copy_passes_without_original_paths_and_rejects_changed_archives(self):
  image = subprocess.check_output(['docker', 'image', 'inspect', 'python:3.12-slim',
                                   '--format', '{{.Id}}'], text=True).strip()
  with tempfile.TemporaryDirectory(prefix='gnumch-portable-inputs-') as tmp:
   suite = Path(tmp)
   evidence = suite / 'evidence'
   shutil.copytree(EVIDENCE, evidence, ignore=shutil.ignore_patterns('.native-qml-*'))
   for name in ('audit.py', 'oracle.py'):
    shutil.copyfile(AUDITOR.parent / name, suite / name)
   bootstrap = ('import pathlib,runpy,sys; '
                f'assert not pathlib.Path({str(ROOT)!r}).exists(); '
                "sys.path.insert(0,'/suite'); "
                "sys.argv=['/suite/audit.py','/suite/evidence']; "
                "runpy.run_path('/suite/audit.py',run_name='__main__')")
   command = ['docker', 'run', '--rm', '--network', 'none', '--read-only',
              '--cap-drop', 'ALL', '--security-opt', 'no-new-privileges',
              '--user', '1000:1000', '--mount', f'type=bind,src={suite},dst=/suite,readonly',
              image, 'python', '-B', '-c', bootstrap]
   def invoke():
    return subprocess.run(command, capture_output=True, text=True, timeout=30)
   result = invoke()
   self.assertEqual(result.returncode, 0, result.stderr)
   self.assertEqual(json.loads(result.stdout)['total_levels'], 104)
   inputs = json.loads((evidence / 'receipt-inputs.json').read_text())
   targets = ['frozen-source/' + inputs['title-red']['portuguese_catalogue'],
              'frozen-source/' + inputs['final/gnumch-equality-01']['source'],
              'frozen-source/manifest.json']
   for relative in targets:
    with self.subTest(archive=relative):
     file = evidence / relative
     original = file.read_bytes()
     if relative.endswith('manifest.json'):
      data = json.loads(original)
      data[inputs['title-red']['portuguese_catalogue']] = '0' * 64
      file.write_text(json.dumps(data))
     else:
      file.write_bytes(original + b'\n ')
     result = invoke()
     self.assertNotEqual(result.returncode, 0, result.stdout)
     file.write_bytes(original)
   # A real but different historical catalogue must not replace the phase's own.
   file = evidence / 'title-red/result.json'
   data = json.loads(file.read_text())
   data['portuguese_catalogue_sha256'] = json.loads(
       (evidence / 'title-green/result.json').read_text())['portuguese_catalogue_sha256']
   file.write_text(json.dumps(data))
   self.assertNotEqual(invoke().returncode, 0)

if __name__ == '__main__': unittest.main()
