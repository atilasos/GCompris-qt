#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Validate complete native drawing receipts and the original resource bytes."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
ROOT=Path(__file__).resolve().parents[2]
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--evidence',type=Path,required=True);p.add_argument('--snapshot',type=Path);p.add_argument('--rcc-inventory',type=Path);a=p.parse_args();base=a.evidence.resolve()
summary=json.loads((base/'complete/summary.json').read_text());assert summary['passed'] and summary['full_original_levels'] and len(summary['cases'])==10 and all(r['exit_code']==0 for r in summary['cases'])
data=json.loads(subprocess.check_output(['node',str(ROOT/'tests/functional_drawing/data.mjs'),'--strict-strokes'],text=True))
voices={r['path']:r for r in json.loads((base/'voices-inventory.json').read_text())}
report={'native_cases':{},'resources_sha256':{},'decoded_voice_routes':[],'level_routes':0,'points':0,'rejected_inputs':0,'stroke_pauses':0,'wins':0}
heard=set();cases={}
for activity in ['number_sequence','clickanddraw','drawletters','drawnumbers']:
 for mode in [1,2]:
  for highlight in ([True,False] if activity=='number_sequence' else [True]):
   name=activity+'-mode'+str(mode)+'-highlight'+str(highlight).lower();folder=base/'complete'/name;path=folder/'result.json';d=json.loads(path.read_text());c=d['case_result']
   assert d['passed'] and d['exit_code']==0 and not d['timeout'] and not d['qml_errors'] and c['failures']==0 and not c['audioErrors'],name
   assert sha(base/'complete'/(name+'.qml'))==d['case_sha256']
   process=json.loads((base/'complete'/(name+'.process.json')).read_text());assert process['exit_code']==0 and process['finished_utc']
   assert d['source_sha256']==sha(ROOT/'src/activities/number_sequence/NumberSequence.qml')
   count={'number_sequence':9,'clickanddraw':9,'drawletters':26,'drawnumbers':10}[activity]
   assert c['mode']==mode and c['highlight']==highlight and c['wins']==count and c['wrong']==2*count
   assert [r['level'] for r in c['completed']]==list(range(1,count+1))
   assert [r['points'] for r in c['completed']]==[len(level['coordinates']) for level in data[activity]]
   assert [r['final'] for r in c['completed']]==[level['imageName2'] for level in data[activity]]
   assert c['pauses']==sum(sum(level['breaks'][1:-1]) for level in data[activity])
   report['native_cases'][name]={'result_sha256':sha(path),'case_sha256':d['case_sha256'],'levels':count,'points':sum(r['points'] for r in c['completed']),'click_sound_status':c['clickSoundStatus']}
   report['level_routes']+=count;report['points']+=sum(r['points'] for r in c['completed']);report['rejected_inputs']+=c['wrong'];report['stroke_pauses']+=c['pauses'];report['wins']+=c['wins']
   playing={(e['serial'],e['route']) for e in c['playing']};requested={(e['serial'],e['route']) for e in c['requested']}
   for event in c['progressed']:
    key=event['serial'],event['route'];assert key in requested and event['position']>0 and event['duration']>0
    if event['playbackState']==1:assert key in playing;heard.add(event['route'])
   for route,name in {**c['images'],**c['copiedRoutes']}.items():
    digest=sha(folder/name)
    if route.startswith('qrc:/gcompris/src/'):assert digest==sha(ROOT/route.removeprefix('qrc:/gcompris/'))
    else:assert digest==voices[route.removeprefix('qrc')]['sha256']
    report['resources_sha256'][route]=digest
for activity in ['number_sequence','clickanddraw','drawletters','drawnumbers']:
 for suffix in ['home','escape']:
  name=activity+'-'+suffix;path=base/'controls'/name/'result.json';d=json.loads(path.read_text());assert d['passed'] and d['exit_code']==0 and not d['qml_errors'] and d['case_result']['failures']==0
  assert sha(base/'controls'/(name+'.qml'))==d['case_sha256'];report['native_cases'][name]={'result_sha256':sha(path),'case_sha256':d['case_sha256']}
expected={f'qrc:/gcompris/data/voices-ogg/pt/alphabet/U{code:04X}.ogg' for code in [*range(97,123),*range(48,58)]}
assert expected<=heard,(expected-heard)
assert report['level_routes']==126 and report['points']==3408 and report['wins']==126 and report['rejected_inputs']==252 and len(report['native_cases'])==18
wav=ROOT/'src/core/resource/sounds/audioclick.wav'
subprocess.run(['gst-launch-1.0','-q','filesrc','location='+str(wav),'!','decodebin','!','fakesink','sync=false'],check=True,capture_output=True)
report['decoded_voice_routes']=sorted(heard);report['alphabet_routes_playing']=len(expected);report['click_wav_sha256']=sha(wav)
if a.snapshot:
 assert a.rcc_inventory
 identities={}
 for activity in ['core','number_sequence','clickanddraw','drawletters','drawnumbers']:
  rcc=a.snapshot/'share/gcompris-qt/rcc'/(activity+'.rcc')
  rows=json.loads(subprocess.check_output([str(a.rcc_inventory.resolve()),str(rcc.resolve())],text=True))
  for row in rows:assert row['sha256']==sha(ROOT/row['path'].removeprefix(':/gcompris/')),row['path']
  identities[activity]={'rcc_sha256':sha(rcc),'source_files':len(rows),'files_sha256':{r['path']:r['sha256'] for r in rows}}
 report['source_identity']=identities
report['scope']='Native MediaPlayer playback observed; SoundEffect output, physical audition/devices, Windows and teacher review pending.'
(base/'audit.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({key:report[key] for key in ['level_routes','points','rejected_inputs','stroke_pauses','wins','alphabet_routes_playing']}))
