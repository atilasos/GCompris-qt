#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Portable completed-proof checks and independently resealed corruption attacks."""
import contextlib
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE))
import audit


class EvidenceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temporary=tempfile.TemporaryDirectory(prefix='association-proof-copy-')
        cls.root=Path(cls.temporary.name)/'proof'
        shutil.copytree(audit.DEFAULT,cls.root)
        cls.bin=Path(cls.temporary.name)/'auditor';cls.bin.mkdir()
        for name in ('audit.py','archive.py','decode.py'):shutil.copyfile(HERE/name,cls.bin/name)

    @classmethod
    def tearDownClass(cls):cls.temporary.cleanup()

    @contextlib.contextmanager
    def corrupt(self,relative,transform):
        path=self.root/relative;original=path.read_bytes();capture=self.root/'capture.json';before=capture.read_bytes()
        archive_manifest=self.root/'archive/manifest.json';before_archive=archive_manifest.read_bytes()
        try:
            path.write_bytes(transform(original))
            # Attack updates the local manifest too; the independently pinned seal must reject it.
            manifest=json.loads(before)
            if relative.startswith('archive/files/'):
                local=json.loads(before_archive);local['files'][relative[len('archive/files/'):]]={'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'bytes':path.stat().st_size}
                archive_manifest.write_text(json.dumps(local,indent=2)+'\n')
                manifest['files']['archive/manifest.json']={'sha256':hashlib.sha256(archive_manifest.read_bytes()).hexdigest(),'bytes':archive_manifest.stat().st_size}
            if relative in manifest['files']:
                manifest['files'][relative]={'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'bytes':path.stat().st_size}
                capture.write_text(json.dumps(manifest,indent=2)+'\n')
            yield
        finally:path.write_bytes(original);capture.write_bytes(before);archive_manifest.write_bytes(before_archive)

    def reject_json(self,path,transform):
        with self.corrupt(path,lambda data:json.dumps(transform(json.loads(data))).encode()):
            with self.assertRaises(AssertionError):audit.verify(self.root)

    def test_independent_copy_without_git_or_original_paths(self):
        completed=subprocess.run([sys.executable,str(self.bin/'audit.py'),'--evidence',str(self.root)],cwd='/',text=True,capture_output=True)
        self.assertEqual(completed.returncode,0,completed.stderr)
        report=json.loads(completed.stdout)
        self.assertEqual((report['boards'],report['associations'],report['natural_bonus']),(25,119,21))
        self.assertEqual(report['native_positive_cases'],14)

    def test_reseal_catalogue(self):
        with self.corrupt('archive/files/poqm/pt/gcompris_qt.po',lambda data:data.replace(b'oveiro',b'ovario')):
            with self.assertRaises(AssertionError):audit.verify(self.root)

    def test_reseal_product(self):
        with self.corrupt('archive/files/src/activities/babymatch/DragListItem.qml',lambda data:data+b'\n// altered\n'):
            with self.assertRaises(AssertionError):audit.verify(self.root)

    def test_reseal_case(self):
        with self.corrupt('archive/files/tests/functional_association/complete.qml',lambda data:data.replace(b'targetLevels: 7',b'targetLevels: 1')):
            with self.assertRaises(AssertionError):audit.verify(self.root)

    def test_reseal_answer(self):
        def change(data):data['case_result']['boards'][0]['pieces'][0]['target']['x']+=200;return data
        self.reject_json('final/imagename-complete/result.json',change)

    def test_reseal_visible_geometry(self):
        def change(data):data['case_result']['boards'][0]['observed']['circles'][0]['x']+=200;return data
        self.reject_json('final/babyshapes-complete/result.json',change)

    def test_reseal_empty_campaign(self):
        def change(data):data['case_result']['boards']=[];data['case_result']['wins']=0;return data
        self.reject_json('final/babymatch-complete/result.json',change)

    def test_reseal_postwait_status(self):
        def change(data):data['exit_code']=143;return data
        self.reject_json('final/imagename-complete/launcher-status.json',change)

    def test_reseal_outer_exit(self):
        def change(data):data['exit_code']=143;return data
        self.reject_json('final-tool.json',change)

    def test_reseal_pixel_capture(self):
        from io import BytesIO
        from PIL import Image
        def change(data):
            image=Image.open(BytesIO(data));image.putpixel((10,10),(0,0,0,255));out=BytesIO();image.save(out,format='PNG');return out.getvalue()
        with self.corrupt('final/imagename-complete/level-1-board-0-question.png',change):
            with self.assertRaises(AssertionError):audit.verify(self.root)

    def test_optimisation_rejected(self):
        completed=subprocess.run([sys.executable,'-O',str(self.bin/'audit.py'),'--evidence',str(self.root)],capture_output=True,text=True)
        self.assertNotEqual(completed.returncode,0)
        self.assertIn('without optimisation',completed.stderr)

    def test_visible_name_oracle_is_independent_of_target_order(self):
        oracle={'semantic':{'names':{'eggpot.svg':'oveiro'}}}
        observed={'circles':[{'x':10,'y':10},{'x':30,'y':10}],'labels':[{'text':'oveiro','x':30,'y':30},{'text':'ovo','x':10,'y':30}]}
        self.assertEqual(audit.expected('imagename','images/eggpot.svg',observed,oracle),{'x':30,'y':10})
        observed['circles'].reverse()
        self.assertEqual(audit.expected('imagename','images/eggpot.svg',observed,oracle),{'x':30,'y':10})

    def test_silhouette_oracle_uses_drawn_image_not_order(self):
        observed={'circles':[{'x':10,'y':20},{'x':100,'y':20}],'backgrounds':[{'image':'triangle.svg','x':100,'y':20},{'image':'circle.svg','x':10,'y':20}]}
        oracle={'silhouettes':{'piece.svg':{'target':'triangle.svg'}}}
        self.assertEqual(audit.expected('babyshapes','piece.svg',observed,oracle),{'x':100,'y':20})


if __name__=='__main__':unittest.main()
