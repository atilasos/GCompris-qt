#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Export retained effective RCCs using the actual QtCore inspector, once per run."""
import argparse,hashlib,json,shutil,subprocess
from pathlib import Path

def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--base',type=Path,required=True);p.add_argument('--sources',type=Path,required=True);p.add_argument('--selection',type=Path,required=True);p.add_argument('--inspector',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
 if a.output.exists() or a.output.is_symlink():p.error('Output must be new')
 selection=json.loads(a.selection.read_text());plans=[]
 for name,revision in selection.items():
  result=json.loads((a.base/name/'result.json').read_text());deployment=Path(result['deployment']);resource={'redraw':'redraw','redraw_symmetrical':'redraw','mosaic':'mosaic','polygons':'polygons'}[result['activity']];rcc=deployment/'share/gcompris-qt/rcc'/f'{resource}.rcc';qm=deployment/'share/gcompris-qt/translations/gcompris_qt_pt.qm';source=a.sources/revision
  if not source.is_dir() or sha(rcc)!=result['private_rcc_sha256'] or sha(qm)!=result['private_qm_sha256']:raise ValueError('Physical effective bytes/source mismatch: '+name)
  plans.append((name,source,rcc,qm))
 a.output.mkdir(parents=True);records={}
 for name,source,rcc,qm in plans:
  target=a.output/name;target.mkdir();shutil.copyfile(rcc,target/'resource.rcc');shutil.copyfile(qm,target/'gcompris_qt_pt.qm');command=[str(a.inspector.absolute()),str((target/'resource.rcc').absolute()),str((target/'files').absolute())];process=subprocess.run(command,capture_output=True,text=True);(target/'inspector.stdout').write_text(process.stdout);(target/'inspector.stderr').write_text(process.stderr)
  records[name]={'source_root':str(source.absolute()),'rcc':str((target/'resource.rcc').absolute()),'qm':str((target/'gcompris_qt_pt.qm').absolute()),'rcc_sha256':sha(rcc),'qm_sha256':sha(qm),'files_root':str((target/'files').absolute()),'argv':command,'exit_code':process.returncode,'inspector_sha256':sha(a.inspector),'files':json.loads(process.stdout) if process.returncode==0 else None}
  (a.output/'index.json').write_text(json.dumps({'runs':records},indent=2)+'\n')
  if process.returncode:raise RuntimeError('QtCore extraction failed: '+name)
 print(json.dumps({'runs':len(records),'exit_code':0}))
if __name__=='__main__':main()
