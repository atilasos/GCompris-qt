#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Audit a copied, immutable native clock proof without its old runtime paths."""
import argparse
import hashlib
import io
import json
from pathlib import Path
import re
import zipfile
from oracle import parse,angles
if not __debug__:raise RuntimeError('Clock audit requires Python assertions; do not use -O')
ROOT=Path(__file__).resolve().parents[2]
HERE=ROOT/'.scratch/pt-pt/functional-clock'
CAPTURE_SHA='b4be514c5c163021c45c897986447ff6ca7a17bbe915f4519496f3ef80fd9776'
SOURCE_ZIP_SHA='547dd81929c94565ed6461898a9fe7ab93bc96fb478973b062c0bd6a50f0ff02'
CASES={'twelve-complete':'twelve-complete.qml','twenty-four-complete':'twenty-four-complete.qml','controls3':'controls3.qml','resources':'resources.qml'}


def sha(data):return hashlib.sha256(data).hexdigest()

def read(path):return json.loads(path.read_text())

def audit(evidence=HERE):
    evidence=Path(evidence);capture_bytes=(evidence/'capture.json').read_bytes()
    assert sha(capture_bytes)==CAPTURE_SHA,'Immutable capture root'
    capture=json.loads(capture_bytes);assert capture['format']==1 and capture['source']=='fec529d1a'
    required={name for case in CASES for name in (str(path.relative_to(evidence)) for path in (evidence/case).rglob('*') if path.is_file())}|set(CASES.values())|{'source-tree.zip','source-manifest.json','resource-snapshot.json','data.json','wav-software-decode.json','execution-notes.json'}
    assert set(capture['files'])==required,'Exact captured paths'
    for name,digest in capture['files'].items():assert sha((evidence/name).read_bytes())==digest,'Frozen artifact '+name
    zip_bytes=(evidence/'source-tree.zip').read_bytes();assert sha(zip_bytes)==SOURCE_ZIP_SHA
    source=read(evidence/'source-manifest.json');assert source['revision']=='fec529d1a' and source['zip_sha256']==SOURCE_ZIP_SHA and len(source['files'])==225
    with zipfile.ZipFile(io.BytesIO(zip_bytes)) as archive:
        assert len(archive.namelist())==len(set(archive.namelist())) and set(archive.namelist())==set(source['files'])
        content={name:archive.read(name) for name in source['files']}
    assert all(sha(data)==source['files'][name] for name,data in content.items())
    snapshot_bytes=(evidence/'resource-snapshot.json').read_bytes();snapshot=json.loads(snapshot_bytes);assert len(snapshot['files'])==269
    data=read(evidence/'data.json');assert data['datasets']==6 and data['questions_per_mode']==50 and len(data['levels'])==10
    authored=[]
    for dataset in range(1,7):
        name=f'src/activities/clockgame/resource/{dataset}/Data.qml';text=content[name].decode();values=json.loads(re.search(r'\bdata:\s*(\[.*\])\s*}',text,re.S)[1])
        for entry in values:authored.append({'level':len(authored)+1,'source':name,'sha256':sha(content[name]),'data':entry})
    assert data['levels']==authored and all(row['data']['numberOfSubLevels']==5 for row in authored)
    totals=[]
    for case,case_file in CASES.items():
        directory=evidence/case;receipt_bytes=(directory/'result.json').read_bytes();result=json.loads(receipt_bytes);status=read(directory/'launcher-status.json');tool=read(directory/'tool-status.json')
        assert status['format']==1 and status['kind']=='observed-subprocess-exit' and status['exit_code']==0
        assert status['native_receipt_sha256']==sha(receipt_bytes) and status['case_sha256']==result['case_sha256'] and status['launcher_sha256']==sha(content['tools/run-native-qml-case.py'])
        assert tool['format']==1 and tool['kind']=='observed-exec-tool-return' and tool['exit_code']==0 and tool['native_receipt_sha256']==sha(receipt_bytes) and tool['launcher_status_sha256']==sha((directory/'launcher-status.json').read_bytes())
        assert result['passed'] is True and result['exit_code']==0 and result['timeout'] is False and not result['qml_errors']
        assert result['activity']=='clockgame' and result['qml_file']=='clockgame/Clockgame.qml' and result['locale']=='pt_PT' and result['network']=='docker-none'
        assert result['runtime_uid']==result['runtime_gid']==1000 and result['private_file_ownership_verified']
        assert result['source_sha256']==sha(content['src/activities/clockgame/Clockgame.qml']) and result['portuguese_catalogue_sha256']==sha(content['poqm/pt/gcompris_qt.po']) and result['runner_sha256']==sha(content['tools/run-native-qml-case.py'])
        assert result['case_sha256']==sha((evidence/case_file).read_bytes()) and result['resource_manifest_sha256']==sha(snapshot_bytes) and result['binary_sha256']==snapshot['files']['bin/gcompris-qt']
        effective=dict(snapshot['files']);effective['share/gcompris-qt/rcc/clockgame.rcc']=result['private_rcc_sha256'];effective['share/gcompris-qt/translations/gcompris_qt_pt.qm']=result['private_qm_sha256'];assert result['resource_files_sha256']==effective
        record=result['case_result'];assert record['failures']==0 and record['passes']==2
        if case.endswith('complete'):
            mode=case=='twenty-four-complete';assert record['twentyFour'] is mode and record['wrong']==50 and len(record['questions'])==50
            assert record['completed']==[{'level':level,'questions':5} for level in range(1,11)]
            assert {p.name for p in directory.glob('level-*.png')}=={f'level-{level}.png' for level in range(1,11)}
            seen={level:0 for level in range(1,11)}
            for question in record['questions']:
                level=question['level'];seen[level]+=1;answer=parse(question['text']);assert list(answer)==question['answer'] and (answer[0]>=12)==mode
                entry=authored[level-1]['data'];assert question['minutes'] is entry['displayMinutesHand'] and question['seconds'] is entry['displaySecondsHand']
                for field,index in [('fixedMinutes',1),('fixedSeconds',2)]:
                    if field in entry:assert answer[index]==entry[field]
                expected=angles(answer)
                for index,visible in enumerate([True,question['minutes'],question['seconds']]):
                    observed=question['angles'][index]
                    if visible:assert observed is not None and min(abs(float(expected[index])-observed),360-abs(float(expected[index])-observed))<0.2
                    else:assert observed is None
            assert set(seen.values())=={5};totals.append({'case':case,'levels':10,'questions':50,'wrong':50,'gestures':record['gestures']})
        elif case=='controls3':
            e=record['evidence'];assert e['title']=='Aprende o relógio' and e['levels']==10 and e['reduced']==9
            for flag in ['hintVisibleAndHidden','twelveAndTwentyFourSaved','partialRestart','previousNextWrap','helpPortuguese','dragAfterHelp','ctrlW','menu']:assert e[flag] is True
        else:
            expected={name for name in source['files'] if name.startswith('src/activities/clockgame/') and name.endswith(('.qml','.js','.svg')) and not name.endswith('/Clockgame.qml')}|{'src/core/resource/sounds/completetask.wav','src/core/resource/sounds/crash.wav'}
            assert len(record['resources'])==len(expected) and set(record['resources'])==expected
            for name in expected:assert (directory/'resources'/name).read_bytes()==content[name]
    decoded=read(evidence/'wav-software-decode.json')['results'];assert len(decoded)==2 and {row['resource'] for row in decoded}=={'src/core/resource/sounds/completetask.wav','src/core/resource/sounds/crash.wav'}
    assert all(row['exit_code']==0 and not row['stderr'] and row['sha256']==sha(content[row['resource']]) for row in decoded)
    return {'cases':4,'levels':20,'questions':100,'wrong':100,'campaigns':totals,'source_files':225,'runtime_files':269,'scope':'Linux software only; no physical audio, Windows or teacher acceptance.'}


if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--evidence',type=Path,default=HERE);args=parser.parse_args();print(json.dumps(audit(args.evidence),indent=2))
