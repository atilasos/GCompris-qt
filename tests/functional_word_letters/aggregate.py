#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Audit disjoint Hangman campaign receipts without altering their identities."""
import argparse
import hashlib
import json
from pathlib import Path

from audit import check_report


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def archived_path(root,relative):
    path=Path(relative)
    if path.is_absolute() or '..' in path.parts:
        raise ValueError('Archive inputs must be relative to the evidence')
    result=root/path
    if not result.resolve().is_relative_to(root.resolve()):
        raise ValueError('Archive input escapes the evidence directory')
    return result


def aggregate(outputs):
    root=outputs[0].parent
    if any(output.parent.resolve()!=root.resolve() for output in outputs):
        raise ValueError('Campaigns must share one evidence directory')
    archive=json.loads((root/'sealed-inputs/historical/archive.json').read_text())
    if archive['format']!=1:raise ValueError('Unsupported archive format')
    corpus_path=archived_path(root,archive['corpus']['path'])
    if sha(corpus_path)!=archive['corpus']['sha256']:
        raise ValueError('Archived corpus hash mismatch')
    data=json.loads(corpus_path.read_text())
    expected={}
    for dataset,lessons in data['datasets'].items():
        for index,lesson in enumerate(lessons):
            for image in (False,True):
                for audio in (False,True):
                    name=f'hangman-{"full" if dataset=="words.json" else "sample"}-lesson{index+1:02}-image{str(image).lower()}-audio{str(audio).lower()}'
                    expected[name]=(index,dataset=='words.json',image,audio,len(lesson['words']))
    rows=[]
    seen=set()
    errors=[]
    for output in outputs:
        summary=output/'summary.json'
        for row in json.loads(summary.read_text()):
            name=row['name']
            report_path=archived_path(output,row['report'])
            report=json.loads(report_path.read_text())
            problems=check_report(report,data)
            if name in seen:problems.append('Duplicate campaign receipt')
            seen.add(name)
            if not row['passed'] or row['launcher_exit']!=0:problems.append('Campaign launcher did not pass')
            if sha(report_path)!=row['report_sha256']:problems.append('Archived report hash mismatch')
            case_path=archived_path(root,archive['cases'][row['case_sha256']])
            if sha(case_path)!=row['case_sha256'] or report['case_sha256']!=row['case_sha256']:
                problems.append('Archived case hash mismatch')
            if report['resource_manifest_sha256']!=row['snapshot_sha256']:
                problems.append('Resource identity mismatch')
            source_record=archive['sources'][row['frozen_source_sha256']]
            frozen=archived_path(root,source_record['path'])
            manifest_path=frozen/'source-manifest.json'
            if sha(manifest_path)!=source_record['manifest_sha256']:
                problems.append('Archived source manifest hash mismatch')
            manifest=json.loads(manifest_path.read_text())
            frozen_sha=hashlib.sha256(json.dumps(manifest,sort_keys=True).encode()).hexdigest()
            if row['frozen_source_sha256']!=frozen_sha or any(sha(archived_path(frozen,path))!=value for path,value in manifest.items()):
                problems.append('Frozen source identity mismatch')
            launcher=archived_path(root,archive['launchers'][report['runner_sha256']])
            if report['runner_sha256']!=sha(launcher):problems.append('Native launcher identity mismatch')
            if name not in expected:problems.append('Unexpected campaign')
            else:
                lesson,external,image,audio,words=expected[name]
                value=report['case_result']
                if (value['lesson'],value['externalWords'],value['imageHint'],value['audioHint'])!=(lesson,external,image,audio):
                    problems.append('Campaign configuration mismatch')
                if len(value['completed'])!=words or row['completed']!=words:problems.append('Wrong lesson completion count')
            rows.append({'name':name,'report':report_path.relative_to(root).as_posix(),'report_sha256':sha(report_path),
                         'completed':row['completed'],'passed':not problems,'errors':problems})
            errors.extend(name+': '+problem for problem in problems)
    missing=sorted(set(expected)-seen)
    if missing:errors.append(f'Missing {len(missing)} campaigns')
    return {'passed':bool(rows) and not errors,'campaigns':len(rows),
            'words':sum(row['completed'] for row in rows),'expected_campaigns':len(expected),
            'missing':missing,'errors':errors,'receipts':rows}


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('outputs',type=Path,nargs='+')
    args=parser.parse_args()
    result=aggregate(args.outputs)
    print(json.dumps(result,ensure_ascii=False,indent=2))
    return 0 if result['passed'] else 1


if __name__=='__main__':raise SystemExit(main())
