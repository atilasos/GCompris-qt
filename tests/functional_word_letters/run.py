#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Checkpoint full native lessons independently, with bounded parallelism."""
import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
import hashlib
import json
from pathlib import Path
import subprocess
import shutil
import sys
from datetime import datetime,timezone
from collections import Counter

from corpus import ROOT,corpus


def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()


def source_digest(folder):
    digest=hashlib.sha256()
    for path in sorted(folder.rglob('*')):
        if path.is_file():
            digest.update(path.relative_to(folder).as_posix().encode())
            digest.update(path.read_bytes())
    return digest.hexdigest()




def canonical_case(text):
    lines=[]
    for line in text.splitlines():
        prefix,separator,value=line.partition(':')
        if prefix.strip() in ('property var expectedWords','property var incidence','property var counts'):
            line=prefix+separator+json.dumps(json.loads(value),sort_keys=True,ensure_ascii=False)
        lines.append(line)
    return '\n'.join(lines)


def freeze_sources(activity):
    paths=[path for path in (ROOT/'src/activities'/activity).rglob('*') if path.is_file()]
    paths += [ROOT/'CMakeLists.txt',ROOT/'poqm/pt/gcompris_qt.po',
              ROOT/'build/functional-input/libfunctionalinput.so',ROOT/'build/functional-input/qmldir']
    manifest={path.relative_to(ROOT).as_posix():sha(path) for path in sorted(paths)}
    digest=hashlib.sha256(json.dumps(manifest,sort_keys=True).encode()).hexdigest()
    frozen=ROOT/'build/word-letter-sources'/digest
    if not frozen.exists():
        frozen.mkdir(parents=True)
        for path in paths:
            destination=frozen/path.relative_to(ROOT)
            destination.parent.mkdir(parents=True,exist_ok=True)
            shutil.copy2(path,destination)
        (frozen/'source-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    assert json.loads((frozen/'source-manifest.json').read_text())==manifest
    assert all(sha(frozen/path)==value for path,value in manifest.items()), 'Frozen source input changed'
    return frozen,digest


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--full-snapshot',type=Path,required=True)
    parser.add_argument('--sample-snapshot',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--jobs',type=int,default=8)
    parser.add_argument('--resume',action='store_true')
    parser.add_argument('--dataset',choices=['all','full','sample'],default='all')
    parser.add_argument('--activity',choices=['hangman','letter-in-word'],default='hangman')
    parser.add_argument('--lesson',type=int,action='append',help='Optional1-based tracer lesson filter')
    args=parser.parse_args()
    if args.jobs<1:parser.error('jobs must be positive')
    data=corpus()
    datasets={name:lessons for name,lessons in data['datasets'].items()
              if args.dataset=='all' or name==('words.json' if args.dataset=='full' else 'words_sample.json')}
    available_lessons={index+1 for lessons in datasets.values() for index in range(len(lessons))}
    if not available_lessons or set(args.lesson or [])-available_lessons:
        parser.error('No applicable lessons for the selected lesson numbers')
    if args.output.exists() and not args.resume:parser.error('Use new output or explicit --resume')
    args.output.mkdir(parents=True,exist_ok=True)
    template=(Path(__file__).parent/(args.activity+'.qml')).read_text()
    source=ROOT/'src/activities'/args.activity/('Hangman.qml' if args.activity=='hangman' else 'LetterInWord.qml')
    current_source_sha=source_digest(source.parent)
    launcher_sha=sha(ROOT/'tools/run-native-qml-case.py')
    frozen_root,frozen_sha=freeze_sources(args.activity)
    frozen_source=frozen_root/source.relative_to(ROOT)
    tasks=[]
    for dataset,lessons in datasets.items():
        external=dataset=='words.json'
        snapshot=(args.full_snapshot if external else args.sample_snapshot).resolve()
        for index,lesson in enumerate(lessons):
            if args.lesson and index+1 not in args.lesson:continue
            modes=[{'IMAGE':str(image).lower(),'AUDIO':str(audio).lower()} for image in (False,True) for audio in (False,True)] if args.activity=='hangman' else [{'MODE':str(size),'CASE':str(case)} for size in (5,11) for case in (0,1,2)]
            for mode in modes:
                mode_name='-'.join(k.lower()+v for k,v in mode.items())
                name=f'{args.activity}-{"full" if external else "sample"}-lesson{index+1:02}-{mode_name}'
                words={word['image'].split('/')[-1].replace('.webp','.ogg'):word['text'] for word in lesson['words']}
                incidence={character:[key for key,text in words.items() if character in set(text)-{' '}] for character in sorted(set(''.join(words.values()))-{' '})}
                frequencies={key:dict(Counter(text.replace(' ',''))) for key,text in words.items()}
                values={'INCIDENCE':json.dumps(incidence,ensure_ascii=False),'FREQUENCIES':json.dumps(frequencies,ensure_ascii=False),'WORDS':json.dumps(words,ensure_ascii=False),'LESSON':str(index),'EXTERNAL':str(external).lower(),**mode}
                text=template
                for key,value in values.items():text=text.replace('__'+key+'__',value)
                case=args.output/(name+'.qml')
                if case.exists():
                    if canonical_case(case.read_text())==canonical_case(text):
                        text=case.read_text()
                    else:
                        case=args.output/(name+'-'+hashlib.sha256(text.encode()).hexdigest()[:16]+'.qml')
                case.write_text(text)
                tasks.append({'name':name,'snapshot':snapshot,'case':case,'expected':len(words),'lesson':index,'mode':mode,'external':external})
    # Avoid a long final tail from the largest lessons.
    tasks.sort(key=lambda task:task['expected'],reverse=True)

    def run(task):
        name=task['name']; previous=sorted(args.output.glob(name+'/attempt*/checkpoint.json'))
        for checkpoint in reversed(previous):
            row=json.loads(checkpoint.read_text())
            if row['passed'] and row['launcher_exit']==0 and row.get('frozen_source_sha256')==frozen_sha and row.get('launcher_sha256')==launcher_sha and sha(args.output/row['report'])==row['report_sha256'] and row['case_sha256']==sha(task['case']) and row['source_sha256']==current_source_sha and row['snapshot_sha256']==sha(task['snapshot']/'manifest.json'):
                return row
        attempts=list(args.output.glob(name+'/attempt[0-9][0-9]'))
        attempt=max([int(path.name[7:]) for path in attempts] or [0])+1
        output=args.output/name/f'attempt{attempt:02}'
        command=[sys.executable,str(ROOT/'tools/run-native-qml-case.py'),'--resource-snapshot',str(task['snapshot']),
            '--source-root',str(frozen_root),'--activity',args.activity,'--qml-file',str(frozen_source),'--case',str(task['case'].resolve()),
            '--start-level',str(task['lesson']+1),'--output',str(output.resolve()),'--timeout',str(task['expected']*12+120),'--offline']
        output.parent.mkdir(parents=True,exist_ok=True)
        with (output.parent/f'attempt{attempt:02}.launcher.log').open('w') as log:
            result=subprocess.run(command,cwd=ROOT,stdout=log,stderr=subprocess.STDOUT)
        report=json.loads((output/'result.json').read_text()) if (output/'result.json').exists() else {}
        case_result=report.get('case_result') or {}
        completions=case_result.get('completed',[])
        actual=len(completions)
        expected=task['expected'] if args.activity=='hangman' else case_result.get('expectedQuestions',-1)
        row={'name':name,'command':command,'launcher_exit':result.returncode,'passed':result.returncode==0 and report.get('passed',False) and actual==expected,
            'frozen_source_sha256':frozen_sha,'launcher_sha256':launcher_sha,'expected':expected,'completed':actual,'case_sha256':sha(task['case']),'source_sha256':current_source_sha,
            'snapshot_sha256':sha(task['snapshot']/'manifest.json'),'report_sha256':sha(output/'result.json') if (output/'result.json').exists() else None,
            'report':str((output/'result.json').relative_to(args.output)),'utc':datetime.now(timezone.utc).isoformat()}
        output.mkdir(parents=True,exist_ok=True)
        (output/'checkpoint.json').write_text(json.dumps(row,indent=2)+'\n')
        print(json.dumps(row),flush=True)
        return row
    rows=[]
    with ThreadPoolExecutor(max_workers=args.jobs) as pool:
        for future in as_completed([pool.submit(run,task) for task in tasks]):
            rows.append(future.result())
            (args.output/'summary.json').write_text(json.dumps(sorted(rows,key=lambda row:row['name']),indent=2)+'\n')
    return 0 if rows and all(row['passed'] for row in rows) else 1


if __name__=='__main__':raise SystemExit(main())
