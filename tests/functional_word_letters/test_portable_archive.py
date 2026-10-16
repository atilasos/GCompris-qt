# SPDX-License-Identifier: GPL-3.0-or-later
"""Audit copied real receipts in Docker with historical paths unavailable."""
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[2]
EVIDENCE=ROOT/'.scratch/pt-pt/functional-word-letters'
OUTPUTS=('hangman-final','hangman-remaining-full','hangman-remaining-sample')
HISTORICAL='/home/proteu/Projetos/GCompris-qt-worktrees/pt-words-letters'


@unittest.skipUnless(shutil.which('docker'),'Portable archive isolation requires Docker')
class PortableArchiveCLI(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.image=subprocess.check_output(['docker','image','inspect','alpine:latest','--format','{{.Id}}'],text=True).strip()

    def setUp(self):
        self.temporary=tempfile.TemporaryDirectory(prefix='hangman-portable-cli-')
        self.addCleanup(self.temporary.cleanup)
        self.suite=Path(self.temporary.name)
        self.evidence=self.suite/'evidence';self.evidence.mkdir()
        archive=json.loads((EVIDENCE/'sealed-inputs/historical/archive.json').read_text())
        shutil.copytree(EVIDENCE/'sealed-inputs/historical',self.evidence/'sealed-inputs/historical')
        shutil.copyfile(EVIDENCE/'corpus.json',self.evidence/'corpus.json')
        for name in OUTPUTS:
            folder=self.evidence/name;folder.mkdir()
            shutil.copyfile(EVIDENCE/name/'summary.json',folder/'summary.json')
            for row in json.loads((folder/'summary.json').read_text()):
                target=folder/row['report'];target.parent.mkdir(parents=True)
                shutil.copyfile(EVIDENCE/name/row['report'],target)
        for relative in archive['cases'].values():
            target=self.evidence/relative;target.parent.mkdir(parents=True,exist_ok=True)
            shutil.copyfile(EVIDENCE/relative,target)
        code=self.suite/'source/tests/functional_word_letters';code.mkdir(parents=True)
        for name in ('aggregate.py','audit.py','corpus.py'):
            shutil.copyfile(ROOT/'tests/functional_word_letters'/name,code/name)
        # Allow the old auditor to reach its absolute-path bug in the red run.
        # The corrected auditor uses the captured corpus in evidence instead.
        resources=self.suite/'source/src/activities/lang/resource';resources.mkdir(parents=True)
        for name in ('content-pt.json','words.json','words_sample.json'):
            shutil.copyfile(ROOT/'src/activities/lang/resource'/name,resources/name)
        self.archive=archive

    def invoke(self):
        script='/suite/source/tests/functional_word_letters/aggregate.py'
        bootstrap=('import pathlib,sys,runpy; '
                   f'assert not pathlib.Path({HISTORICAL!r}).exists(); '
                   "sys.path.insert(0,'/suite/source/tests/functional_word_letters'); "
                   f'sys.argv=[{script!r}]+sys.argv[1:]; runpy.run_path({script!r},run_name="__main__")')
        command=['docker','run','--rm','--network','none','--read-only','--cap-drop','ALL',
                 '--security-opt','no-new-privileges','--user','1000:1000']
        for source,target in [('/usr','/usr'),('/lib','/lib'),('/lib64','/lib64'),(str(self.suite),'/suite')]:
            command+=['--mount',f'type=bind,src={source},dst={target},readonly']
        command+=['--entrypoint','/usr/bin/python3',self.image,'-B','-c',bootstrap]
        command+=['/suite/evidence/'+name for name in OUTPUTS]
        return subprocess.run(command,text=True,capture_output=True,timeout=60)

    def test_copied_archive_passes_with_historical_worktree_inaccessible(self):
        result=self.invoke()
        self.assertEqual(result.returncode,0,result.stderr)
        record=json.loads(result.stdout)
        self.assertTrue(record['passed']);self.assertEqual(record['campaigns'],116)
        self.assertEqual(record['words'],4824)
        self.assertTrue(all(not row['report'].startswith('/') for row in record['receipts']))
        shutil.rmtree(self.suite/'source/src')
        without_current_corpus=self.invoke()
        self.assertEqual(without_current_corpus.returncode,0,without_current_corpus.stderr)

    def test_tampered_archived_inputs_are_rejected(self):
        source=next(iter(self.archive['sources'].values()))['path']
        targets=[next(iter(self.archive['cases'].values())),
                 source+'/src/activities/hangman/Hangman.qml',
                 source+'/build/functional-input/libfunctionalinput.so',
                 source+'/source-manifest.json',
                 next(iter(self.archive['launchers'].values())),
                 self.archive['corpus']['path']]
        for relative in targets:
            with self.subTest(input=relative):
                path=self.evidence/relative;original=path.read_bytes()
                try:
                    path.write_bytes(original+b'\n ')
                    result=self.invoke()
                    self.assertNotEqual(result.returncode,0,result.stdout)
                finally:path.write_bytes(original)


if __name__=='__main__':unittest.main()
