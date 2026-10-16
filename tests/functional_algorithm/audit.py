#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Audit fixed native algorithm artifacts without the original runtime paths."""
import ast
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT=Path(__file__).resolve().parents[2]
HERE=ROOT/'.scratch/pt-pt/functional-algorithm'
SOURCE='ad6f5706f'
CAPTURE='8a8f9c00a13fdcdf58c38cb9c09cbc674824f252'
SUPERVISOR='dd5a27b9b'
PREFIX='.scratch/pt-pt/functional-algorithm/'
QML='src/activities/algorithm/Algorithm.qml'
CAT='poqm/pt/gcompris_qt.po'
RUNNER='tools/run-native-qml-case.py'
FRUITS=['apple','banana','cherries','lemon','orange','pear','pineapple','plum']
EXTRA={f'src/activities/enumerate/resource/{name}.svg' for name in FRUITS+['question_mark']}|{f'src/core/resource/sounds/{name}.wav' for name in ['completetask','brick','bleep']}


def sha(data):return hashlib.sha256(data).hexdigest()

def git(path,revision=SOURCE):return subprocess.check_output(['git','show',revision+':'+path],cwd=ROOT)

def canonical(sequence):
    mapping={};result=[]
    for symbol in sequence:
        if symbol not in mapping:mapping[symbol]=len(mapping)
        result.append(mapping[symbol])
    return result


