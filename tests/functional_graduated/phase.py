# SPDX-License-Identifier: GPL-3.0-or-later
"""Materialize exact historical inputs without touching the principal build."""
import hashlib,json,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
PREFIXES=['CMakeLists.txt','poqm/pt/gcompris_qt.po','tools/run-native-qml-case.py','tools/run-native-qml-supervised.py','tools/native_qml_resources.py','tools/native_qml_supervision.py','src/activities/graduated_line_read','src/activities/graduated_line_use','src/activities/chess/resource/background-wood.svg',*[f'src/core/resource/sounds/{name}.wav' for name in ['completetask','crash','audioclick','smudge']]]
def freeze(revision):
 revision=subprocess.check_output(['git','rev-parse',revision+'^{commit}'],cwd=ROOT,text=True).strip()
 output=ROOT/'build/functional-graduated/sources'/revision
 paths=subprocess.check_output(['git','ls-tree','-r','--name-only',revision,'--',*PREFIXES],cwd=ROOT,text=True).splitlines()
 output.mkdir(parents=True,exist_ok=True)
 for path in paths:
  target=output/path;target.parent.mkdir(parents=True,exist_ok=True)
  if not target.exists():target.write_bytes(subprocess.check_output(['git','show',revision+':'+path],cwd=ROOT))
 manifest={'revision':revision,'files':{p:hashlib.sha256((output/p).read_bytes()).hexdigest() for p in paths}}
 assert all(hashlib.sha256(subprocess.check_output(['git','show',revision+':'+p],cwd=ROOT)).hexdigest()==digest for p,digest in manifest['files'].items())
 (output/'source-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
 return output
