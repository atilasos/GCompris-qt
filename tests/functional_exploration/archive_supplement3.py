#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Seal the Colosseum follow-up observation without rewriting history."""
import hashlib,json,shutil,subprocess,uuid
from pathlib import Path
from archive import BASE,capsule
from phase import ROOT,sha

def main():
 final=BASE/'supplement3-archive'
 if final.exists():raise FileExistsError(final)
 out=BASE/('.supplement3-building-'+uuid.uuid4().hex);out.mkdir();(out/'blobs').mkdir()
 index={'sources':{},'runs':{},'principal_index_sha256':sha(BASE/'archive/sealed.json')}
 for phase in ['supplement2','supplement3']:
  source=ROOT/'build/functional-exploration/sources'/phase;manifest=json.loads((source/'source-manifest.json').read_text());files={p:(source/p).read_bytes() for p in manifest}
  if {p:hashlib.sha256(b).hexdigest() for p,b in files.items()}!=manifest:raise ValueError('Frozen source changed')
  capsule(files,out/'sources'/(phase+'.tar.xz'));index['sources'][phase]=manifest
 for name,phase,code in [('supplement3-red','supplement2',1),('supplement3-green','supplement3',0)]:
  original=BASE/name;target=out/'runs'/name;target.mkdir(parents=True)
  for p in original.iterdir():
   if p.is_file():shutil.copyfile(p,target/p.name)
  native=json.loads((original/'result.json').read_text());deploy=Path(native['deployment']);rcc=deploy/'share/gcompris-qt/rcc/explore_farm_animals.rcc';qm=deploy/'share/gcompris-qt/translations/gcompris_qt_pt.qm'
  record={'phase':phase,'expected_exit':code,'rcc':sha(rcc),'qm':sha(qm),'runtime_output':str(original.resolve()),'runtime_source':str(ROOT/'build/functional-exploration/sources'/phase)}
  for p in [rcc,qm]:
   dest=out/'blobs'/sha(p)
   if not dest.exists():shutil.copyfile(p,dest)
  export=ROOT/'build/functional-exploration/exports'/name
  result=subprocess.run(['/tmp/pt-audio-rcc-inventory',str(rcc),str(export)],capture_output=True,text=True);result.check_returncode();record['resources']=json.loads(result.stdout);record['export_exit']=result.returncode
  capsule({r['path'][2:]:(export/r['path'][2:]).read_bytes() for r in record['resources']},out/'effective'/(name+'.tar.xz'));index['runs'][name]=record
 shutil.copyfile(ROOT/'tests/functional_exploration/supplement3-review.json',out/'review.json')
 (out/'evidence.json').write_text(json.dumps(index,ensure_ascii=False,indent=2)+'\n')
 (out/'sealed.json').write_text(json.dumps({str(p.relative_to(out)):sha(p) for p in sorted(out.rglob('*')) if p.is_file()},indent=2)+'\n');out.rename(final);print(sha(final/'sealed.json'))
if __name__=='__main__':main()
