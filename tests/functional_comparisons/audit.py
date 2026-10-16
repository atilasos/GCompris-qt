#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Audit comparison evidence against frozen sources and Git-captured native receipts."""
import argparse
from collections import Counter
from decimal import Decimal
import hashlib
import importlib.util
import json
from pathlib import Path
import sys
sys.dont_write_bytecode=True
from PIL import Image
from archive import verify as verify_archive,SELECTED

if not __debug__:
    raise RuntimeError('Evidence checks require Python assertions; run without optimisation')

SOURCE='e38441ab1e30fe543db96b35a913857f70153dc9'
ARCHIVE='358e891a94e89235ae88911316ceb803ab55a3cc4f60f4310845cd8c45d06156'
CAPTURE='PENDING'
BASE='.scratch/pt-pt/functional-comparisons'
DEFAULT=Path(__file__).resolve().parents[2]/BASE
ACTIVITIES={'comparator':'Comparator.qml','adjacent_numbers':'Adjacent_numbers.qml'}
CASE_ACTIVITY={'comparator-complete':'comparator','comparator-controls':'comparator','comparator-resources':'comparator',
               'adjacent-automatic-complete':'adjacent_numbers','adjacent-manual-complete-rerun':'adjacent_numbers',
               'adjacent-controls':'adjacent_numbers','adjacent_numbers-resources':'adjacent_numbers',
               'adjacent-contract-red':'adjacent_numbers','adjacent-contract-green2':'adjacent_numbers'}


def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()


def load(path,name):
    specification=importlib.util.spec_from_file_location(name,path);module=importlib.util.module_from_spec(specification);specification.loader.exec_module(module);return module


def sources(root):
    assert sha(root/'archive/manifest.json')==ARCHIVE
    manifest=verify_archive(root/'archive');assert manifest['source_commit']==SOURCE
    source=root/'archive/files'
    data=load(source/'tests/functional_comparisons/data.py','frozen_data');data.ROOT=source
    oracle=load(source/'tests/functional_comparisons/oracle.py','frozen_oracle')
    resources=load(source/'tests/functional_comparisons/resources.py','frozen_resources');resources.ROOT=source
    return manifest,source,data.inventory(),oracle,resources


def captured(root):
    assert CAPTURE!='PENDING' and sha(root/'capture.json')==CAPTURE
    manifest=json.loads((root/'capture.json').read_text());assert manifest['version']==1 and len(manifest['capture_commit'])==40
    for relative,identity in manifest['files'].items():
        path=root/relative;assert not path.is_symlink() and sha(path)==identity['sha256'] and path.stat().st_size==identity['bytes'],relative
    assert all(name+'/result.json' in manifest['files'] and name+'/launcher-status.json' in manifest['files'] and name+'/tool-status.json' in manifest['files'] for name in SELECTED)
    return manifest


def native(root,name,manifest,source):
    activity=CASE_ACTIVITY[name];directory=root/name;result=json.loads((directory/'result.json').read_text())
    status=json.loads((directory/'launcher-status.json').read_text());red=name=='adjacent-contract-red'
    case='adjacent-level-contract.qml' if name.startswith('adjacent-contract-') else 'adjacent-manual-complete.qml' if name=='adjacent-manual-complete-rerun' else name+'.qml'
    tool=json.loads((directory/'tool-status.json').read_text())
    assert tool['format']==1 and tool['kind']=='observed-exec-tool-return' and tool['exit_code']==(1 if red else 0)
    assert tool['native_receipt_sha256']==sha(directory/'result.json') and tool['launcher_status_sha256']==sha(directory/'launcher-status.json')
    assert result['activity']==activity and result['locale']=='pt_PT' and result['network']=='docker-none'
    assert result['portuguese_catalogue_sha256']==sha(source/'poqm/pt/gcompris_qt.po')
    assert result['case_sha256']==status['case_sha256']==sha(source/BASE/case)
    assert result['runner_sha256']==status['launcher_sha256']==sha(source/'tools/run-native-qml-case.py')
    qml='src/activities/'+activity+'/'+ACTIVITIES[activity]
    assert result['source_sha256']==sha((source.parent/'red' if red else source)/qml)
    assert result['exit_code']==0 and not result['timeout'] and not result['qml_errors'] and result['private_file_ownership_verified']
    assert status['format']==1 and status['kind']=='observed-subprocess-exit'
    assert status['native_receipt_sha256']==sha(directory/'result.json') and status['exit_code']==(1 if red else 0)
    assert result['passed']==(not red) and result['case_result']['failures']==(1 if red else 0) and result['case_result']['passes']==(1 if red else 2)
    snapshot=source/BASE/'resource-snapshot.json';expected=json.loads(snapshot.read_text())['files']
    expected['share/gcompris-qt/rcc/'+activity+'.rcc']=result['private_rcc_sha256']
    expected['share/gcompris-qt/translations/gcompris_qt_pt.qm']=result['private_qm_sha256']
    assert result['resource_files_sha256']==expected and len(expected)==269
    assert result['resource_manifest_sha256']==sha(snapshot) and result['binary_sha256']==expected['bin/gcompris-qt']
    for screenshot in result['screenshots']:
        assert sha(directory/screenshot['file'])==screenshot['sha256']
        with Image.open(directory/screenshot['file']) as image:assert image.width>0 and image.height>0;image.verify()
    return result['case_result'],result


