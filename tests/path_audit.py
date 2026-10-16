#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Audit immutable path evidence without running Qt or opening old worktrees."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys

sys.path.insert(0,str(Path(__file__).resolve().parent))
from path_data import ACTIVITIES, matrices, validate
from path_resources import EXTRA

ROOT=Path(__file__).resolve().parents[1]
HERE=ROOT/'.scratch/pt-pt/functional-paths'
GAME='be9df9911'
CONTROL='7273ac208b596a34c3c3e8a7388b7c91ce3b53ff'
CASES='84dca6830'
CAT='poqm/pt/gcompris_qt.po'
RUNNER='tools/run-native-qml-case.py'
INJECTED='src/activities/path_encoding/GridPath.qml'


def digest(data): return hashlib.sha256(data).hexdigest()

def git(path, revision=GAME):
    return subprocess.check_output(['git','show',revision+':'+path],cwd=ROOT)


def audit(evidence=HERE):
    evidence=Path(evidence)
    identity=json.loads((evidence/'source-identity.json').read_text())
    expected=set(subprocess.check_output(['git','ls-tree','-r','--name-only',GAME,'--',*[f'src/activities/{a}' for a in ACTIVITIES]],cwd=ROOT,text=True).splitlines())|{CAT,RUNNER}
    assert set(identity)==expected, 'Exact historical source inventory'
    assert all(value==digest(git(name)) for name,value in identity.items()), 'Historical source SHA'
    snapshot=json.loads((evidence/'resource-snapshot.json').read_text())
    assert len(snapshot['files'])==269
    assert digest((evidence/'resource-snapshot.json').read_bytes())=='81e55b723f2f047a8234e95df934fea30ecf4311155cf3357e77b3008eaa179b'
    manifest_sha=digest((evidence/'resource-snapshot.json').read_bytes())
    results=[]
    for activity in ACTIVITIES:
        resource_paths=sorted(set(EXTRA)|{name for name in expected if any(name.startswith('src/activities/'+a+'/') for a in {'path_encoding',activity}) and Path(name).suffix in {'.qml','.js','.svg'} and Path(name).name!='GridPath.qml'})
        authored=[]
        for n in range(1,5):
            authored.extend(validate(matrix) for matrix in matrices(git(f'src/activities/{activity}/resource/{n}/Data.qml').decode()))
        assert len(authored)==7
        for kind,casefile,revision in [('full','full.qml',GAME),('controls-fixed','controls-fixed.qml',CONTROL),('resources',f'resources-{activity}.qml',CONTROL)]:
            directory=evidence/f'{kind}-{activity}'
            receipt=json.loads((directory/'result.json').read_text())
            assert receipt['passed'] is True and receipt['exit_code']==0 and receipt['timeout'] is False
            assert receipt['activity']==activity and receipt['locale']=='pt_PT' and receipt['network']=='docker-none'
            assert receipt['qml_file']=='path_encoding/GridPath.qml'
            assert not receipt['qml_errors'] and receipt['runtime_uid']==receipt['runtime_gid']==1000
            assert receipt['private_file_ownership_verified'] and not receipt['deployment_retained']
            assert receipt['source_sha256']==digest(git(INJECTED))
            assert receipt['runner_sha256']==digest(git(RUNNER))
            assert receipt['portuguese_catalogue_sha256']==digest(git(CAT,revision))
            assert receipt['case_sha256']==digest((evidence/casefile).read_bytes())
            assert receipt['case_sha256']==digest(git('.scratch/pt-pt/functional-paths/'+casefile,CASES)), 'Immutable archived case'
            assert receipt['resource_manifest_sha256']==manifest_sha
            effective=dict(snapshot['files'])
            effective['share/gcompris-qt/rcc/path_encoding.rcc']=receipt['private_rcc_sha256']
            effective['share/gcompris-qt/translations/gcompris_qt_pt.qm']=receipt['private_qm_sha256']
            assert receipt['resource_files_sha256']==effective, 'Exact effective snapshot files'
            assert receipt['binary_sha256']==snapshot['files']['bin/gcompris-qt']
            for shot in receipt['screenshots']:
                assert digest((directory/shot['file']).read_bytes())==shot['sha256']
            result=receipt['case_result'];assert result['failures']==0
            if kind=='full':
                assert [r['level'] for r in result['completed']]==list(range(1,8))
                assert [r['moves'] for r in result['completed']]==[r['moves'] for r in authored]
                assert result['moves']==sum(r['moves'] for r in authored) and result['rejected']==7
            elif kind=='controls-fixed':
                control=result['controls'];assert control['activity']==activity
                assert [control[k] for k in ['datasets','levels','reducedLevels']]==[4,7,5]
                assert all(control[k] is True for k in ['configurationSaved','restartClearedPartial','helpEscape','moveAfterHelp','navigation'])
                assert control['title']==('Codificação de caminhos relativos' if activity=='path_encoding_relative' else {'path_encoding':'Codificação de caminhos','path_decoding':'Descodificação de caminhos','path_decoding_relative':'Descodificação de caminhos relativos'}[activity])
            else:
                assert result['resources']==resource_paths
                for name in resource_paths:
                    assert (directory/'resources'/name).read_bytes()==git(name), 'Original QRC resource bytes '+name
                assert [d['source'] for d in result['datasets']]==[f'src/activities/{activity}/resource/{n}/Data.qml' for n in range(1,5)]
                for dataset in result['datasets']:
                    assert dataset['matrices']==matrices(git(dataset['source']).decode()), 'Runtime authored matrices'
            results.append({'activity':activity,'kind':kind,'passed':True})
    red=json.loads((evidence/'title-exact-red/result.json').read_text())
    green=json.loads((evidence/'controls-fixed-path_encoding_relative/result.json').read_text())
    assert red['case_sha256']==green['case_sha256'] and red['passed'] is False
    assert red['portuguese_catalogue_sha256']==digest(git(CAT))
    decode=json.loads((evidence/'wav-software-decode.json').read_text())['results']
    assert len(decode)==12
    assert {(r['activity'],r['resource']) for r in decode}=={(a,p) for a in ACTIVITIES for p in EXTRA if p.endswith('.wav')}
    assert all(r['exit_code']==0 and r['sha256']==digest(git(r['resource'])) for r in decode)
    artifacts={str(p.relative_to(evidence)):digest(p.read_bytes()) for p in evidence.rglob('*') if p.is_file() and not any(part.startswith('.') or part in {'snapshot','__pycache__'} for part in p.relative_to(evidence).parts) and p.name!='index.json'}
    return {'passed':True,'scope':'Historical Linux Qt interaction and QRC bytes; no Windows, physical audio or teacher approval','game_revision':GAME,'control_catalogue_revision':CONTROL,'levels':28,'moves':829,'rejected':28,'cases':results,'artifacts_sha256':artifacts}


if __name__=='__main__':
    result=audit()
    (HERE/'index.json').write_text(json.dumps(result,indent=2,ensure_ascii=False)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k not in {'artifacts_sha256','cases'}},ensure_ascii=False))
