# SPDX-License-Identifier: GPL-3.0-or-later
"""Published curriculum, used for coverage, never to choose a native answer."""
import json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
def inventory(source=ROOT):
 rows=[]
 for dataset in range(1,4):
  text=(source/f'src/activities/share/resource/{dataset}/Data.qml').read_text()
  text=text[text.index('data:'):];text=text[text.index('['):text.rindex(']')+1]
  text=re.sub(r'qsTr\(("(?:[^"\\]|\\.)*")\)',r'\1',text)
  text=re.sub(r',(\s*[}\]])',r'\1',text)
  levels=json.loads(text)
  for level,data in enumerate(levels,1):rows.append({'dataset':dataset,'within_dataset':level,'level':len(rows)+1,**data})
 return rows
if __name__=='__main__':print(json.dumps(inventory(),indent=2))