def verify(root):
    manifest,source,data,oracle,resources=sources(root);capture=captured(root)
    results={name:native(root,name,manifest,source) for name in SELECTED}
    assert len(data['comparator']['levels'])==26 and data['comparator']['puzzles']==130
    assert len(data['adjacent_numbers']['levels'])==25 and data['adjacent_numbers']['puzzles']==125
    compared=0;adjacent_questions=0;completed_levels=0;wrong=0;signs=set();decimal_seen=False;negative_adjacent=False
    for name,activity,manual in [('comparator-complete','comparator',None),('adjacent-automatic-complete','adjacent_numbers',False),('adjacent-manual-complete-rerun','adjacent_numbers',True)]:
        case,result=results[name];levels=data[activity]['levels'];puzzles=case['puzzles']
        assert case['wrong']==len(puzzles)==data[activity]['puzzles']
        assert case['completed']==[{'level':level['level'],'puzzles':level['puzzles']} for level in levels]
        assert Counter(p['level'] for p in puzzles)==Counter({level['level']:level['puzzles'] for level in levels})
        assert {s['file'] for s in result['screenshots']}=={'level-'+str(level['level'])+'.png' for level in levels}
        for puzzle in puzzles:
            config=levels[puzzle['level']-1]['configuration']
            if activity=='comparator':
                assert len(puzzle['rows'])==config['numberOfEquations']==5
                for row in puzzle['rows']:
                    assert row['sign']==oracle.compare(row['left'],row['right']);signs.add(row['sign'])
                    for field in ('left','right'):
                        number=oracle.number(row[field]);assert Decimal(str(config['minValue']))<=number<=Decimal(str(config['maxValue']))
                        assert number%Decimal(str(config.get('precision',1)))==0
                        decimal_seen=decimal_seen or ',' in row[field]
                    compared+=1
            else:
                assert puzzle['manual']==manual and case['manual']==manual
                visible=[]
                for item in puzzle['visible']:
                    if item=='?':visible.append(None)
                    else:
                        value=oracle.number(item);assert value==value.to_integral_value();visible.append(int(value))
                expected=oracle.adjacent(visible)
                negative_adjacent=negative_adjacent or min(expected)<0
                assert puzzle['expected']==expected and puzzle['missing']==[i for i,value in enumerate(visible) if value is None]
                assert len(visible)==config['numberShown'] and puzzle['missing']==config['indicesToGuess']
                assert config['lowerBound']<=expected[0]<=config['upperBound']
                missing=puzzle['missing'];count=len(missing);last=len(visible)-1
                if missing==list(range(count)):ending='anterior' if count==1 else 'anteriores'
                elif missing==list(range(last-count+1,last+1)):ending='seguinte' if count==1 else 'seguintes'
                elif 0 not in missing and last not in missing:ending='intermédio' if count==1 else 'intermédios'
                else:ending='em falta'
                instruction=('Encontra '+str(count)+' número ' if count==1 else 'Encontra os '+str(count)+' números ')+ending+'.'
                assert puzzle['instruction']==instruction
                adjacent_questions+=1
        completed_levels+=len(levels);wrong+=case['wrong']
    assert signs=={'<','=','>'} and decimal_seen and negative_adjacent
    assert results['comparator-complete'][0]['marks']==650
    for name in ('adjacent-automatic-complete','adjacent-manual-complete-rerun'):
        case=results[name][0];assert case['moves']==sum(len(puzzle['missing'])+1 for puzzle in case['puzzles'])
    assert compared==650 and adjacent_questions==250 and completed_levels==76 and wrong==380
    for name,title,total,reduced in [('comparator-controls','Comparar os números',26,23),('adjacent-controls','Descobrir os números sequenciais.',25,21)]:
        evidence=results[name][0]['evidence'];assert evidence['title']==title and evidence['levels']==total and evidence['reduced']==reduced and len(evidence['datasetObjective'])>10
        assert all(evidence[key] for key in ('partialRestart','selectorsPersist','previousNext','helpPortuguese','focusAfterHelp','home'))
    copied=0
    for name,activity in [('comparator-resources','comparator'),('adjacent_numbers-resources','adjacent_numbers')]:
        case,_=results[name];assert case['resources']==resources.paths(activity)
        for relative in case['resources']:
            assert sha(root/name/'resources'/relative)==sha(source/relative);copied+=1
    audio=json.loads((root/'audio-decode.json').read_text());assert len(audio['files'])==6
    for record in audio['files']:
        assert record['exit_code']==0 and record['sha256']==sha(root/record['file']) and not record['stderr']
    red=results['adjacent-contract-red'][0];green=results['adjacent-contract-green2'][0]
    assert red['levels']==0 and red['current']==0 and red['displayed']==2
    assert green['levels']==25 and green['displayed']==red['displayed']==2 and green['current']==1
    assert results['adjacent-contract-red'][1]['case_sha256']==results['adjacent-contract-green2'][1]['case_sha256']
    return {'scope':'Linux Qt offline; Windows, physical input/audio and teacher pending','source_commit':SOURCE,'capture_commit':capture['capture_commit'],'positive_cases':8,'expected_red_cases':1,'completed_levels':76,'comparator_questions':130,'comparisons':650,'adjacent_questions':250,'wrong_answers':380,'natural_bonus':76,'level_images':76,'copied_resources':copied}


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--evidence',type=Path,default=DEFAULT);args=parser.parse_args();print(json.dumps(verify(args.evidence),ensure_ascii=False,indent=2))
