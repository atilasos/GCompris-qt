# SPDX-License-Identifier: GPL-3.0-or-later
import importlib.util
import json
from pathlib import Path
import shutil
import tempfile
import unittest

SPEC=importlib.util.spec_from_file_location('calendar_auditor',Path(__file__).with_name('audit.py'))
MODULE=importlib.util.module_from_spec(SPEC);SPEC.loader.exec_module(MODULE)


class CalendarEvidence(unittest.TestCase):
    def setUp(self):
        self.temporary=tempfile.TemporaryDirectory();self.addCleanup(self.temporary.cleanup)
        self.evidence=Path(self.temporary.name)/'copied';self.evidence.mkdir()
        names=['source-identity.json','resource-snapshot.json','data.json','wav-software-decode.json']
        for activity in MODULE.ACTIVITIES:
            for group in ['full','controls','resources']:
                names.extend([group+'-'+activity,group+'-'+activity+'.qml'])
        for stem,case in [('title','title-visible.qml'),('month-navigation','month-navigation.qml'),('orthography-diagnostic','orthography-diagnostic.qml')]:
            names.extend([stem+'-red',stem+'-green',case])
        for name in names:
            source=MODULE.HERE/name;target=self.evidence/name
            if source.is_dir():shutil.copytree(source,target)
            else:shutil.copyfile(source,target)

    def alter(self,path,change):
        target=self.evidence/path;data=json.loads(target.read_text());change(data);target.write_text(json.dumps(data))

    def test_relocated_without_original_worktree(self):
        result=MODULE.audit(self.evidence);self.assertEqual(result['questions'],70)

    def test_missing_question_rejected(self):
        self.alter('full-calendar/result.json',lambda d:d['case_result']['answered'].pop())
        with self.assertRaises(AssertionError):MODULE.audit(self.evidence)

    def test_changed_receipt_source_and_catalogue_rejected(self):
        for key in ['source_sha256','portuguese_catalogue_sha256']:
            target=self.evidence/'full-calendar/result.json';original=target.read_bytes()
            self.alter('full-calendar/result.json',lambda d:d.update({key:'0'*64}))
            with self.assertRaises(AssertionError):MODULE.audit(self.evidence)
            target.write_bytes(original)

    def test_changed_archived_case_rejected(self):
        target=self.evidence/'full-calendar.qml';target.write_bytes(target.read_bytes()+b'changed')
        with self.assertRaises(AssertionError):MODULE.audit(self.evidence)

    def test_changed_qrc_resource_rejected(self):
        target=self.evidence/'resources-calendar/resources/src/activities/calendar/calendar_dataset.js'
        target.chmod(0o600);target.write_bytes(target.read_bytes()+b'changed')
        with self.assertRaises(AssertionError):MODULE.audit(self.evidence)

    def test_missing_source_inventory_rejected(self):
        self.alter('source-identity.json',lambda d:d['files'].pop(MODULE.QML))
        with self.assertRaises(AssertionError):MODULE.audit(self.evidence)


if __name__=='__main__':unittest.main()
