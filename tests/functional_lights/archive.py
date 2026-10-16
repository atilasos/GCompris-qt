#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Preserve both actual production phases as physical, deterministic ZIP data."""
import hashlib,io,json,subprocess,zipfile
from pathlib import Path
from phase import ROOT,PREFIXES
PHASES={'baseline':'d83e5ab7e','final':'4e2f434cf'}
JS='src/activities/lightsoff/lightsoff.js'
def blob(revision,path):return subprocess.check_output(['git','show',revision+':'+path],cwd=ROOT)
def create(destination):
 files=subprocess.check_output(['git','ls-tree','-r','--name-only',PHASES['final'],'--',*PREFIXES],cwd=ROOT,text=True).splitlines()
 contents={'final/'+name:blob(PHASES['final'],name) for name in files}
 contents['baseline/'+JS]=blob(PHASES['baseline'],JS)
 for name in files:
  if name!=JS:assert blob(PHASES['baseline'],name)==contents['final/'+name],name
 output=io.BytesIO()
 with zipfile.ZipFile(output,'w',compression=zipfile.ZIP_DEFLATED) as archive:
  for name,data in sorted(contents.items()):
   info=zipfile.ZipInfo(name,(1980,1,1,0,0,0));info.compress_type=zipfile.ZIP_DEFLATED;info.external_attr=0o100644<<16;archive.writestr(info,data)
 manifest={'format':1,'phases':PHASES,'files':{name:hashlib.sha256(data).hexdigest() for name,data in sorted(contents.items())},'zip_sha256':hashlib.sha256(output.getvalue()).hexdigest()}
 with (destination/'source-tree.zip').open('xb') as stream:stream.write(output.getvalue())
 with (destination/'source-manifest.json').open('x') as stream:stream.write(json.dumps(manifest,indent=2)+'\n')
 print(len(contents),manifest['zip_sha256'])
if __name__=='__main__':create(ROOT/'.scratch/pt-pt/functional-lights')
