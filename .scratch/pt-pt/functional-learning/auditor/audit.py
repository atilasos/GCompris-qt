#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Audit the original supervised Linux learning receipts without current checkout inputs."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import xml.etree.ElementTree as ET
from PIL import Image
from archive import verify as archive_verify
from audit_data import audit as data_audit
from oracles import quantity

SOURCE='f7d88df532b778b2a54826abbec0f13f79b1f40b'
ARCHIVE='4bf989a00e0c00bf10d3fcd82fd5923cb85ac98ca2e5e66f90a9f4a82fff9ed4'
RESOURCE_SHA='9305a18e04a7a368ee778c320d7ab6b3c61e797fecb4de83c754997237750232'
DEFAULT=Path(__file__).resolve().parents[2]/'.scratch/pt-pt/functional-learning'
NAMES=('learn_digits','learn_additions','learn_subtractions')


def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()


def receipt(root,name,source,manifest,case,activity):
    directory=root/'final'/name;result=json.loads((directory/'result.json').read_text())
    status=json.loads((directory/'launcher-status.json').read_text())
    process=json.loads((root/'final'/(name+'.process.json')).read_text())
    assert process['case']==name and process['supervisor_exit']==0
    assert status['format']==1 and status['kind']=='observed-subprocess-exit' and status['exit_code']==0
    assert status['native_receipt_sha256']==sha(directory/'result.json')
    assert status['launcher_sha256']==result['runner_sha256']==sha(source/'tools/run-native-qml-case.py')
    assert status['case_sha256']==result['case_sha256']==sha(source/'tests/functional_learning'/case)
    assert result['source_sha256']==sha(source/'src/activities/learn_digits/Learn_digits.qml')
    assert result['portuguese_catalogue_sha256']==sha(source/'poqm/pt/gcompris_qt.po')
    assert result['passed'] and result['exit_code']==0 and not result['timeout'] and not result['qml_errors']
    assert result['activity']==activity and result['locale']=='pt_PT' and result['network']=='docker-none' and result['private_file_ownership_verified']
    snapshot=json.loads((root/'archive/snapshot-manifest.json').read_text())
    expected=dict(snapshot['files'])
    expected['share/gcompris-qt/rcc/learn_digits.rcc']=result['private_rcc_sha256']
    expected['share/gcompris-qt/translations/gcompris_qt_pt.qm']=result['private_qm_sha256']
    assert result['resource_files_sha256']==expected and len(expected)==269
    assert result['resource_manifest_sha256']==manifest['snapshot_manifest_sha256']
    assert result['binary_sha256']==expected['bin/gcompris-qt']
    assert result['case_result']['failures']==0 and result['case_result']['passes']==2
    for screenshot in result['screenshots']:assert sha(directory/screenshot['file'])==screenshot['sha256']
    return result['case_result'],directory


