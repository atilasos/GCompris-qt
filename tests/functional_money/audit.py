#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Verify immutable money evidence and independently check visible cent arithmetic."""
import argparse
from collections import Counter
from functools import cache
import hashlib
import json
from pathlib import Path, PurePosixPath
import subprocess
import sys
from oracle import DENOMINATIONS, cents, subset

ROOT=Path(__file__).resolve().parents[2]
EVIDENCE='.scratch/pt-pt/functional-money/'
PROOF_REVISION='ee3eb60d751c4463f0781560f729dba1aa8354a8'
PHASES={'original':'0df3a261b8ba60ee2a518a2f1ff80382da34861f','keyboard-fixed':'29041be632ab3f86c844b554239c19f864470a9e','final':'8d9b050078c7d6d40a8e962651bee493cae8ab25'}
LEVELS={'money':23,'money_cents':23,'money_back':29,'money_back_cents':28}


def digest(raw):return hashlib.sha256(raw).hexdigest()


def audit(base,repository=ROOT):
    @cache
    def blob(revision,path):return subprocess.check_output(['git','-C',str(repository),'show',revision+':'+path])
    def reference(path):return blob(PROOF_REVISION,EVIDENCE+path)
    def read(path):return json.loads((base/path).read_text())
    index=read('index.json')
    assert (base/'index.json').read_bytes()==reference('index.json'),'Historical index changed'
    for path,sha in index['files'].items():
        parsed=PurePosixPath(path)
        assert not parsed.is_absolute() and '..' not in parsed.parts and str(parsed)==path,'Unsafe evidence path'
        assert digest((base/path).read_bytes())==sha,'Evidence bytes changed: '+path
    manifests={}
    for phase,revision in PHASES.items():
        source=read('phases/'+phase+'/source-manifest.json')
        assert source['revision']==revision
        prefixes=['CMakeLists.txt','poqm/pt/gcompris_qt.po','tools/run-native-qml-case.py','tools/native_qml_resources.py','src/core',*['src/activities/'+name for name in LEVELS]]
        paths=set(subprocess.check_output(['git','-C',str(repository),'ls-tree','-r','--name-only',revision,'--',*prefixes],text=True).splitlines())
        assert set(source['files'])==paths,'Source path set changed'
        for path,sha in source['files'].items():assert digest(blob(revision,path))==sha,path
        snapshot=read('phases/'+phase+'/snapshot-manifest.json');manifests[phase]=snapshot
        assert len(snapshot['files'])==269
        canonical=read('phases/'+phase+'/rcc-identities.json')
        assert set(canonical)=={'core',*LEVELS}
        for name,resource in canonical.items():
            prefix='src/core' if name=='core' else 'src/activities/'+name
            expected={path for path in paths if path.startswith(prefix+'/')}
            assert {row['path'] for row in resource['files']}=={':/gcompris/'+path for path in expected}
            assert len(resource['files'])==len(expected)
            for row in resource['files']:
                content=blob(revision,row['path'].removeprefix(':/gcompris/'))
                assert row['sha256']==digest(content) and row['bytes']==len(content) and row['ogg']==content.startswith(b'OggS')
            assert resource['rcc_sha256']==snapshot['files']['share/gcompris-qt/rcc/'+name+'.rcc']
    inv=read('inventory.json')
    for path,sha in inv['source_files'].items():assert sha==digest(blob(PHASES['final'],path))
    external=read('phases/final/external-identities.json')
    assert set(external)=={'babymatch','babyshapes','family','mosaic'}
    assert sum(len(value['files']) for value in external.values())==17
    for name,resource in external.items():
        assert resource['rcc_sha256']==manifests['final']['files']['share/gcompris-qt/rcc/'+name+'.rcc']
        for row in resource['files']:
            content=blob(PHASES['final'],row['path'].removeprefix(':/gcompris/'))
            assert row['sha256']==digest(content) and row['bytes']==len(content)
    counts={'puzzles':0,'mouse':0,'keyboard':0,'insufficient':0,'excessive':0,'controls':0}
    def denomination(row):
        assert row['cents']==DENOMINATIONS[row['source'].split('/')[-1]]
        return row['cents']
    def payment(sources,wallet):
        assert not Counter(sources)-Counter(row['source'] for row in wallet),'Payment exceeds physical wallet'
        return sum(DENOMINATIONS[source.split('/')[-1]] for source in sources)
    for name,case in index['cases'].items():
        result=read(name+'/result.json');phase=case['phase'];revision=PHASES[phase]
        assert result['case_sha256']==digest((base/name/'case.qml').read_bytes())
        assert result['source_sha256']==digest(blob(revision,'src/activities/'+result['qml_file']))
        assert result['runner_sha256']==digest(blob(revision,'tools/run-native-qml-case.py'))
        assert result['portuguese_catalogue_sha256']==digest(blob(revision,'poqm/pt/gcompris_qt.po'))
        manifest=manifests[phase]
        assert result['resource_manifest_sha256']==digest((base/'phases'/phase/'snapshot-manifest.json').read_bytes())
        effective=dict(manifest['files']);effective['share/gcompris-qt/rcc/money.rcc']=result['private_rcc_sha256'];effective['share/gcompris-qt/translations/gcompris_qt_pt.qm']=result['private_qm_sha256']
        assert effective==result['resource_files_sha256']
        assert result['binary_sha256']==effective['bin/gcompris-qt']
        assert result['exit_code']==0 and not result['timeout'] and result['private_file_ownership_verified']
        assert result['network']=='docker-none' and result['runtime_uid']!=0
        assert result['passed']==(case['kind']!='red')
        evidence=result['case_result']
        if case['kind']=='campaign':
            activity=result['activity'];rows=evidence['observations'];assert len(rows)==LEVELS[activity]
            for i,row in enumerate(rows):
                assert row['level']==i+1 and row['validation']==case['mode'] and row['bonus']
                wallet=row['wallet'];values=[denomination(coin) for coin in wallet]
                prices=sum(cents(price['text']) for price in row['prices'])
                assert all(cents(price['text'])==price['cents'] for price in row['prices'])
                tender=sum(denomination(coin) for coin in row['tender'])
                target=tender-prices if '_back' in activity else prices
                assert target==row['targetCents']==row['paidCents'] and target>0
                assert subset(values,target) is not None and payment(row['payment'],wallet)==target
                dataset=inv['activities'][activity]['levels'][i]
                assert Counter(values)==Counter(coin['cents'] for coin in dataset['pocket'])
                if '_back' in activity:assert tender==dataset['paid']*100
                for negative in row['negative']:
                    if negative['available']:
                        amount=payment(negative['sources'],wallet);assert amount==negative['cents']
                        assert (amount<target if negative['kind']=='insufficient' else amount>target)
                        assert negative['errorVisible']==(case['mode']==2)
                        counts[negative['kind']]+=1
                counts['puzzles']+=1;counts[row['input']]+=1
        elif case['kind']=='controls':
            assert all(evidence['evidence'][key] for key in ['modePersistence','datasetPersistence','partialRestart','previousNextWrap','helpPortuguese','keyboardAfterHelp','menu'])
            counts['controls']+=1
    assert counts['puzzles']==206 and counts['controls']==4,counts
    for a,b in [('automatic-keyboard-red','automatic-keyboard-green'),('manual-feedback-red','manual-feedback-green'),('reachability-red','reachability-green')]:
        assert read(a+'/result.json')['case_sha256']==read(b+'/result.json')['case_sha256']
    assert len(read('reachability-green/result.json')['case_result']['observations'])==12
    for row in read('audio-decode.json'):
        assert row['sha256']==digest(blob(PHASES['final'],row['path'])) and row['exit_code']==0 and not row['physical_audio_approved']
    return {'proof_revision':PROOF_REVISION,'cases':len(index['cases']),**counts,'scope':'Linux software evidence; Windows, physical audio and teacher review pending'}


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--evidence',type=Path,default=ROOT/EVIDENCE)
    parser.add_argument('--repository',type=Path,default=ROOT)
    args=parser.parse_args()
    try:print(json.dumps(audit(args.evidence,args.repository),indent=2))
    except (AssertionError,OSError,ValueError,KeyError) as error:
        print('Money evidence rejected: '+str(error),file=sys.stderr);return 1
    return 0

if __name__=='__main__':sys.exit(main())
