#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Validate immutable flying-sequence evidence and observed post-wait statuses."""
import argparse
from functools import cache
import hashlib
import json
from pathlib import Path,PurePosixPath
import subprocess
import sys
from oracle import sequence

ROOT=Path(__file__).resolve().parents[2]
EVIDENCE='.scratch/pt-pt/functional-planes/'
PROOF_REVISION='db1119f63b9c93dacd5839bdc4a7f53c7db4213f'
ORIGINAL='fb5e4eac9f0e7740673acf79d06eb63fe5449875'
FIXED='7e1d611bd246763bdfb4ba63ccbe09dbd36078c3'


def digest(raw):return hashlib.sha256(raw).hexdigest()


def audit(base,repository=ROOT):
    @cache
    def blob(revision,path):return subprocess.check_output(['git','-C',str(repository),'show',revision+':'+path])
    def read(path):return json.loads((base/path).read_text())
    index=read('index.json')
    assert (base/'index.json').read_bytes()==blob(PROOF_REVISION,EVIDENCE+'index.json'),'Immutable proof index changed'
    for path,sha in index['files'].items():
        parsed=PurePosixPath(path);assert not parsed.is_absolute() and '..' not in parsed.parts and str(parsed)==path
        assert digest((base/path).read_bytes())==sha,'Evidence changed: '+path
    for revision,filename in [(ORIGINAL,'source-manifest.json'),(FIXED,'fixed-source-manifest.json')]:
        manifest=read('identities/'+filename);assert manifest['revision']==revision
        for path,sha in manifest['files'].items():assert sha==digest(blob(revision,path)),path
        assert all(name in manifest['files'] for name in ['tools/run-native-qml-case.py','tools/run-native-qml-supervised.py','tools/native_qml_resources.py','poqm/pt/gcompris_qt.po'])
    snapshot=read('identities/snapshot-manifest.json');assert len(snapshot['files'])==269
    resources=read('identities/resource-identities.json');assert resources['revision']==ORIGINAL
    assert resources['inspector_source_sha256']==digest(blob(ORIGINAL,'tools/pt-pt-audio/rcc_inventory.cpp'))
    source=read('identities/source-manifest.json')['files']
    for name,resource in resources['canonical'].items():
        prefix='src/core' if name=='core' else 'src/activities/'+name
        expected={path for path in source if path.startswith(prefix+'/')}
        assert {row['path'] for row in resource['files']}=={':/gcompris/'+path for path in expected}
        assert len(resource['files'])==len(expected)
        for row in resource['files']:
            content=blob(ORIGINAL,row['path'].removeprefix(':/gcompris/'))
            assert row['sha256']==digest(content) and row['bytes']==len(content)
        assert resource['rcc_sha256']==snapshot['files']['share/gcompris-qt/rcc/'+name+'.rcc']
    assert set(resources['canonical'])=={'planegame','numbers-odd-even','alphabet-sequence','core'}
    assert set(resources['external'])=={'algorithm','digital_electricity'}
    for name,resource in resources['external'].items():
        assert resource['rcc_sha256']==snapshot['files']['share/gcompris-qt/rcc/'+name+'.rcc']
        for row in resource['files']:assert row['sha256']==digest(blob(ORIGINAL,row['path'].removeprefix(':/gcompris/')))
    assert len(resources['voices'])==47
    for path,sha in resources['voice_rcc'].items():assert sha==snapshot['files'][path]
    for row in resources['voices'].values():
        assert row['ogg'] and row['decode_exit_code']==0
        assert row['rcc'] in resources['voice_rcc']
    assert resources['crash']['decode_exit_code']==0 and resources['crash']['sha256']==digest(blob(ORIGINAL,resources['crash']['path']))
    levels=targets=controls=tutorial=0
    for name,entry in index['cases'].items():
        result=read(name+'/result.json');status=read(name+'/launcher-status.json');revision=entry['revision']
        assert revision in [ORIGINAL,FIXED]
        assert status['kind']=='observed-subprocess-exit' and status['format']==1
        assert status['native_receipt_sha256']==digest((base/name/'result.json').read_bytes())
        assert status['case_sha256']==result['case_sha256']==digest((base/name/'case.qml').read_bytes())
        assert status['launcher_sha256']==result['runner_sha256']==digest(blob(revision,'tools/run-native-qml-case.py'))
        manifest=read('identities/'+('source-manifest.json' if revision==ORIGINAL else 'fixed-source-manifest.json'))
        assert manifest['files']['tools/run-native-qml-supervised.py']==digest(blob(revision,'tools/run-native-qml-supervised.py'))
        assert result['source_sha256']==digest(blob(revision,'src/activities/'+result['qml_file']))
        assert result['portuguese_catalogue_sha256']==digest(blob(revision,'poqm/pt/gcompris_qt.po'))
        assert result['exit_code']==0 and not result['timeout'] and result['private_file_ownership_verified']
        assert result['network']=='docker-none' and result['runtime_uid']!=0 and not result['qml_errors']
        assert status['exit_code']==(0 if entry['kind'] in ['campaign','controls','tracer','focus'] else 1)
        assert result['passed']==(status['exit_code']==0)
        if entry['snapshot'] in ['canonical','origin']:
            snapshot_path='identities/'+('snapshot-manifest.json' if entry['snapshot']=='canonical' else 'origin-snapshot-manifest.json')
            assert result['resource_manifest_sha256']==digest((base/snapshot_path).read_bytes())
            effective=dict(read(snapshot_path)['files']);effective['share/gcompris-qt/rcc/planegame.rcc']=result['private_rcc_sha256'];effective['share/gcompris-qt/translations/gcompris_qt_pt.qm']=result['private_qm_sha256']
            assert result['resource_files_sha256']==effective and result['binary_sha256']==effective['bin/gcompris-qt']
        if entry['kind']=='campaign':
            rows=result['case_result']['observations'];assert len(rows)==4
            for index_level,row in enumerate(rows,1):
                assert row['level']==index_level and row['indicationVisible']==(index_level<=2) and row['bonus']
                expected=sequence(result['activity'],index_level)
                assert [item['drawn'] for item in row['captures']]==expected
                assert all(item['expected']==item['drawn'] and item['feedback']=='fade' and item['cloudMoved'] for item in row['captures'])
                levels+=1;targets+=len(expected)
            if result['activity']=='numbers-odd-even':
                pages=result['case_result']['tutorial'];assert len(pages)==8
                for page in pages[5:]:
                    wrong,right=page['answers'];assert not wrong['correct'] and right['correct']
                    assert int(wrong['chosen'])%2==wrong['remainder'] and int(right['chosen'])%2==right['remainder']
                    assert wrong['remainder']!=right['remainder'] and right['feedback']=='Ótimo'
                tutorial=len(pages)
        elif entry['kind']=='focus':
            evidence=result['case_result']['evidence'];assert len(evidence['tutorialPages'])==8 and evidence['keyboardAfterStart'] and evidence['keyboardAfterHelp']
        elif entry['kind']=='controls':
            evidence=result['case_result']['evidence']
            assert all(evidence[key] for key in ['naturalStormRecovery','previousNextAndWrap','indicationHidden','helpPortuguese','helpEscape','menu'])
            assert evidence['mistake']['feedback']=='storm' and evidence['restartFirstCapture']['feedback']=='fade'
            assert len(evidence['keyboard'])==4 and evidence['keyboardAfterHelp']['after']>evidence['keyboardAfterHelp']['before']
            controls+=1
    assert levels==12 and targets==190 and controls==3 and tutorial==8
    red=read('alphabet-modern-red/result.json');green=read('alphabet-complete/result.json');assert red['case_sha256']==green['case_sha256']
    return {'proof_revision':PROOF_REVISION,'cases':len(index['cases']),'levels':levels,'captures':targets,'controls':controls,'tutorial_pages':tutorial,'voices_decoded':47,'scope':'Linux software only; Windows, physical devices, listening and teacher approval pending'}


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--evidence',type=Path,default=ROOT/EVIDENCE);parser.add_argument('--repository',type=Path,default=ROOT);args=parser.parse_args()
    try:print(json.dumps(audit(args.evidence,args.repository),indent=2))
    except (AssertionError,OSError,ValueError,KeyError) as error:print('Flying sequence proof rejected: '+str(error),file=sys.stderr);return 1
    return 0

if __name__=='__main__':raise SystemExit(main())
