#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Audit archived native fraction proof, independently of the current checkout."""
import argparse
from collections import Counter
from fractions import Fraction
import hashlib
import json
import math
from pathlib import Path
from PIL import Image
from archive import verify as verify_archive
from inventory import collect
from audit_data import audit as audit_data
from oracles import instruction_fraction

SOURCE_COMMIT='a32b458613048ed6190fcac8ff271533e0d468d8'
ARCHIVE_SHA='c6f7815a18fe2ba3938656f26133a4e2e6d17357571d26d5298396132f7890e9'
COUNTS={'fractions_create':[5]*13+[3]*3+[2]*2,'fractions_find':[5]*12}
MODES={'fractions_create':'selectPie','fractions_find':'findFraction'}
DEFAULT=Path(__file__).resolve().parents[2]/'.scratch/pt-pt/functional-fractions'


def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()


def pixel_parts(path, drawing):
    with Image.open(path) as image:
        image=image.convert('RGB')
        backgrounds=[image.getpixel((round(point['x']),round(point['y']))) for point in drawing['background']]
        for part in drawing['parts']:
            color=image.getpixel((round(part['x']),round(part['y'])))
            base=backgrounds[part['chart']]
            contrast=max(abs(a-b) for a,b in zip(color,base))
            assert contrast>30 if part['selected'] else contrast<15,(path.name,part,color,base)


def drawing_fraction(drawing):
    parts=drawing['parts'];assert parts
    denominator=drawing['denominator']
    assert denominator>=2 and len(parts)%denominator==0
    assert all(part['denominator']==denominator for part in parts)
    assert drawing['selected']==sum(part['selected'] for part in parts)
    assert all(0<=part['chart']<len(drawing['background']) for part in parts)
    for part in parts:
        if part['kind']=='pie':assert abs(part['angle']-360/denominator)<0.001
        else:assert part['kind']=='rectangle' and part['width']>0 and part['height']>0
    assert len(drawing['background'])==len(parts)//denominator
    for chart in range(len(drawing['background'])):
        group=[part for part in parts if part['chart']==chart]
        assert len(group)==denominator and len({(round(part['x'],4),round(part['y'],4)) for part in group})==denominator
        assert len({part['kind'] for part in group})==1
        if group[0]['kind']=='pie':
            cx=sum(part['x'] for part in group)/denominator;cy=sum(part['y'] for part in group)/denominator
            radii=[math.hypot(part['x']-cx,part['y']-cy) for part in group]
            assert min(radii)>0 and max(radii)-min(radii)<0.01
            angles=sorted(math.atan2(part['y']-cy,part['x']-cx)%(2*math.pi) for part in group)
            gaps=[(angles[(i+1)%denominator]-angles[i])%(2*math.pi) for i in range(denominator)]
            assert all(abs(gap-2*math.pi/denominator)<0.001 for gap in gaps)
        else:
            assert max(part['y'] for part in group)-min(part['y'] for part in group)<0.01
            ordered=sorted(group,key=lambda part:part['x']);gap=ordered[1]['x']-ordered[0]['x']
            assert gap>0 and all(abs(ordered[i]['x']-ordered[i-1]['x']-gap)<0.01 for i in range(1,denominator))
            assert all(abs(part['width']-group[0]['width'])<0.01 and abs(part['height']-group[0]['height'])<0.01 for part in group)
    return Fraction(drawing['selected'],denominator)


