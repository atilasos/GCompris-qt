# SPDX-License-Identifier: GPL-3.0-or-later
"""Exercise lesson checkpoint resumption through CLI subprocess fixtures only."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[2]
LAUNCHER='''import json,os,pathlib,re,sys
args=sys.argv
case=pathlib.Path(args[args.index('--case')+1]).read_text()
words=json.loads(re.search(r'property var expectedWords:\\s*(.*)',case).group(1))
output=pathlib.Path(args[args.index('--output')+1]);output.mkdir(parents=True)
(output/'result.json').write_text(json.dumps({'passed':True,'case_result':{'completed':[{} for word in words]}}))
with pathlib.Path(os.environ['WORD_LESSON_FIXTURE_LOG']).open('a') as log:log.write('launcher\\n')
sys.exit(int(os.environ.get('WORD_LESSON_FIXTURE_EXIT','0')))
'''


class LessonCheckpointTest(unittest.TestCase):
    def setUp(self):
        self.directory=tempfile.TemporaryDirectory(prefix='word-lesson-cli-')
        self.addCleanup(self.directory.cleanup)
        self.root=Path(self.directory.name)
        tests=self.root/'tests/functional_word_letters';tests.mkdir(parents=True)
        for name in ('run.py','corpus.py','hangman.qml'):
            shutil.copy2(ROOT/'tests/functional_word_letters'/name,tests/name)
        for name,content in {'CMakeLists.txt':'fixture','poqm/pt/gcompris_qt.po':'fixture',
            'src/activities/hangman/Hangman.qml':'fixture','build/functional-input/qmldir':'fixture',
            'build/functional-input/libfunctionalinput.so':'fixture',
            'tools/run-native-qml-case.py':LAUNCHER,'full/manifest.json':'{}','sample/manifest.json':'{}'}.items():
            path=self.root/name;path.parent.mkdir(parents=True,exist_ok=True);path.write_text(content)
        resource=self.root/'src/activities/lang/resource';resource.mkdir(parents=True)
        self.resource=resource
        self.entries=[{'image':'one.webp','voice':'voices-$CA/$LOCALE/words/one.$CA'},
                      {'image':'two.webp','voice':'voices-$CA/$LOCALE/words/two.$CA'}]
        self.write_dataset(self.entries)
        (resource/'content-pt.json').write_text(json.dumps({'one.ogg':'chá','two.ogg':'pão'}))
        self.output=self.root/'results';self.log=self.root/'launchers.log'

    def write_dataset(self,entries):
        data=[{'name':'fixture','imgPrefix':'qrc:/fixture/','content':[{'name':'fixture','content':entries}]}]
        for name in ('words.json','words_sample.json'):(self.resource/name).write_text(json.dumps(data))

    def invoke(self,resume=False,exit_code=0):
        command=[sys.executable,str(self.root/'tests/functional_word_letters/run.py'),
            '--full-snapshot',str(self.root/'full'),'--sample-snapshot',str(self.root/'sample'),
            '--output',str(self.output),'--jobs','1']
        if resume:command.append('--resume')
        result=subprocess.run(command,text=True,capture_output=True,
            env=dict(os.environ,WORD_LESSON_FIXTURE_LOG=str(self.log),WORD_LESSON_FIXTURE_EXIT=str(exit_code)))
        self.assertEqual(result.stderr,'')
        return result.returncode

    def test_resume_retains_semantically_identical_json_inputs_but_rechecks_changed_words(self):
        self.assertEqual(self.invoke(),0)
        self.assertEqual(len(self.log.read_text().splitlines()),8)
        # Dictionary insertion order changes without changing any word or mode.
        self.write_dataset(list(reversed(self.entries)))
        self.assertEqual(self.invoke(resume=True),0)
        self.assertEqual(len(self.log.read_text().splitlines()),8)
        translations=self.resource/'content-pt.json'
        translations.write_text(json.dumps({'one.ogg':'chávena','two.ogg':'pão'}))
        self.assertEqual(self.invoke(resume=True),0)
        self.assertEqual(len(self.log.read_text().splitlines()),16)


if __name__=='__main__':unittest.main()
