#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Seal diagnostic sources, actual RCC/QM, snapshot and external command observations."""
import hashlib,io,json,shutil,subprocess,tarfile
from pathlib import Path
from phase import ROOT,freeze
BASE=ROOT/'.scratch/pt-pt/penalty-shutdown'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 if (BASE/'index.json').exists():raise ValueError('Archive already sealed')
 observation=json.loads((BASE/'probes/observations.json').read_text());phases={row['name'].split('-')[0]:row['phase'] for row in observation['runs']};commands=[];effective={}
 for phase,revision in phases.items():
  source=freeze(revision);manifest=json.loads((source/'source-manifest.json').read_text());target=BASE/'sources'/phase;target.mkdir(parents=True);shutil.copyfile(source/'source-manifest.json',target/'source-manifest.json')
  with tarfile.open(target/'source.tar.xz','w:xz') as capsule:
   for name,digest in sorted(manifest['files'].items()):
    raw=(source/name).read_bytes()
    if hashlib.sha256(raw).hexdigest()!=digest:raise ValueError('Frozen source changed')
    entry=tarfile.TarInfo(name);entry.size=len(raw);entry.mode=0o644;entry.mtime=0;capsule.addfile(entry,io.BytesIO(raw))
 for row in observation['runs']:
  name=row['name'];output=BASE/'probes'/name;receipt=json.loads((output/'result.json').read_text());deployment=Path(receipt['deployment']);rcc=deployment/'share/gcompris-qt/rcc/penalty.rcc';export=ROOT/'build/penalty-shutdown/exported'/name
  command=['/tmp/pt-audio-rcc-inventory',str(rcc),str(export)];result=subprocess.run(command,capture_output=True,text=True);commands.append({'argv':command,'exit_code':result.returncode});result.check_returncode();files=json.loads(result.stdout);target=BASE/'effective'/name;target.mkdir(parents=True)
  if sha(rcc)!=receipt['private_rcc_sha256']:raise ValueError('Actual RCC differs')
  shutil.copyfile(rcc,target/'activity.rcc')
  for entry in files:
   path=entry['path'].removeprefix(':/gcompris/');dest=target/'files'/path;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(export/'gcompris'/path,dest)
  qm=deployment/'share/gcompris-qt/translations/gcompris_qt_pt.qm';shutil.copyfile(qm,target/'catalogue.qm')
  if sha(qm)!=receipt['private_qm_sha256']:raise ValueError('Actual QM differs')
  effective[name]={'files':files,'runtime_output':str(output.resolve()),'runtime_source':str(ROOT/'build/penalty-shutdown/sources'/row['phase'])}
 shutil.copyfile(ROOT/'build/penalty-shutdown/snapshot/manifest.json',BASE/'snapshot-manifest.json');(BASE/'effective-resources.json').write_text(json.dumps(effective,indent=2)+'\n');(BASE/'external-commands.json').write_text(json.dumps(commands,indent=2)+'\n')
 files={p.relative_to(BASE).as_posix():sha(p) for p in sorted(BASE.rglob('*')) if p.is_file() and '__pycache__' not in p.relative_to(BASE).parts and not any(part.startswith('.') for part in p.relative_to(BASE).parts)}
 (BASE/'index.json').write_text(json.dumps({'phases':phases,'files':files,'scope':'Six finite idle diagnostics, not gameplay/stability acceptance;83remainsopen'},indent=2)+'\n')
if __name__=='__main__':main()
