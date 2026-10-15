#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Audit complete fish/duck data and actual Qt receipt bytes, independently of scoring."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
from PIL import Image
ROOT=Path(__file__).resolve().parents[2]
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
p=argparse.ArgumentParser();p.add_argument('--evidence',type=Path,required=True);a=p.parse_args();evidence=a.evidence.resolve()
source=ROOT/'src/activities/clickgame/clickgame.js'
js="""const vm=require('node:vm'),fs=require('node:fs');let c=vm.createContext({Qt:{createComponent:()=>({})}});vm.runInContext(fs.readFileSync(process.argv[1],'utf8').replace(/^\\.(?:pragma|import).*$/gm,''),c);console.log(vm.runInContext('JSON.stringify({fishes,levelProperty})',c));"""
data=json.loads(subprocess.check_output(['node','-e',js,str(source)],text=True))
assert [l['nbFish'] for l in data['levelProperty']]==[5,7,10,12,15,18]
assert [l['minDuration'] for l in data['levelProperty']]==[2000,1500,1000,800,600,400]
assert len(data['fishes'])==27 and len({f['imgName'] for f in data['fishes']})==27
assets={}
for fish in data['fishes']:
 path=ROOT/'src/activities/clickgame/resource'/fish['imgName']
 with Image.open(path) as image:
  image.load();assert image.size==(fish['width']*fish['nbFrame'],fish['height']),path
 assets[str(path.relative_to(ROOT))]=sha(path)
for i in range(1,7):
 path=ROOT/f'src/activities/clickgame/resource/sea{i}.webp'
 with Image.open(path) as image:image.load();assert image.width>0 and image.height>0
 assets[str(path.relative_to(ROOT))]=sha(path)
for source in ['bleep','smudge','flip','completetask','scroll']:
 path=ROOT/f'src/core/resource/sounds/{source}.wav';assets[str(path.relative_to(ROOT))]=sha(path)
for name in ['bubble','drip']:
 path=ROOT/f'src/activities/clickgame/resource/{name}.wav';assets[str(path.relative_to(ROOT))]=sha(path)
for path in assets:
 if path.endswith('.wav'):subprocess.run(['gst-launch-1.0','-q','filesrc','location='+str(ROOT/path),'!','decodebin','!','fakesink','sync=false'],check=True,capture_output=True)
receipts={};resources={}
for path in sorted(evidence.glob('*/result.json')):
 d=json.loads(path.read_text());receipts[path.parent.name]={'passed':d['passed'],'sha256':sha(path),'case_sha256':d['case_sha256']}
 for route,name in d.get('case_result',{}).get('resources',{}).items():
  original=ROOT/route.removeprefix('qrc:/gcompris/');assert sha(path.parent/name)==sha(original);resources[route]=sha(original)
fish=json.loads((evidence/'fish-gameplay/result.json').read_text())['case_result']
assert [r['caught'] for r in fish['completed']]==[5,7,10,12,15,18] and fish['wins']==6 and fish['wrongClicks']==6
report={'complete_data':data,'assets_sha256':assets,'native_receipts':receipts,'observed_resources_sha256':resources,'fish_caught':67,'audio_decode':'Seven original WAV files decoded to fakesink; physical output not verified.'}
(evidence/'audit.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'sprites':27,'backgrounds':6,'decoded_wav':7,'native_observed_resources':len(resources),'fish_caught':67}))
