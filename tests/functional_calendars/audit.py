#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Validate the historical native calendar evidence, independent of old paths."""
import hashlib
import json
from pathlib import Path
import subprocess

ROOT=Path(__file__).resolve().parents[2]
HERE=ROOT/'.scratch/pt-pt/functional-calendars'
SOURCE='02c4675f67bf273448cffb643d80008fae308a77'
ARCHIVE='253a90e85a7d0acf6ea00c8ffd57a34e0e55b17f'
BASE='db2f86383'
TITLE='bde22db2e0bedde49ebcc4a08e314e0b54e3b5be'
QML='src/activities/calendar/Calendar.qml'
CAT='poqm/pt/gcompris_qt.po'
RUNNER='tools/run-native-qml-case.py'
PREFIX='.scratch/pt-pt/functional-calendars/'
ACTIVITIES=['calendar','find_the_day']
EXTRA={'src/activities/fifteen/resource/background.svg','src/core/resource/sounds/completetask.wav','src/core/resource/sounds/crash.wav','src/core/resource/scroll_down.svg','src/core/resource/bar_ok.svg'}


def sha(data):return hashlib.sha256(data).hexdigest()

def git(name,revision=SOURCE):return subprocess.check_output(['git','show',revision+':'+name],cwd=ROOT)


