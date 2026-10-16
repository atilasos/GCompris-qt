#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Verify preserved native Roman-number results against physical fixed sources."""
import argparse
import ast
import hashlib
import io
import json
from pathlib import Path
import re
import zipfile
from oracle import roman,arabic
if not __debug__:raise RuntimeError('Roman audit requires Python assertions; do not use -O')
ROOT=Path(__file__).resolve().parents[2]
HERE=ROOT/'.scratch/pt-pt/functional-roman'
CAPTURE_SHA='77da6ca663c046532e7ef7a23b10f8b1c3213a1f278c3fc3d7079b9a428f1c09'
SOURCE_SHA='0464b6c452f18a47452d1ccbd08fd7a8a8eedd93f961dd157b6e5ef5573e2c43'
QML='src/activities/roman_numerals/RomanNumerals.qml'
CASES={
 'bounds-red':('bounds-probe.qml','baseline',False),
 'reset-red':('reset-probe.qml','baseline',False),
 'bounds-green':('bounds-probe.qml','range-reset',True),
 'reset-green':('reset-probe.qml','range-reset',True),
 'blank-red':('blank-answer.qml','range-reset',False),
 'blank-green':('blank-answer.qml','final',True),
 'complete-final':('complete.qml','final',True),
 'controls':('controls.qml','final',True),
 'resources':('resources.qml','final',True),
 'noncanonical-final':('noncanonical.qml','final',True),
}
EXTRA={'source-tree.zip','source-manifest.json','resource-snapshot.json','data.json','wav-software-decode.json','execution-notes.json'}


def sha(data):return hashlib.sha256(data).hexdigest()

def read(path):return json.loads(path.read_text())

def question(text):
    match=re.fullmatch(r'Converter o número romano ([IVXLCDM]+) para árabe\.',text)
    if match:return True,match[1],str(arabic(match[1]))
    match=re.fullmatch(r'Converter o número árabe (\d+) para romano\.',text);assert match,'Portuguese question'
    return False,match[1],roman(int(match[1]))

def source_values(text):
    matches=re.findall(r'values:\s*(\[.*?\]),.*?toArabic:\s*(true|false)',text,re.S);assert len(matches)==14
    return [(ast.literal_eval(re.sub(r'/\*.*?\*/','',values,flags=re.S)),direction=='true') for values,direction in matches]


