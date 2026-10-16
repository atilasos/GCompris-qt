#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Seal finished creation evidence once, including physical runtime resources."""
import argparse,hashlib,json,subprocess,tempfile,zipfile
from pathlib import Path
from phase import verify_source,ACTIVITIES
if not __debug__:raise SystemExit('Creation sealing rejects Python -O')
ROOT=Path(__file__).resolve().parents[2];BASE=ROOT/'.scratch/pt-pt/functional-creation'
def sha(raw):return hashlib.sha256(raw).hexdigest()
def seal(output):
 if output.exists():raise ValueError('New capsule output required')
 objects={};files={};phases={};cases={}
 def store(raw):
  digest=sha(raw);objects[digest]=raw;return digest
 def tree(path,prefix):
  for p in sorted(path.rglob('*')):
   if p.is_file():
    assert not p.is_symlink();files[prefix+'/'+p.relative_to(path).as_posix()]=store(p.read_bytes())
 revisions=['7992a59d814e72cdbca811a8f3e0f19425c70264','4a4e636b615b228c559d2ad3349c55b4b878f675','9c1fa4b621f377593a6251338677c0f1f525a413','728cfdc72f48e048b70d969d22ef166c2206bb8e','416ddcc9dd331e8072c7f4a7e69bf3339ac86655']
 initial=set('sketch-gl-inventory sketch-gl-inventory-v2 simplepaint-levels simplepaint-levels-v2 simplepaint-levels-v3 simplepaint-levels-v4 simplepaint-levels-v5 sketch-tracer sketch-tracer-v2 sketch-shortcut-red wheels-shortcut-red wheels-shortcut-red-v2'.split())
 for revision in revisions:
  source=ROOT/'build/creation-sources'/revision;manifest=verify_source(source);phases[revision]={'source':manifest,'historical_source':str(source)}
  for name,digest in manifest['files'].items():assert store((source/name).read_bytes())==digest
 for directory in sorted(BASE.iterdir()):
  if directory.name.startswith('.') or not directory.is_dir() or not (directory/'result.json').exists():continue
  receipt=json.loads((directory/'result.json').read_text());assert (directory/'tool-exit.json').is_file() and (directory/'supervisor-exit.json').is_file()
  options=[rev for rev,value in phases.items() if value['source']['files']['src/activities/'+receipt['qml_file']] == receipt['source_sha256'] and value['source']['files']['poqm/pt/gcompris_qt.po']==receipt['portuguese_catalogue_sha256'] and value['source']['files']['tools/run-native-qml-case.py']==receipt['runner_sha256']]
  assert options,directory.name
  # Identical content across phases is bound to all compatible historical trees.
  cases[directory.name]={'compatible_phases':options,'capturer':'initial.py' if directory.name in initial else 'with-creations.py','native':receipt['exit_code'],'passed':receipt['passed'],'historical_output':str(directory)}
  tree(directory,'cases/'+directory.name)
  # Supplement only: preserve remaining real files after a capturer failed. Never rewrite its receipt.
  saved=(receipt.get('case_result') or {}).get('evidence',{}).get('savedFiles',[]);recovery=[]
  for name in saved:
   path=Path(name);assert path.resolve().is_relative_to((Path(receipt['deployment'])/'profile').resolve())
   recovery.append({'name':path.name,'exists_after_wait':path.is_file(),'sha256':store(path.read_bytes()) if path.is_file() else None})
  cases[directory.name]['saved_after_wait']=recovery
 tree(ROOT/'build/creation-capturers','capturers');tree(ROOT/'build/creation-dependencies-v1','dependencies')
 files['dependencies/git.json']=store((ROOT/'build/creation-dependencies-git-final.json').read_bytes())
 for name in ['resource-provenance.md']:
  files[name]=store((BASE/name).read_bytes())
 for p in sorted((ROOT/'tests/functional_creation').iterdir()):
  if p.is_file() and p.name!='audit.py':files['harness/'+p.name]=store(p.read_bytes())
 for p in (ROOT/'build').glob('creation-*-red.log'):files['tdd/'+p.name]=store(p.read_bytes())
 snapshots={};canonicals={}
 with tempfile.TemporaryDirectory(prefix='creation exports ',dir=ROOT/'build') as temp:
  temp=Path(temp);cpp=ROOT/'build/creation-sources'/revisions[1]/'tools/pt-pt-audio/rcc_inventory.cpp';binary=temp/'inspect';flags=subprocess.check_output(['pkg-config','--cflags','--libs','Qt6Core'],text=True).split();subprocess.run(['g++','-std=c++17','-fPIC',str(cpp),'-o',str(binary),*flags],check=True)
  for name in ['creation-origin','creation-canonical','creation-focused','creation-final']:
   snapshot=ROOT/'build'/name;raw=(snapshot/'manifest.json').read_bytes();manifest=json.loads(raw);assert len(manifest['files'])==269;snapshots[sha(raw)]=store(raw);canonicals[name]={}
   for activity in [*ACTIVITIES,'core']:
    path=snapshot/'share/gcompris-qt/rcc'/(activity+'.rcc');destination=temp/(name+'-'+activity);rows=json.loads(subprocess.check_output([str(binary),str(path),str(destination)]));digest=store(path.read_bytes());assert manifest['files']['share/gcompris-qt/rcc/'+activity+'.rcc']==digest
    for row in rows:assert store((destination/row['path'].removeprefix(':/')).read_bytes())==row['sha256']
    canonicals[name][activity]={'rcc_sha256':digest,'files':rows}
   # Physical executable/local QML and translated catalogues, as well as every RCC,
   # are retained in the own snapshot; all 269 files are bound by manifest here.
  xvfb=ROOT/'build/xvfb-package/extracted/usr/bin/Xvfb';files['environment/Xvfb']=store(xvfb.read_bytes())
 for p in (ROOT/'build/xvfb-package').rglob('*'):
  if p.is_file() and (p.suffix=='.deb' or p.name=='copyright'):files['environment/'+p.relative_to(ROOT/'build/xvfb-package').as_posix()]=store(p.read_bytes())
 output.mkdir(parents=True);capture={'format':1,'phases':phases,'cases':cases,'files':files,'snapshots':snapshots,'canonical':canonicals,'objects':sorted(objects)}
 (output/'capture.json').write_text(json.dumps(capture,indent=2)+'\n')
 with zipfile.ZipFile(output/'objects.zip','x',zipfile.ZIP_DEFLATED) as bundle:
  for digest,raw in sorted(objects.items()):
   entry=zipfile.ZipInfo('objects/'+digest,(2026,1,1,0,0,0));entry.compress_type=zipfile.ZIP_DEFLATED;bundle.writestr(entry,raw)
 print(json.dumps({'capture_sha256':sha((output/'capture.json').read_bytes()),'objects':len(objects),'cases':len(cases),'zip_bytes':(output/'objects.zip').stat().st_size}))
if __name__=='__main__':
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True);args=parser.parse_args();seal(args.output.resolve())
