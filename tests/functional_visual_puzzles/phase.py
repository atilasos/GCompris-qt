# SPDX-License-Identifier: GPL-3.0-or-later
"""Materialize exact historical inputs without touching the principal build."""
import errno,hashlib,json,subprocess,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
PREFIXES=['CMakeLists.txt','poqm/pt/gcompris_qt.po','tools/run-native-qml-case.py','tools/run-native-qml-supervised.py','tools/native_qml_resources.py','tools/native_qml_supervision.py','tools/pt-pt-audio/rcc_inventory.cpp','src/core','src/activities/babymatch','src/activities/details','src/activities/paintings','src/activities/photo_hunter','tests/functional_visual_puzzles','tests/painting_pixel_solver']
def freeze(revision):
 revision=subprocess.check_output(['git','rev-parse',revision+'^{commit}'],cwd=ROOT,text=True).strip()
 output=ROOT/'build/functional-visual-puzzles/sources'/revision
 paths=subprocess.check_output(['git','ls-tree','-r','--name-only',revision,'--',*PREFIXES],cwd=ROOT,text=True).splitlines()
 contents={path:subprocess.check_output(['git','show',revision+':'+path],cwd=ROOT) for path in paths}
 manifest={'revision':revision,'files':{path:hashlib.sha256(data).hexdigest() for path,data in contents.items()}}
 def verify():
  if json.loads((output/'source-manifest.json').read_text())!=manifest:
   raise ValueError('Frozen source manifest differs from Git')
  if any((output/path).read_bytes()!=data for path,data in contents.items()):
   raise ValueError('Frozen source bytes differ from Git')
 if output.exists():
  verify()
  return output
 output.parent.mkdir(parents=True,exist_ok=True)
 # Only complete trees become visible. Independent callers may race to publish;
 # the losing caller verifies the winner rather than modifying published bytes.
 with tempfile.TemporaryDirectory(prefix='.'+revision+'-',dir=output.parent) as temporary:
  staged=Path(temporary)/'source'
  staged.mkdir()
  for path,data in contents.items():
   target=staged/path;target.parent.mkdir(parents=True,exist_ok=True)
   target.write_bytes(data)
  (staged/'source-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
  try:staged.rename(output)
  except OSError as error:
   if error.errno not in (errno.EEXIST,errno.ENOTEMPTY):raise
  verify()
 return output
