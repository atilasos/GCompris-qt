# SPDX-License-Identifier: GPL-3.0-or-later
"""Published levels and modes, never passed as answers to the native solver."""
import json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
def inventory(source=ROOT):
 text=(source/'src/activities/leftright/leftright.js').read_text();hands=re.search(r'var levels = (\[.*?\n\])',text,re.S)[1];hands=json.loads(re.sub(r',(\s*[}\]])',r'\1',hands))
 positions=[]
 for dataset in [1,2]:
  text=(source/f'src/activities/positions/resource/{dataset}/Data.qml').read_text();relations=re.findall(r'"position":\s*qsTr\("([^"]+)"\)',text)
  positions.extend([{'dataset':dataset,'mode':mode,'relations':relations} for mode in ['text-to-picture','picture-to-text']])
 text=(source/'src/activities/left_right_click/left_right_click.js').read_text();animals=json.loads(re.search(r'var levelDifficulty = (\[[^\]]+\])',text)[1])
 return {'leftright':hands,'positions':positions,'left_right_click':animals}
if __name__=='__main__':print(json.dumps(inventory(),indent=2))