def verify(root,locked=True):
    assert sha(root/'archive/manifest.json')==ARCHIVE
    manifest=archive_verify(root/'archive');assert manifest['source_commit']==SOURCE
    source=root/'archive/files'
    if locked:
        lock=json.loads((root/'lock.json').read_text());assert lock['source_commit']==SOURCE and lock['archive_sha256']==ARCHIVE
        for relative,digest in lock['files'].items():assert sha(root/relative)==digest,relative
    datasets=data_audit(source)
    resources=json.loads((root/'resources.json').read_text());assert sha(root/'resources.json')==RESOURCE_SHA and len(resources)==33
    assert sha(root/'resource-exporter.cpp')=='e792721d65615028e513b7902e865d2f2856ea3fba3cef3d8cf95c16e59d31af'
    hands=json.loads((source/'tests/functional_learning/hands-oracle.json').read_text())
    by_md5={entry['md5']:entry for entry in hands};assert sorted(entry['count'] for entry in hands)==list(range(10))
    svg_by_md5={}
    for record in resources:
        path=root/'resources'/record['file'];assert sha(path)==record['sha256'] and path.stat().st_size==record['bytes']
        relative=record['resource'].removeprefix(':/gcompris/')
        if relative.startswith('src/'):
            assert sha(source/relative)==record['sha256']
        if record['file'].startswith(('dots-','hands-')):
            md5=hashlib.md5(path.read_bytes()).hexdigest()
            if record['file'].startswith('dots-'):
                count=sum(e.tag.endswith('}circle') for e in ET.parse(path).iter())
            else:
                entry=by_md5[md5];assert entry['sha256']==record['sha256'];count=entry['count']
            svg_by_md5[md5]=count
        if path.suffix in ('.wav','.ogg'):
            decoded=record['decoded'];assert 0<decoded['peak_pcm16']<=32768 and decoded['frames']>0 and decoded['sample_rate']>0 and decoded['channels'] in (1,2)
            assert abs(decoded['duration']-decoded['frames']/decoded['sample_rate'])<1e-8
    totals={'levels':0,'questions':0,'wrong':0,'natural_bonus':0,'pixel_images':0,'supervised_cases':0,'decoded_audio':12,'snapshot_files':269}
    routes=[]
    for activity in NAMES:
        for mode in ((1,2,3) if activity=='learn_digits' else (1,)):
            name=activity+'-gameplay-'+str(mode)
            case,directory=receipt(root,name,source,manifest,'mode-'+str(mode)+'.qml',activity);totals['supervised_cases']+=1
            expected_levels=datasets[activity];completed=case['completed'];count=sum(len(level['questionsArray']) for level in expected_levels)
            assert case['representation']==mode and case['wrong']==len(completed)==count and case['wins']==len(expected_levels)
            for level_number,level in enumerate(expected_levels,1):
                rows=[row for row in completed if row['level']==level_number]
                assert len(rows)==len(level['questionsArray']) and sorted(row['question'] for row in rows)==list(range(1,len(rows)+1))
                seen=[]
                for row in rows:
                    target=row['target']
                    if activity!='learn_digits' or mode==1:
                        assert 'text' in target;answer=quantity(target['text']);seen.append(target['text'])
                    else:
                        assert target['svgMd5'] in svg_by_md5;answer=svg_by_md5[target['svgMd5']];seen.append(str(answer))
                        resource=target['image'].replace('qrc:','');assert any(record['resource']==':'+resource and hashlib.md5((root/'resources'/record['file']).read_bytes()).hexdigest()==target['svgMd5'] for record in resources)
                        assert target['imageRect']['width']>0 and target['imageRect']['height']>0
                    assert target['answer']==answer
                    circles=row['circles'];assert len(circles)==level['circlesModel'] and sum(circle['filled'] for circle in circles)==answer
                    assert len({(round(circle['x'],3),round(circle['y'],3)) for circle in circles})==len(circles)
                    with Image.open(directory/row['screenshot']) as image:
                        image=image.convert('RGB')
                        for circle in circles:
                            pixel=image.getpixel((round(circle['x']),round(circle['y'])))
                            color=tuple(int(circle['color'][i:i+2],16) for i in (1,3,5)) if circle['filled'] else None
                            if color is not None:assert max(abs(a-b) for a,b in zip(pixel,color))<5
                            else:assert max(abs(a-b) for a,b in zip(pixel,(210,97,29)))>30
                    totals['pixel_images']+=1
                assert Counter(seen)==Counter(level['questionsArray'])
            routes.append({'activity':activity,'mode':mode,'levels':len(expected_levels),'questions':count,'wins':case['wins']})
            totals['levels']+=len(expected_levels);totals['questions']+=count;totals['wrong']+=case['wrong'];totals['natural_bonus']+=case['wins']
        for kind in ('controls','keyboard'):
            case,_=receipt(root,activity+'-'+kind,source,manifest,kind+'.qml',activity);totals['supervised_cases']+=1
            observed=case['evidence']
            if kind=='keyboard':assert all(observed[key] for key in ('singleStep','toggle','wrap'))
            else:
                assert observed['activity']==activity and observed['levels']==len(datasets[activity]) and observed['reducedLevels']==observed['levels']-1
                assert all(observed[key] for key in ('configurationSaved','restartClearedInput','previousNext','inputAfterHelp','menu'))
                assert observed['title']=={'learn_digits':'Aprende os algarismos','learn_additions':'Aprende a adição','learn_subtractions':'Aprende a subtração'}[activity]
                assert len(observed['manual'])>40 and '<b>Controlos do teclado:</b>' in observed['manual']
    assert totals['levels']==35 and totals['questions']==220 and totals['supervised_cases']==11
    return {'scope':'Linux Qt offline; physical input/audio, Windows and teacher pending','source_commit':SOURCE,'archive_sha256':ARCHIVE,'routes':routes,**totals}


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--evidence',type=Path,default=DEFAULT);args=parser.parse_args()
    print(json.dumps(verify(args.evidence),ensure_ascii=False,indent=2))