def native(directory,activity,case,archive,manifest):
    result=json.loads((directory/'result.json').read_text())
    assert result['passed'] and result['exit_code']==0 and not result['timeout'] and not result['qml_errors']
    assert result['activity']==activity and result['locale']=='pt_PT' and result['network']=='docker-none'
    assert result['private_file_ownership_verified']
    assert result['case_result']['failures']==0 and result['case_result']['passes']==2
    assert result['case_sha256']==sha(archive/case)
    assert result['source_sha256']==sha(archive/'src/activities/fractions_create/FractionsCreate.qml')
    assert result['portuguese_catalogue_sha256']==sha(archive/'poqm/pt/gcompris_qt.po')
    assert result['runner_sha256']==sha(archive/'tools/run-native-qml-case.py')
    snapshot=json.loads((archive.parent/'snapshot-manifest.json').read_text())
    expected_resources=dict(snapshot['files'])
    expected_resources['share/gcompris-qt/rcc/fractions_create.rcc']=result['private_rcc_sha256']
    expected_resources['share/gcompris-qt/translations/gcompris_qt_pt.qm']=result['private_qm_sha256']
    assert result['resource_files_sha256']==expected_resources and len(snapshot['files'])==269
    assert result['resource_manifest_sha256']==manifest['snapshot_manifest_sha256']
    assert result['binary_sha256']==snapshot['files']['bin/gcompris-qt']
    for screenshot in result['screenshots']:assert sha(directory/screenshot['file'])==screenshot['sha256']
    return result['case_result']


