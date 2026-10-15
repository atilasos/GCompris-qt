#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Check all native proofs against current cases and index their actual counts."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
EVIDENCE=ROOT/'.scratch/pt-pt/functional-memory-math'
FAMILIES=['add','minus','mult','div','add-minus','mult-div','add-minus-mult-div']
ACTIVITIES=['memory-math-'+family+suffix for family in FAMILIES for suffix in ['', '-tux']]
FOLDERS={'gameplay':'sealed-gameplay','controls':'final-controls','restart':'final-restart','keyboard_home':'final-keyboard-home','datasets':'final-datasets'}
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--partial',action='store_true',help='Save completed proofs, explicitly list missing cases')
    args=parser.parse_args()
    manifests=set();rows=[];missing=[];case_count=0
    totals={key:0 for key in ['completed','correctPairs','wrongPairs','blockedClicks','tuxPairs','tuxTurns','losses','winSignals','lossSignals','forcedDefeats']}
    artifacts={}
    for activity in ACTIVITIES:
        row={'activity':activity}
        for case,folder in FOLDERS.items():
            directory=EVIDENCE/folder/activity/case
            path=directory/'result.json'
            if not path.exists() and args.partial:
                missing.append({'activity':activity,'case':case})
                continue
            result=json.loads(path.read_text())
            case_count+=1
            assert result['passed'] and result['exit_code']==0 and not result['qml_errors'],path
            assert result['case_result']['failures']==0,path
            assert result['network']=='docker-none',path
            assert result['case_sha256']==sha(ROOT/f'tests/functional_memory_math/{case}.qml'),path
            manifests.add(result['resource_manifest_sha256'])
            if case=='gameplay':
                data=result['case_result'];tux=activity.endswith('-tux')
                levels=9 if activity.startswith('memory-math-mult-div') else 10
                assert len(data['completed'])==levels*(1 if tux else 2),path
                assert data['winSignals']==levels*(1 if tux else 2),path
                assert data['forcedDefeats']==int(tux),path
                assert all(v['score1']+v['score2']==5 for v in data['completed']),path
                assert data['correctPairs']+data['tuxPairs']==5*(levels*(1 if tux else 2)+int(tux)+data['losses']),path
                assert data['lossSignals']==data['losses']+int(tux),path
                assert {(v['players'],v['level']) for v in data['completed']}=={(p,l) for p in ([1] if tux else [1,2]) for l in range(1,levels+1)},path
                row.update({key:(len(data[key]) if key=='completed' else data[key]) for key in totals})
                for key in totals:totals[key]+=row[key]
            for artifact in sorted(directory.iterdir()):
                if artifact.is_file() and not artifact.is_symlink():
                    artifacts[str(artifact.relative_to(EVIDENCE))]={'sha256':sha(artifact),'bytes':artifact.stat().st_size}
        rows.append(row)
    assert len(manifests)==1
    if not missing:
        assert totals['completed']==207 and totals['forcedDefeats']==7
        assert case_count==70
    manifest=EVIDENCE/'resource-manifest.json'
    assert sha(manifest)==next(iter(manifests))
    for name in ['data.log','build-identity.json','resource-manifest.json']:
        artifact=EVIDENCE/name
        artifacts[name]={'sha256':sha(artifact),'bytes':artifact.stat().st_size}
    output={'format':1,'complete':not missing,'missing_cases':missing,'native_cases':case_count,'activities':14,'totals':totals,'by_activity':rows,
        'snapshot_manifest_sha256':sha(manifest),'snapshot_file_count':len(json.loads(manifest.read_text())['files']),
        'case_sources_sha256':{case:sha(ROOT/f'tests/functional_memory_math/{case}.qml') for case in FOLDERS},
        'data_test_sha256':sha(ROOT/'tests/functional_memory_math/data.test.mjs'),
        'scope':'Named native cases only; Linux global acceptance, Windows, school, physical input/audio and teacher review pending.',
        'artifacts':artifacts}
    (EVIDENCE/('checkpoint.json' if args.partial else 'index.json')).write_text(json.dumps(output,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({'complete':not missing,'native_cases':case_count,'totals':totals},ensure_ascii=False))
if __name__=='__main__':main()