def audit(evidence=HERE):
    evidence=Path(evidence);capture_bytes=(evidence/'capture.json').read_bytes();assert sha(capture_bytes)==CAPTURE_SHA,'Immutable capture root'
    capture=json.loads(capture_bytes);assert capture['format']==1
    required={str(path.relative_to(evidence)) for case in CASES for path in (evidence/case).rglob('*') if path.is_file()}|{row[0] for row in CASES.values()}|EXTRA
    assert set(capture['files'])==required,'Exact selected paths'
    for name,digest in capture['files'].items():assert sha((evidence/name).read_bytes())==digest,'Frozen artifact '+name
    source_bytes=(evidence/'source-tree.zip').read_bytes();assert sha(source_bytes)==SOURCE_SHA
    source=read(evidence/'source-manifest.json');assert source['phases']=={'baseline':'7a93fa86e','range-reset':'31121a829','final':'5425ec71e'} and source['zip_sha256']==SOURCE_SHA and len(source['files'])==218
    with zipfile.ZipFile(io.BytesIO(source_bytes)) as archive:
        assert len(archive.namelist())==len(set(archive.namelist())) and set(archive.namelist())==set(source['files']);content={name:archive.read(name) for name in source['files']}
    assert all(sha(data)==source['files'][name] for name,data in content.items())
    def original(name,phase='final'):return content[(phase if name==QML else 'final')+'/'+name]
    authored=source_values(original(QML,'baseline').decode());assert all(source_values(original(QML,phase).decode())==authored for phase in ['range-reset','final'])
    data=read(evidence/'data.json');assert data['source']==QML and data['sha256']==sha(original(QML,'baseline')) and len(data['levels'])==14 and data['questions']==102
    counts=[]
    for index,((values,direction),entry) in enumerate(zip(authored,data['levels'])):
        count=values[2] if values[0]=='_random_' else len(values);counts.append(count)
        assert entry['level']==index+1 and entry['data']['values']==values and entry['data']['toArabic'] is direction and entry['questions']==count and entry['random'] is (values[0]=='_random_')
    assert counts==[7,7,8,8,7,7,7,7,2,2,10,10,10,10]
    snapshot_bytes=(evidence/'resource-snapshot.json').read_bytes();snapshot=json.loads(snapshot_bytes);assert len(snapshot['files'])==269
    results={}
    for name,(case_file,phase,positive) in CASES.items():
        directory=evidence/name;receipt_bytes=(directory/'result.json').read_bytes();result=json.loads(receipt_bytes);status=read(directory/'launcher-status.json');tool=read(directory/'tool-status.json');outer=0 if positive else 1
        assert status['format']==1 and status['kind']=='observed-subprocess-exit' and status['exit_code']==outer
        assert status['native_receipt_sha256']==sha(receipt_bytes) and status['case_sha256']==result['case_sha256'] and status['launcher_sha256']==sha(original('tools/run-native-qml-case.py'))
        assert tool['format']==1 and tool['kind']=='observed-exec-tool-return' and tool['exit_code']==outer and tool['native_receipt_sha256']==sha(receipt_bytes) and tool['launcher_status_sha256']==sha((directory/'launcher-status.json').read_bytes())
        assert result['passed'] is positive and result['exit_code']==0 and result['timeout'] is False and not result['qml_errors']
        assert result['activity']=='roman_numerals' and result['qml_file']=='roman_numerals/RomanNumerals.qml' and result['locale']=='pt_PT' and result['network']=='docker-none'
        assert result['runtime_uid']==result['runtime_gid']==1000 and result['private_file_ownership_verified']
        assert result['source_sha256']==sha(original(QML,phase)) and result['portuguese_catalogue_sha256']==sha(original('poqm/pt/gcompris_qt.po')) and result['runner_sha256']==sha(original('tools/run-native-qml-case.py'))
        assert result['case_sha256']==sha((evidence/case_file).read_bytes()) and result['resource_manifest_sha256']==sha(snapshot_bytes) and result['binary_sha256']==snapshot['files']['bin/gcompris-qt']
        effective=dict(snapshot['files']);effective['share/gcompris-qt/rcc/roman_numerals.rcc']=result['private_rcc_sha256'];effective['share/gcompris-qt/translations/gcompris_qt_pt.qm']=result['private_qm_sha256'];assert result['resource_files_sha256']==effective
        record=result['case_result'];assert record['failures']==(0 if positive else 1) and record['passes']==(2 if positive else 1);results[name]=record
        if name.startswith(('bounds-','reset-')):
            samples=record['samples'];assert samples and record['checkBounds'] is name.startswith('bounds-') and record['checkReset'] is name.startswith('reset-')
            for sample in samples:
                direction,number,answer=question(sample['text']);assert direction is False and answer==sample['answer']
                if positive:assert 1<=int(number)<=50
            if positive:
                assert len(samples)==150 and [(r['round'],r['question']) for r in samples]==[(round,index) for round in range(15) for index in range(10)]
            if name=='bounds-red':assert len(samples)==58 and int(question(samples[-1]['text'])[1])==51 and all(int(question(row['text'])[1])<=50 for row in samples[:-1])
            if name=='reset-red':
                assert len(samples)==74 and samples[-1]['text']==samples[-2]['text'] and samples[-1]['round']==samples[-2]['round'] and samples[-1]['input']==samples[-1]['answer'] and samples[-1]['input']!=''
            if name=='reset-green':assert all(row['input']=='' for row in samples) and any(a['round']==b['round'] and a['text']==b['text'] for a,b in zip(samples,samples[1:]))
        elif name=='complete-final':
            assert record['wrong']==102 and record['physical']==record['virtual']==51 and len(record['questions'])==102
            assert record['completed']==[{'level':level,'questions':counts[level-1]} for level in range(1,15)]
            assert {p.name for p in directory.glob('level-*.png')}=={f'level-{level}.png' for level in range(1,15)}
            grouped={level:[] for level in range(1,15)}
            for row in record['questions']:
                direction,value,answer=question(row['question']);assert row['source']==value and row['answer']==answer and row['toArabic'] is direction
                values,wanted_direction=authored[row['level']-1];assert direction is wanted_direction
                assert row['feedback']==('Valor romano: ' if direction else 'Valor árabe: ')+value
                if values[0]=='_random_':assert 1<=int(value)<=values[1]
                grouped[row['level']].append(value)
            for level,observed in grouped.items():
                assert len(observed)==counts[level-1]
                if authored[level-1][0][0]!='_random_':assert observed==[str(value) for value in authored[level-1][0]]
        elif name=='blank-green':assert record['evidence']['clearedAnswerRejected'] and record['evidence']['correctAnswerAccepted'] and question(record['evidence']['question'])==(True,'I','1')
        elif name=='blank-red':assert record['evidence']=={} and 'ROMAN_BLANK_ACCEPTED' in (directory/'native.log').read_text()
        elif name=='noncanonical-final':assert record['evidence']=={'level':4,'rejected':['MMMM','IIII','VX','IL','IIV'],'repair':'III'}
        elif name=='controls':
            e=record['evidence'];assert e['title']=='Números romanos' and e['levels']==14
            for flag in ['virtualVisibleAndHidden','virtualBackspace','partialRestartByNavigation','previousNextWrap','hintVisibleAndHidden','helpPortuguese','physicalKeyAfterHelp','blankRejectedAfterHelp','home','menu']:assert e[flag] is True
        else:
            expected={name.removeprefix('final/') for name in source['files'] if name.startswith('final/src/activities/roman_numerals/') and name.endswith(('.qml','.js','.svg')) and not name.endswith('/RomanNumerals.qml')}|{'src/core/resource/sounds/completetask.wav','src/core/resource/sounds/crash.wav'}
            assert len(record['resources'])==len(expected) and set(record['resources'])==expected
            for path in expected:assert (directory/'resources'/path).read_bytes()==original(path)
    for prefix in ['bounds','reset','blank']:
        assert read(evidence/(prefix+'-red')/'result.json')['case_sha256']==read(evidence/(prefix+'-green')/'result.json')['case_sha256']
    decoded=read(evidence/'wav-software-decode.json')['results'];assert len(decoded)==2 and {row['resource'] for row in decoded}=={'src/core/resource/sounds/completetask.wav','src/core/resource/sounds/crash.wav'}
    assert all(row['exit_code']==0 and not row['stderr'] and row['sha256']==sha(original(row['resource'])) for row in decoded)
    return {'cases':10,'positive':7,'expected_red':3,'levels':14,'questions':102,'wrong':102,'physical':51,'virtual':51,'additional_random_samples':300,'source_files':218,'runtime_files':269,'scope':'Linux software verification; no physical audio, Windows or teacher acceptance.'}


if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--evidence',type=Path,default=HERE);args=parser.parse_args();print(json.dumps(audit(args.evidence),indent=2))
