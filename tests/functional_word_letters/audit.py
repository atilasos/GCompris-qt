#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Independently check native word/letter lesson reports against the PT corpus."""
from collections import Counter
import json
from pathlib import Path
import sys

from corpus import corpus


def check_report(report, data=None):
    result=report.get('case_result') or {}
    activity=report['activity']
    dataset='words.json' if result['externalWords'] else 'words_sample.json'
    lessons=(corpus() if data is None else data)['datasets'][dataset]
    lesson=lessons[result['lesson']]
    words={word['image'].split('/')[-1].replace('.webp','.ogg'):word['text'] for word in lesson['words']}
    completed=result.get('completed',[])
    errors=[]
    if not report['passed'] or report['exit_code']!=0:errors.append('Native report did not pass')
    if report['network']!='docker-none':errors.append('Network was not disabled')
    if activity=='hangman':
        keys=[row['key'] for row in completed]
        if len(keys)!=len(words) or set(keys)!=set(words):errors.append('Lesson word set incomplete or repeated')
        if [row['ordinal'] for row in completed]!=list(range(1,len(words)+1)):errors.append('Word ordinals incomplete')
        if any(row['word']!=words.get(row['key']) for row in completed):errors.append('Incorrect spelling')
        if any(row['remainingLife'] not in (3,6) for row in completed):errors.append('Unexpected life accounting')
        if not result['physicalInputs'] or not result['virtualInputs']:errors.append('Input channel missing')
    else:
        seen=set()
        board=None
        for row in completed:
            keys=row['cards']
            if board is not None and keys!=board:errors.append('Board changed within the lesson')
            board=keys
            if len(keys)!=min(result['mode'],len(words)) or len(set(keys))!=len(keys) or not set(keys)<=set(words):
                errors.append('Invalid selected board')
                continue
            frequency=Counter(''.join(words[key] for key in keys).replace(' ',''))
            expected_questions=min(10,len(frequency))
            if len(completed)!=expected_questions:errors.append('Question set incomplete')
            question=row['question']
            if question in seen:errors.append('Repeated question')
            seen.add(question)
            if frequency.get(question,0)<sorted(frequency.values(),reverse=True)[expected_questions-1]:errors.append('Question outside frequency threshold')
            wanted={key for key in keys if question in set(words[key])}
            if set(row['selected'])!=wanted or len(row['selected'])!=len(wanted):errors.append('Incorrect card selection')
            allowed_cases=(1,2) if result['letterCase']==0 else (result['letterCase'],)
            if row['capitalization'] not in allowed_cases:errors.append('Incorrect visual case')
        if not completed:errors.append('No completed questions')
    return sorted(set(errors))


def audit(output):
    rows=[]
    for checkpoint in sorted(Path(output).glob('*/attempt*/checkpoint.json')):
        value=json.loads(checkpoint.read_text())
        if not value['passed']:continue
        report=json.loads((Path(output)/value['report']).read_text())
        errors=check_report(report)
        if value['launcher_exit']!=0:errors.append('Launcher failed')
        rows.append({'name':value['name'],'report':value['report'],'completed':value['completed'],'passed':not errors,'errors':errors})
    return rows


if __name__=='__main__':
    rows=audit(Path(sys.argv[1]))
    print(json.dumps(rows,ensure_ascii=False,indent=2))
    raise SystemExit(0 if rows and all(row['passed'] for row in rows) else 1)
