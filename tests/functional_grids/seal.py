#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Archive only finished grids evidence, including every physical override."""
import argparse,hashlib,json,subprocess,tempfile,zipfile
from pathlib import Path
from phase import verify_source,ACTIVITIES
if not __debug__:raise SystemExit('Grids validation requires assertions; Python -O rejected')
ROOT=Path(__file__).resolve().parents[2];BASE=ROOT/'.scratch/pt-pt/functional-grids'
PHASES={'baseline':('1061af56417228aa27d123dd4aaa69eb7b5e256a','grids-canonical'),'final':('d740510aa8a87611d28e4776e64c8345fc4b2a64','grids-help-fixed')}
DIAGNOSTIC=['sudoku-inventory','calcudoku-inventory']
INVENTORY=['sudoku-inventory-v2','calcudoku-inventory-v2']
TRACERS=['sudoku-tracer','calcudoku-tracer']
GAMES=['sudoku-dataset-'+str(i) for i in range(1,5)]+['calcudoku-dataset-'+str(i) for i in range(1,6)]
FINAL=['sudoku-help-green','sudoku-controls','calcudoku-controls']
CASES={name:('final' if name in FINAL else 'baseline',int(name in DIAGNOSTIC or name=='sudoku-help-red')) for name in [*DIAGNOSTIC,*INVENTORY,*TRACERS,*GAMES,'sudoku-help-red',*FINAL]}
def sha(raw):return hashlib.sha256(raw).hexdigest()
def read(path):return json.loads(path.read_text())
def seal(output):
 if output.exists():raise ValueError('Use a new capsule output directory')
 output.mkdir(parents=True);objects={};files={};phases={};cases={}
 def store(raw):
  digest=sha(raw);assert digest not in objects or objects[digest]==raw;objects[digest]=raw;return digest
 for name,(phase,expected) in CASES.items():
  path=BASE/name;receipt=read(path/'result.json');status=read(path/'launcher-status.json');outer=read(path/'supervisor-exit.json');tool=read(path/'tool-exit.json');assert receipt['exit_code']==0 and status['exit_code']==outer['exit_code']==tool['exit_code']==expected and receipt['passed']==(expected==0) and receipt['deployment_retained']
  assert tool['native_receipt_sha256']==outer['native_receipt_sha256']==status['native_receipt_sha256']==sha((path/'result.json').read_bytes())
  cases[name]={'phase':phase,'expected_outer':expected,'historical_output':path.as_posix()}
  for artifact in sorted(path.rglob('*')):
   if artifact.is_file():assert not artifact.is_symlink();files['cases/'+name+'/'+artifact.relative_to(path).as_posix()]=store(artifact.read_bytes())
 with tempfile.TemporaryDirectory(prefix='grids physical capture ',dir=ROOT/'build') as temporary:
  work=Path(temporary);cpp=ROOT/'build/grids-sources'/PHASES['baseline'][0]/'tools/pt-pt-audio/rcc_inventory.cpp';inspector=work/'inspector';flags=subprocess.check_output(['pkg-config','--cflags','--libs','Qt6Core'],text=True).split();subprocess.run(['g++','-std=c++17','-fPIC',str(cpp),'-o',str(inspector),*flags],check=True)
  for phase,(revision,snapshot_name) in PHASES.items():
   source=ROOT/'build/grids-sources'/revision;manifest=verify_source(source);snapshot=ROOT/'build'/snapshot_name;entry={'revision':revision,'historical_source_root':source.as_posix(),'source':manifest,'snapshot_manifest':store((snapshot/'manifest.json').read_bytes()),'canonical':{},'audio':[]};phases[phase]=entry
   for name,digest in manifest['files'].items():assert store((source/name).read_bytes())==digest
   for activity in [*ACTIVITIES,'core']:
    path=snapshot/'share/gcompris-qt/rcc'/(activity+'.rcc');destination=work/(phase+'-'+activity);rows=json.loads(subprocess.check_output([str(inspector),str(path),str(destination)]));prefix='src/core/' if activity=='core' else 'src/activities/'+activity+'/';expected={':/gcompris/'+name for name in manifest['files'] if name.startswith(prefix)};assert {row['path'] for row in rows}==expected
    for row in rows:raw=(destination/row['path'].removeprefix(':/')).read_bytes();assert len(raw)==row['bytes'] and store(raw)==row['sha256']==manifest['files'][row['path'].removeprefix(':/gcompris/')]
    entry['canonical'][activity]={'rcc_sha256':store(path.read_bytes()),'files':rows}
   for name in ['bleep','darken','completetask','smudge','scroll','bonus']:
    relative='src/core/resource/sounds/'+name+'.wav';decoded=subprocess.run(['gst-launch-1.0','-q','filesrc','location='+str(source/relative),'!','wavparse','!','audioconvert','!','fakesink'],capture_output=True,text=True,timeout=20);assert decoded.returncode==0;entry['audio'].append({'path':relative,'sha256':manifest['files'][relative],'decode_exit_code':decoded.returncode})
 for name in ['README.md','oracle-red.log','oracle-green.log','audit-red.log','mathematical-sources.md','glyphs.png']:
  files[name]=store((BASE/name).read_bytes())
 for path in sorted((ROOT/'tests/functional_grids').iterdir()):
  if path.is_file() and path.name!='audit.py':files['harness/'+path.name]=store(path.read_bytes())
 origin=store((ROOT/'build/grids-origin/manifest.json').read_bytes());value={'format':1,'phases':phases,'cases':cases,'files':files,'origin_snapshot_manifest':origin,'objects':sorted(objects)}
 (output/'capture.json').write_text(json.dumps(value,indent=2)+'\n')
 with zipfile.ZipFile(output/'objects.zip','x',zipfile.ZIP_DEFLATED) as bundle:
  for digest,raw in sorted(objects.items()):
   entry=zipfile.ZipInfo('objects/'+digest,date_time=(2026,1,1,0,0,0));entry.compress_type=zipfile.ZIP_DEFLATED;bundle.writestr(entry,raw)
 print(json.dumps({'capture_sha256':sha((output/'capture.json').read_bytes()),'objects':len(objects),'zip_bytes':(output/'objects.zip').stat().st_size}))
if __name__=='__main__':
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True);args=parser.parse_args();seal(args.output.resolve())
