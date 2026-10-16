#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Capture exact historical Hangman inputs before removing their old worktree."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def capture(evidence):
    destination=evidence/'sealed-inputs/historical'
    destination.mkdir(exist_ok=False)
    archive={'format':1,'cases':{},'sources':{},'launchers':{},
             'corpus':{'path':'corpus.json','sha256':sha(evidence/'corpus.json')}}
    for name in ('hangman-final','hangman-remaining-full','hangman-remaining-sample'):
        output=evidence/name
        for row in json.loads((output/'summary.json').read_text()):
            report_path=output/row['report']
            assert sha(report_path)==row['report_sha256']
            report=json.loads(report_path.read_text())
            command=row['command']
            case=output/Path(command[command.index('--case')+1]).name
            assert sha(case)==row['case_sha256']==report['case_sha256']
            archive['cases'][row['case_sha256']]=case.relative_to(evidence).as_posix()
            source_id=row['frozen_source_sha256']
            if source_id not in archive['sources']:
                original=Path(command[command.index('--source-root')+1])
                manifest=json.loads((original/'source-manifest.json').read_text())
                assert hashlib.sha256(json.dumps(manifest,sort_keys=True).encode()).hexdigest()==source_id
                target=destination/'sources'/source_id
                target.mkdir(parents=True)
                for path,digest in manifest.items():
                    assert sha(original/path)==digest
                    copied=target/path;copied.parent.mkdir(parents=True,exist_ok=True)
                    shutil.copyfile(original/path,copied)
                shutil.copyfile(original/'source-manifest.json',target/'source-manifest.json')
                archive['sources'][source_id]={'path':target.relative_to(evidence).as_posix(),
                    'manifest_sha256':sha(target/'source-manifest.json')}
            launcher_id=report['runner_sha256']
            if launcher_id not in archive['launchers']:
                original=Path(command[1]);assert sha(original)==launcher_id
                target=destination/'launchers'/(launcher_id+'.py')
                target.parent.mkdir(exist_ok=True)
                shutil.copyfile(original,target)
                archive['launchers'][launcher_id]=target.relative_to(evidence).as_posix()
    destination.joinpath('archive.json').write_text(json.dumps(archive,indent=2)+'\n')
    return archive


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('evidence',type=Path)
    args=parser.parse_args()
    value=capture(args.evidence)
    print(json.dumps({key:len(value[key]) for key in ('cases','sources','launchers')}))