def audit(evidence=HERE):
    evidence=Path(evidence)
    identity=json.loads((evidence/'source-identity.json').read_text())
    required=set(subprocess.check_output(['git','ls-tree','-r','--name-only',SOURCE,'--',*[f'src/activities/{a}' for a in ACTIVITIES]],cwd=ROOT,text=True).splitlines())|{RUNNER,CAT}|EXTRA
    assert identity['revision']==SOURCE and set(identity['files'])==required
    assert all(sha(git(name))==digest for name,digest in identity['files'].items()),'Exact historical source bytes'
    snapshot_bytes=(evidence/'resource-snapshot.json').read_bytes()
    assert snapshot_bytes==git(PREFIX+'resource-snapshot.json',ARCHIVE)
    snapshot=json.loads(snapshot_bytes);assert len(snapshot['files'])==269
    data_bytes=(evidence/'data.json').read_bytes();assert data_bytes==git(PREFIX+'data.json',ARCHIVE)
    data=json.loads(data_bytes)
    namespace={};exec(compile(git('tests/functional_calendars/oracle.py'),'<historical calendar oracle>','exec'),namespace)
    for activity in ACTIVITIES:
        for level in data[activity]['levels']:
            config=level['configuration']
            for question in level['questions']:
                assert question['expected']==namespace['solve'](question['question'],config['visibleYear'],config['visibleMonth']+1)
    cases=[]
    def receipt(directory,case,activity,source=SOURCE,catalogue=SOURCE,positive=True):
        result=json.loads((evidence/directory/'result.json').read_text())
        assert result['passed'] is positive and result['timeout'] is False
        assert result['exit_code']==0 and not result['qml_errors']
        assert result['activity']==activity and result['locale']=='pt_PT' and result['network']=='docker-none'
        assert result['runtime_uid']==result['runtime_gid']==1000 and result['private_file_ownership_verified']
        assert result['source_sha256']==sha(git(QML,source)) and result['portuguese_catalogue_sha256']==sha(git(CAT,catalogue))
        assert result['runner_sha256']==sha(git(RUNNER)) and result['binary_sha256']==snapshot['files']['bin/gcompris-qt']
        assert result['qml_file']=='calendar/Calendar.qml'
        assert (evidence/case).read_bytes()==git(PREFIX+case,ARCHIVE),'Archived immutable case'
        assert result['case_sha256']==sha((evidence/case).read_bytes())
        assert result['resource_manifest_sha256']==sha(snapshot_bytes)
        expected=dict(snapshot['files']);expected['share/gcompris-qt/rcc/calendar.rcc']=result['private_rcc_sha256'];expected['share/gcompris-qt/translations/gcompris_qt_pt.qm']=result['private_qm_sha256']
        assert result['resource_files_sha256']==expected
        assert result['case_result']['failures']==(0 if positive else 1)
        for shot in result['screenshots']:assert sha((evidence/directory/shot['file']).read_bytes())==shot['sha256']
        cases.append({'directory':directory,'activity':activity,'passed':positive})
        return result['case_result']
    for activity in ACTIVITIES:
        full=receipt('full-'+activity,'full-'+activity+'.qml',activity)
        levels=data[activity]['levels']
        assert full['completed']==[{'level':l['level'],'questions':len(l['questions'])} for l in levels]
        assert full['wrong']==len(levels)
        expected={(level['level'],q['portuguese'].lower()):q['expected'] for level in levels for q in level['questions']}
        actual={(r['level'],r['question'].lower()):r['expected'] for r in full['answered']}
        assert actual==expected and len(full['answered'])==len(expected),'All independent questions exactly once'
        controls=receipt('controls-'+activity,'controls-'+activity+'.qml',activity)['controls']
        assert controls['activity']==activity and all(controls[k] is True for k in ['arrowKeys','homeEnd','pageKeys','bounds','restart','weekdayKeyboard','helpEscape','keyAfterHelp','navigation'])
        resources=receipt('resources-'+activity,'resources-'+activity+'.qml',activity)['resources']
        expected_resources=sorted(EXTRA|{p for p in required if any(p.startswith('src/activities/'+a+'/') for a in {'calendar',activity}) and Path(p).suffix in {'.qml','.js','.svg'} and p!=QML})
        assert resources==expected_resources
        for name in resources:assert (evidence/('resources-'+activity)/'resources'/name).read_bytes()==git(name),'Original QRC bytes '+name
    for stem,case,old_source,new_source,old_cat,new_cat in [
        ('title','title-visible.qml',BASE,TITLE,BASE,BASE),
        ('month-navigation','month-navigation.qml',TITLE,SOURCE,SOURCE,SOURCE),
        ('orthography-diagnostic','orthography-diagnostic.qml',SOURCE,SOURCE,BASE,SOURCE)]:
        receipt(stem+'-red',case,'calendar',old_source,old_cat,False)
        receipt(stem+'-green',case,'calendar',new_source,new_cat,True)
    assert json.loads((evidence/'title-red/result.json').read_text())['case_result']['title']['titleVisible'] is False
    assert 'CALENDAR_ASSERT 2018,3 2018,2 January 31' in (evidence/'month-navigation-red/native.log').read_text()
    assert 'CALENDAR_ASSERT Current Portuguese orthography:' in (evidence/'orthography-diagnostic-red/native.log').read_text()
    decode=json.loads((evidence/'wav-software-decode.json').read_text())['results']
    assert {(r['activity'],r['resource']) for r in decode}=={(a,p) for a in ACTIVITIES for p in EXTRA if p.endswith('.wav')} and len(decode)==4
    assert all(r['exit_code']==0 and r['sha256']==sha(git(r['resource'])) for r in decode)
    artifacts={str(p.relative_to(evidence)):sha(p.read_bytes()) for p in evidence.rglob('*') if p.is_file() and p.name!='index.json' and not any(part.startswith('.') or part in {'snapshot','__pycache__'} for part in p.relative_to(evidence).parts)}
    return {'passed':True,'scope':'Historical Linux Qt inputs and QRC resources only; Windows, physical devices, listening and teacher review pending','source_revision':SOURCE,'archive_revision':ARCHIVE,'levels':12,'questions':70,'wrong':12,'primary_cases':6,'regression_pairs':3,'cases':cases,'artifacts_sha256':artifacts}


if __name__=='__main__':
    result=audit();(HERE/'index.json').write_text(json.dumps(result,indent=2,ensure_ascii=False)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k not in {'artifacts_sha256','cases'}}))
