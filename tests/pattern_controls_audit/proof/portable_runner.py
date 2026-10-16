#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Reproduce pure-module verification from physical copies without Qt/Git/network."""
import argparse, hashlib, json, shutil, subprocess, tempfile, time
from pathlib import Path
TESTS = Path(__file__).resolve().parents[2]
NAMES = ['controls2-redraw','controls3-redraw_symmetrical','controls3-mosaic',
         'controls-redraw','controls-redraw_symmetrical','controls-mosaic',
         'controls2-mosaic','controls2-redraw_symmetrical']


def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--records-root',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    if args.output.exists() or args.output.is_symlink():raise FileExistsError('Use a fresh portable report')
    identity=subprocess.check_output(['docker','image','inspect','--format','{{.Id}}','python:3.12-slim'],text=True).strip()
    results=[]
    with tempfile.TemporaryDirectory(prefix='pattern controls copied ') as temporary:
        suite=Path(temporary);suite.chmod(0o755)
        shutil.copytree(TESTS/'pattern_controls_audit',suite/'tests/pattern_controls_audit',ignore=shutil.ignore_patterns('__pycache__'))
        helper=suite/'tests/pattern_grid_solver';helper.mkdir()
        for name in ['__init__.py','solver.py']:shutil.copyfile(TESTS/'pattern_grid_solver'/name,helper/name)
        for name in NAMES:
            target=suite/'records'/name;target.mkdir(parents=True)
            shutil.copyfile(args.records_root/name/'result.json',target/'result.json')
        manifest={'code':{p.relative_to(suite).as_posix():sha(p) for p in sorted((suite/'tests').rglob('*.py'))},
                  'records':{p.relative_to(suite).as_posix():sha(p) for p in sorted((suite/'records').rglob('result.json'))}}
        (suite/'manifest.json').write_text(json.dumps(manifest))
        for optimized in [False,True]:
            bootstrap='''import ctypes.util,hashlib,json,pathlib,shutil,subprocess,sys
suite=pathlib.Path('/suite');manifest=json.loads((suite/'manifest.json').read_text())
if pathlib.Path('/home/proteu/Projetos').exists() or shutil.which('git') or ctypes.util.find_library('Qt6Core'):
 raise RuntimeError('Original tree, Git or Qt unexpectedly available')
for entries in manifest.values():
 for name,digest in entries.items():
  if hashlib.sha256((suite/name).read_bytes()).hexdigest()!=digest:raise RuntimeError('Physical copied bytes differ')
flags=FLAGS
commands=[[sys.executable,*flags,'-m','unittest','discover','-s','/suite/tests/pattern_controls_audit','-p','test_*.py','-v'],[sys.executable,*flags,'-m','pattern_controls_audit.verify_records','--root-evidence','/suite/records']]
results=[]
for command in commands:
 run=subprocess.run(command,capture_output=True,text=True)
 results.append({'argv':command,'exit_code':run.returncode,'stdout':run.stdout,'stderr':run.stderr})
print(json.dumps({'isolation':'physical code/raw-record copies; no network/Qt/Git/original tree','python':sys.version,'checks':results}),flush=True)
if any(r['exit_code']!=0 for r in results):raise SystemExit(1)
'''.replace('FLAGS',repr(['-O'] if optimized else []))
            command=['docker','run','--rm','--pull=never','--network=none','--read-only','--cap-drop=ALL','--security-opt=no-new-privileges','--user','1000:1000','--tmpfs','/tmp:rw,mode=1777,size=128m','--mount',f'type=bind,src={suite},dst=/suite,readonly','--env','PYTHONPATH=/suite/tests','--env','PYTHONDONTWRITEBYTECODE=1',identity,'python','-c',bootstrap]
            start=time.monotonic();run=subprocess.run(command,capture_output=True,text=True)
            results.append({'source_commit':'76db3ceba','optimized':optimized,'image_id':identity,'argv':command,
                            'exit_code':run.returncode,'stdout':run.stdout,'stderr':run.stderr,
                            'seconds':round(time.monotonic()-start,3),'copied_sha256':manifest})
            if run.returncode:break
    with args.output.open('x') as stream:stream.write(json.dumps(results,indent=2)+'\n')
    print(json.dumps({'modes':len(results),'exit_codes':[r['exit_code'] for r in results],'report':str(args.output)}))
    if any(r['exit_code'] for r in results):raise SystemExit(1)


if __name__=='__main__':main()