def verify(evidence,require_lock=True):
    archive_dir=evidence/'archive'
    assert sha(archive_dir/'manifest.json')==ARCHIVE_SHA
    manifest=verify_archive(archive_dir);assert manifest['source_commit']==SOURCE_COMMIT
    archive=archive_dir/'files'
    if require_lock:
        lock=json.loads((evidence/'lock.json').read_text())
        assert lock['source_commit']==SOURCE_COMMIT and lock['archive_manifest_sha256']==ARCHIVE_SHA
        for relative,digest in lock['files'].items():assert sha(evidence/relative)==digest,relative
    history=json.loads((evidence/'history/identity.json').read_text())
    assert history['red_commit']=='5953a4bce0c3fe7ad6056917b1db2912261ae3ee'
    assert history['green_commit']=='8eeedc44ae6bf499365870bd16e9be6dc48f3477'
    assert sha(evidence/'history/red-po.po')==history['red_po_sha256']=='ac46f8c055a1c773667e0dacfb1e06da2a22692f57a0a57c69c35b1c982bbd19'
    old_po=(evidence/'history/red-po.po').read_text();fixed=old_po
    for name in ('dois-terços','dois-quintos','três-quartos','três-quintos'):fixed=fixed.replace(name,name.replace('-',' '))
    assert fixed==(archive/'poqm/pt/gcompris_qt.po').read_text()
    red=json.loads((evidence/'wording-red-final/result.json').read_text())
    green=json.loads((evidence/'wording-green/result.json').read_text())
    assert red['case_sha256']==green['case_sha256']==sha(archive/'tests/functional_fractions/first-level.qml')
    assert red['source_sha256']==green['source_sha256']==sha(archive/'src/activities/fractions_create/FractionsCreate.qml')
    assert red['portuguese_catalogue_sha256']==history['red_po_sha256']
    assert green['portuguese_catalogue_sha256']==sha(archive/'poqm/pt/gcompris_qt.po')
    assert not red['passed'] and red['case_result']['failures']==1 and red['exit_code']==0 and not red['qml_errors'] and not red['timeout']
    assert green['passed'] and green['case_result']['failures']==0 and green['case_result']['wins']==1 and len(green['case_result']['completed'])==5 and green['exit_code']==0
    for directory,record in [('wording-red-final',red),('wording-green',green)]:
        for screenshot in record['screenshots']:assert sha(evidence/directory/screenshot['file'])==screenshot['sha256']
    datasets=collect(archive);summary=audit_data(datasets)
    expected={activity:[] for activity in COUNTS}
    for dataset in datasets:expected[dataset['path'].split('/')[2]].extend(dataset['levels'])
    routes=[]
    for activity,counts in COUNTS.items():
        for kind in ('gameplay','controls'):
            name=activity+'-'+kind;directory=evidence/'final'/name
            case='tests/functional_fractions/'+('all-levels.qml' if kind=='gameplay' else 'controls.qml')
            process=json.loads((evidence/'final'/(name+'.process.json')).read_text())
            assert process['activity']==activity and process['case']==kind and process['test_file']==case
            assert process['source_commit']==SOURCE_COMMIT and process['archive_manifest_sha256']==ARCHIVE_SHA
            assert process['launcher_exit']==process['native_exit']==0 and process['native_passed']
            record=native(directory,activity,case,archive,manifest)
            if kind=='controls':
                control=record['evidence'];assert control['mode']==MODES[activity] and control['levels']==len(counts)
                assert control['reducedLevels']==len(counts)-2
                assert all(control[key] for key in ('configurationSaved','restartClearedInput','previousNext','inputAfterHelp','menu'))
                routes.append({'activity':activity,'case':kind,'passed':True});continue
            assert record['mode']==MODES[activity] and record['levels']==record['wins']==len(counts)
            assert len(record['completed'])==record['wrong']==sum(counts)
            assert record['toggles']==(len(counts) if activity=='fractions_create' else 0)
            observed={index+1:[] for index in range(len(counts))}
            for row in record['completed']:
                level,q=row['level'],row['question'];assert 1<=level<=len(counts) and 1<=q<=counts[level-1]
                before,answer=row['before'],row['answer'];before_fraction=drawing_fraction(before);answer_fraction=drawing_fraction(answer)
                assert [part['kind'] for part in before['parts']]==[part['kind'] for part in answer['parts']]
                assert before['denominator']==answer['denominator']
                for old,new in zip(before['parts'],answer['parts']):
                    assert {key:value for key,value in old.items() if key!='selected'}=={key:value for key,value in new.items() if key!='selected'}
                model=expected[activity][level-1]['subLevels'][q-1]
                assert all(part['kind']==model['chartType'] for part in before['parts'])
                expected_fraction=instruction_fraction(row['instruction'],before['denominator']) if activity=='fractions_create' else before_fraction
                assert Fraction(*row['target'])==expected_fraction
                assert Fraction(row['answerNumerator'],row['answerDenominator'])==expected_fraction
                if activity=='fractions_create':
                    assert before_fraction==0 and answer_fraction==expected_fraction
                    assert row['answerNumerator']==answer['selected'] and row['answerDenominator']==answer['denominator']
                    observed[level].append((row['instruction'],before['denominator']))
                else:
                    assert answer_fraction==before_fraction
                    assert 2<=before['denominator']<=11 and 0<before['selected']<model['maxFractions']*before['denominator']
                    if model['fixedNumerator']:assert row['answerNumerator']==before['selected']
                    if model['fixedDenominator']:assert row['answerDenominator']==before['denominator']
                pixel_parts(directory/row['questionFile'],before);pixel_parts(directory/row['answerFile'],answer)
            assert [(row['level'],row['question']) for row in record['completed']]==[(level+1,q+1) for level,count in enumerate(counts) for q in range(count)]
            if activity=='fractions_create':
                for level,model in enumerate(expected[activity],1):
                    assert Counter(observed[level])==Counter((question['instruction'],question['denominator']) for question in model['subLevels'])
            routes.append({'activity':activity,'case':kind,'levels':len(counts),'questions':sum(counts),'wins':record['wins'],'wrong':record['wrong']})
    assert len(routes)==4 and len(summary)==30
    return {'scope':'Linux native offline; Windows, physical input/audio and teacher pending.',
            'source_commit':SOURCE_COMMIT,'archive_manifest_sha256':ARCHIVE_SHA,
            'routes':routes,'levels':30,'questions':138,'wrong_answers':138,'natural_bonus':30,
            'snapshotted_resources':269,'pixel_verified_images':276}


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--evidence',type=Path,default=DEFAULT);args=parser.parse_args()
    print(json.dumps(verify(args.evidence.resolve()),ensure_ascii=False,indent=2))
