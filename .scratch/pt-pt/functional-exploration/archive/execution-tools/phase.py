# SPDX-License-Identifier: GPL-3.0-or-later
"""Publish immutable task-84 input trees atomically before native workers."""
import hashlib,json,os,shutil,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
ACTIVITIES=['explore_farm_animals','explore_world_animals','explore_world_music','explore_monuments']
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def freeze(name):
 target=ROOT/'build/functional-exploration/sources'/name
 if target.exists():verify(target);return target
 target.parent.mkdir(parents=True,exist_ok=True)
 with tempfile.TemporaryDirectory(prefix='.'+name+'-',dir=target.parent) as temporary:
  staged=Path(temporary)/'source';staged.mkdir()
  for item in ['CMakeLists.txt','poqm/pt/gcompris_qt.po','tools/run-native-qml-case.py','tools/run-native-qml-supervised.py','tools/native_qml_resources.py','tools/native_qml_supervision.py',*[f'src/activities/{n}' for n in ACTIVITIES]]:
   src=ROOT/item;dst=staged/item;dst.parent.mkdir(parents=True,exist_ok=True)
   if src.is_dir():shutil.copytree(src,dst)
   else:shutil.copyfile(src,dst)
  files={str(p.relative_to(staged)):sha(p) for p in staged.rglob('*') if p.is_file()}
  (staged/'source-manifest.json').write_text(json.dumps(files,indent=2)+'\n')
  staged.rename(target)
 verify(target);return target
def verify(target):
 files=json.loads((target/'source-manifest.json').read_text())
 if not files or any(not (target/n).is_file() or (target/n).is_symlink() or sha(target/n)!=h for n,h in files.items()):raise ValueError('Frozen source bytes differ')
 return files
