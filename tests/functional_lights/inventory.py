#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Read authored board inputs without retaining author-provided solutions."""
import json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
def data(text):
 body=re.search(r'data:\s*(\[.*\])',text,re.S).group(1)
 body=re.sub(r'//[^\n]*','',body)
 body=re.sub(r',\s*([}\]])',r'\1',body)
 return [{key:row[key] for key in ['size','level','dynamic'] if key in row} for row in json.loads(body)]
def inventory(root=ROOT):
 return [{'dataset':str(index),'boards':data((root/f'src/activities/lightsoff/resource/{index}/Data.qml').read_text())} for index in range(1,10)]
if __name__=='__main__':print(json.dumps(inventory(),indent=2))