def audit(evidence=HERE):
    evidence=Path(evidence)
    identity=json.loads((evidence/'source-identity.json').read_text())
    required=set(subprocess.check_output(['git','ls-tree','-r','--name-only',SOURCE,'--','src/activities/algorithm'],cwd=ROOT,text=True).splitlines())|EXTRA|{CAT,RUNNER}
    assert identity['revision']==SOURCE and identity['supervisor_revision']==SUPERVISOR and set(identity['files'])==required
    assert all(digest==sha(git(name)) for name,digest in identity['files'].items())
    assert (evidence/'supervisor.py').read_bytes()==git('tools/run-native-qml-supervised.py',SUPERVISOR)
    snapshot_bytes=(evidence/'resource-snapshot.json').read_bytes();assert snapshot_bytes==git(PREFIX+'resource-snapshot.json',CAPTURE)
    snapshot=json.loads(snapshot_bytes);assert len(snapshot['files'])==269
    data_bytes=(evidence/'data.json').read_bytes();assert data_bytes==git(PREFIX+'data.json',CAPTURE)
    data=json.loads(data_bytes);assert data['sha256']==identity['files']['src/activities/algorithm/algorithm.js']
    text=git('src/activities/algorithm/algorithm.js').decode();start=text.index('[',text.index('var sample ='));depth=0
    for end in range(start,len(text)):
        depth+=(text[end]=='[')-(text[end]==']')
        if depth==0:break
    assert data['levels']==ast.literal_eval(re.sub(r'//[^\n]*','',text[start:end+1]))
    assert data['examples']==28 and data['unique_patterns']==27
    namespace={'__file__':str(ROOT/'tests/functional_algorithm/patterns.py'),'__name__':'historical_algorithm_patterns'}
    exec(compile(git('tests/functional_algorithm/patterns.py',CAPTURE),'<historical algorithm oracle>','exec'),namespace)
    complete=namespace['complete']
    for level in data['levels']:
        for sample in level:complete(sample,[f'symbol-{n}' for n in sample[:4]])
    cases=[]
    for name in ['full','controls','resources']:
        directory=evidence/name
        for file in ['result.json','launcher-status.json']:
            assert (directory/file).read_bytes()==git(PREFIX+name+'/'+file,CAPTURE),'Frozen execution artifact '+name+'/'+file
        result_bytes=(directory/'result.json').read_bytes();result=json.loads(result_bytes)
        status=json.loads((directory/'launcher-status.json').read_text())
        assert status['format']==1 and status['kind']=='observed-subprocess-exit' and status['exit_code']==0
        assert status['native_receipt_sha256']==sha(result_bytes) and status['case_sha256']==result['case_sha256'] and status['launcher_sha256']==identity['files'][RUNNER]
        assert result['passed'] is True and result['exit_code']==0 and result['timeout'] is False and not result['qml_errors']
        assert result['activity']=='algorithm' and result['locale']=='pt_PT' and result['network']=='docker-none'
        assert result['runtime_uid']==result['runtime_gid']==1000 and result['private_file_ownership_verified'] and not result['deployment_retained']
        assert result['source_sha256']==identity['files'][QML] and result['portuguese_catalogue_sha256']==identity['files'][CAT]
        assert result['runner_sha256']==identity['files'][RUNNER] and result['qml_file']=='algorithm/Algorithm.qml'
        assert (evidence/(name+'.qml')).read_bytes()==git(PREFIX+name+'.qml',CAPTURE)
        assert result['case_sha256']==sha((evidence/(name+'.qml')).read_bytes())
        assert result['binary_sha256']==snapshot['files']['bin/gcompris-qt'] and result['resource_manifest_sha256']==sha(snapshot_bytes)
        effective=dict(snapshot['files']);effective['share/gcompris-qt/rcc/algorithm.rcc']=result['private_rcc_sha256'];effective['share/gcompris-qt/translations/gcompris_qt_pt.qm']=result['private_qm_sha256']
        assert result['resource_files_sha256']==effective
        assert result['case_result']['failures']==0
        for shot in result['screenshots']:assert sha((directory/shot['file']).read_bytes())==shot['sha256']
        cases.append({'case':name,'passed':True})
    full=json.loads((evidence/'full/result.json').read_text())['case_result']
    assert full['completed']==list(range(1,8)) and full['correct']==84 and full['rejected']==21 and len(full['puzzles'])==21
    allowed={'qrc:/gcompris/src/activities/enumerate/resource/'+fruit+'.svg' for fruit in FRUITS}
    observed={level:set() for level in range(1,8)}
    for level in range(1,8):
        puzzles=[p for p in full['puzzles'] if p['level']==level];assert len(puzzles)==3
        published={tuple(canonical(p)) for p in data['levels'][level-1]}
        for puzzle in puzzles:
            reference,prefix,answer=puzzle['reference'],puzzle['prefix'],puzzle['answer']
            assert set(reference+prefix+answer)<=allowed
            assert answer==prefix+complete(reference,prefix)
            pattern=tuple(canonical(reference));assert pattern in published;observed[level].add(pattern)
    control=json.loads((evidence/'controls/result.json').read_text())['case_result']['controls']
    assert all(control[k] is True for k in ['leftRight','selectionKeys','restart','navigation','helpPortuguese','escape','inputAfterHelp'])
    resources=json.loads((evidence/'resources/result.json').read_text())['case_result']['resources']
    expected_resources=sorted(EXTRA|{name for name in required if name.startswith('src/activities/algorithm/') and Path(name).suffix in {'.qml','.js','.svg'} and name!=QML})
    assert resources==expected_resources and len(resources)==16
    for name in resources:assert (evidence/'resources/resources'/name).read_bytes()==git(name)
    decoded=json.loads((evidence/'wav-software-decode.json').read_text())['results']
    assert len(decoded)==3 and {r['resource'] for r in decoded}=={name for name in EXTRA if name.endswith('.wav')}
    assert all(r['exit_code']==0 and r['sha256']==sha(git(r['resource'])) for r in decoded)
    artifacts={str(p.relative_to(evidence)):sha(p.read_bytes()) for p in evidence.rglob('*') if p.is_file() and p.name!='index.json' and not any(part.startswith('.') or part in {'snapshot','__pycache__'} for part in p.relative_to(evidence).parts)}
    return {'passed':True,'scope':'Historical Linux Qt inputs only; observed random patterns are a subset. Windows, physical devices, audio listening and teacher review pending','source_revision':SOURCE,'capture_revision':CAPTURE,'supervisor_revision':SUPERVISOR,'levels':7,'puzzles':21,'correct':84,'rejected':21,'published_examples':28,'observed_patterns':sum(map(len,observed.values())),'cases':cases,'artifacts_sha256':artifacts}


if __name__=='__main__':
    result=audit();(HERE/'index.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k not in {'artifacts_sha256','cases'}}))
