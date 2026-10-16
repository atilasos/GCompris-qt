#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Audit immutable visible-star evidence, arithmetic and completed supervisor status."""
import argparse
from functools import cache
import hashlib
import json
from pathlib import Path,PurePosixPath
import re
import subprocess
import sys
from oracle import representation,result_vector

if not __debug__:raise SystemExit('Magic hat validation requires assertions; Python -O is rejected')
ROOT=Path(__file__).resolve().parents[2]
EVIDENCE='.scratch/pt-pt/functional-magic-hat/'
TESTED_REVISION='8ea79102f473c1a9ff8b2b8e2e7b7fa7bf9def47'
PROOF_REVISION='4cc4ef43774c9517c45a9c77ab78ffc6201c5744'


def sha(raw):return hashlib.sha256(raw).hexdigest()


def audit(base,repository=ROOT):
    @cache
    def blob(revision,path):return subprocess.check_output(['git','-C',str(repository),'show',revision+':'+path])
    def read(path):return json.loads((base/path).read_text())
    index=read('index.json');assert (base/'index.json').read_bytes()==blob(PROOF_REVISION,EVIDENCE+'index.json'),'Immutable proof index changed'
    for relative,digest in index['files'].items():
        path=PurePosixPath(relative);assert not path.is_absolute() and '..' not in path.parts and str(path)==relative
        assert sha((base/relative).read_bytes())==digest,'Evidence changed: '+relative
    source=read('identities/source-manifest.json');assert source['revision']==TESTED_REVISION
    prefixes=['CMakeLists.txt','poqm/pt/gcompris_qt.po','tools/run-native-qml-case.py','tools/run-native-qml-supervised.py','tools/native_qml_resources.py','src/core','src/activities/magic-hat-minus','src/activities/magic-hat-plus']
    paths=set(subprocess.check_output(['git','-C',str(repository),'ls-tree','-r','--name-only',TESTED_REVISION,'--',*prefixes],text=True).splitlines());assert set(source['files'])==paths
    for path,digest in source['files'].items():assert digest==sha(blob(TESTED_REVISION,path)),path
    snapshot=read('identities/snapshot-manifest.json');assert len(snapshot['files'])==269
    resources=read('identities/resources.json');assert resources['revision']==TESTED_REVISION
    assert resources['inspector_source_sha256']==sha(blob(TESTED_REVISION,'tools/pt-pt-audio/rcc_inventory.cpp'))
    assert set(resources['canonical'])=={'core','magic-hat-minus','magic-hat-plus'}
    for name,value in resources['canonical'].items():
        prefix='src/core' if name=='core' else 'src/activities/'+name
        expected={path for path in paths if path.startswith(prefix+'/')}
        assert {row['path'] for row in value['files']}=={':/gcompris/'+path for path in expected} and len(value['files'])==len(expected)
        for row in value['files']:
            original=blob(TESTED_REVISION,row['path'].removeprefix(':/gcompris/'));assert row['sha256']==sha(original) and row['bytes']==len(original)
        assert value['rcc_sha256']==snapshot['files']['share/gcompris-qt/rcc/'+name+'.rcc']
    for row in resources['audio']:assert row['decode_exit_code']==0 and row['sha256']==sha(blob(TESTED_REVISION,row['path']))
    assert len(resources['audio'])==3
    data=read('data.json');assert set(data)=={'magic-hat-plus','magic-hat-minus'}
    for value in data.values():assert len(value['datasets'])==9 and len(value['levels'])==41
    def visible(rows):
        for row in rows:
            if row is None:continue
            assert row['count']==len(row['stars']) and 0<=row['count']<=10
            if row['coefficientText'] is None:assert row['weight']==1
            else:assert re.fullmatch(r'\s*\d+\s*[x×]\s*',row['coefficientText']) and int(re.sub(r'\D','',row['coefficientText']))==row['weight']
            for star in row['stars']:
                assert star['source'].endswith('/star-'+row['group']+'.svg')
                assert star['x']>=0 and star['y']>=0 and star['width']>0 and star['height']>0
    counts={'levels':0,'wrong_repaired':0,'controls':0,'weighted':0,'colored':0}
    for name,entry in index['cases'].items():
        raw=(base/name/'result.json').read_bytes();result=json.loads(raw);status=read(name+'/launcher-status.json')
        assert status['native_receipt_sha256']==sha(raw) and status['kind']=='observed-subprocess-exit'
        assert status['case_sha256']==result['case_sha256']==sha((base/name/'case.qml').read_bytes())
        assert result['runner_sha256']==status['launcher_sha256']==sha(blob(TESTED_REVISION,'tools/run-native-qml-case.py'))
        assert result['source_sha256']==sha(blob(TESTED_REVISION,'src/activities/'+result['qml_file']))
        assert result['portuguese_catalogue_sha256']==sha(blob(TESTED_REVISION,'poqm/pt/gcompris_qt.po'))
        assert result['exit_code']==0 and not result['timeout'] and not result['qml_errors'] and result['private_file_ownership_verified']
        assert result['network']=='docker-none' and result['runtime_uid']!=0
        expected=1 if entry['kind']=='diagnostic' else 0;assert status['exit_code']==expected and result['passed']==(expected==0)
        if entry['kind']!='tracer':
            outer=read(name+'/supervisor-exit.json');assert outer['kind']=='observed-supervisor-subprocess-exit' and outer['exit_code']==expected
            assert outer['native_receipt_sha256']==sha(raw) and outer['launcher_status_sha256']==sha((base/name/'launcher-status.json').read_bytes()) and outer['case_sha256']==result['case_sha256']
            assert outer['supervisor_sha256']==sha(blob(TESTED_REVISION,'tools/run-native-qml-supervised.py'))
        assert result['resource_manifest_sha256']==sha((base/'identities/snapshot-manifest.json').read_bytes())
        effective=dict(snapshot['files']);effective['share/gcompris-qt/rcc/magic-hat-minus.rcc']=result['private_rcc_sha256'];effective['share/gcompris-qt/translations/gcompris_qt_pt.qm']=result['private_qm_sha256']
        assert result['resource_files_sha256']==effective and result['binary_sha256']==effective['bin/gcompris-qt']
        if entry['kind']=='campaign':
            rows=result['case_result']['observations'];assert len(rows)==41
            for i,row in enumerate(rows,1):
                assert row['level']==i and row['mode']==result['activity'].removeprefix('magic-hat-')
                for field in ['first','secondBefore','second','answerRows','selected']:visible(row[field])
                if row['mode']=='minus':assert all(part is None or part['count']==0 for part in row['secondBefore']) and any(part and part['count']>0 for part in row['second'])
                else:assert row['second']==row['secondBefore']
                target=result_vector(row['first'],row['second'],row['mode']);assert target==row['target'] and all(value>=0 for value in target.values())
                assert representation(target,row['answerRows']) is not None
                actual=result_vector(row['selected'],[],'plus');assert actual==target
                assert [part['count'] if part else 0 for part in row['selected']]==row['payment']
                assert row['wrongBonus'].endswith('/flower_bad.svg') and row['goodBonus'].endswith('/flower_good.svg')
                counts['levels']+=1;counts['wrong_repaired']+=1
                counts['weighted']+=any(part and part['coefficientText'] is not None for part in row['first'])
                counts['colored']+=len({part['group'] for part in row['first'] if part})>1
        elif entry['kind']=='controls':
            evidence=result['case_result']['evidence'];assert len(evidence['objectives'])==9 and evidence['levelsBefore']==41 and evidence['levelsAfterExclusion']==39
            assert all(evidence[key] for key in ['restartPartial','datasetPersistence','previousNextWrap','helpPortuguese','helpEscape','inputAfterHelp','menu']);counts['controls']+=1
    assert counts['levels']==82 and counts['controls']==2
    observations=read('tool-outer-observations.json')['observations'];assert set(observations)==set(index['cases'])
    for name,entry in observations.items():
        assert entry['native_receipt_sha256']==sha((base/name/'result.json').read_bytes()) and entry['case_sha256']==sha((base/name/'case.qml').read_bytes())
        assert entry['tool_exit_code']==read(name+'/launcher-status.json')['exit_code']
    return {'proof_revision':PROOF_REVISION,'cases':len(index['cases']),**counts,'datasets':18,'wav_decoded':3,'scope':'Linux software only; Windows 10, physical devices, listening and teacher approval pending'}


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--evidence',type=Path,default=ROOT/EVIDENCE);parser.add_argument('--repository',type=Path,default=ROOT);args=parser.parse_args()
    try:print(json.dumps(audit(args.evidence,args.repository),indent=2))
    except (AssertionError,OSError,ValueError,KeyError) as error:print('Magic hat evidence rejected: '+str(error),file=sys.stderr);return 1
    return 0

if __name__=='__main__':raise SystemExit(main())
