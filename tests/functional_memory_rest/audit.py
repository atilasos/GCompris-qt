#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Check native memory receipts against fixed board sizes and original resource bytes."""
import argparse
import hashlib
import json
import subprocess
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
SIZES={'memory':[3,4,5,6,9,10], 'memory-tux':[3,4,5,6,9,10],
       'memory-sound':[3,4,5,6,15,10,12], 'memory-sound-tux':[3,4,5,6,15,10,12],
       'memory-case-association-tux':[3,4,5,6]}
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def validate_gameplay(activity,data):
    sizes=SIZES[activity];tux=activity.endswith('-tux');modes=[1] if tux else [1,2]
    assert data['failures']==0 and not data['audioErrors']
    won=[r for r in data['completed'] if r['won']]
    lost=[r for r in data['completed'] if not r['won']]
    assert sorted((r['players'],r['level']) for r in data['completed'])==[(p,i+1) for p in modes for i in range(len(sizes))]
    for row in data['completed']:
        assert row['players'] in modes and 1<=row['level']<=len(sizes)
        assert row['pairs']==sizes[row['level']-1]
        assert row['score1']+row['score2']==row['pairs']
        assert row['won']==(not tux or row['score1']>row['score2'])
    assert data['forcedDefeats']==int(tux)
    assert data['losses']==len(lost)
    assert data['winSignals']==len(data['completed'])
    assert data['lossSignals']==len(lost)+int(tux)
    capacity=sum(sizes)*len(modes)+sum(r['pairs'] for r in lost)+int(tux)*sizes[0]
    assert data['correctPairs']+data['tuxPairs']==capacity
    assert data['wrongPairs']>0 and data['blockedClicks']>=data['wrongPairs']
    assert (data['tuxTurns']>0)==tux
    return {'routes':len(data['completed']),'natural_losses':len(lost),'forced_defeats':int(tux),'resolved_pairs':capacity}

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--gameplay',type=Path,required=True)
    parser.add_argument('--voices-inventory',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--resource-snapshot',type=Path)
    parser.add_argument('--rcc-inventory',type=Path)
    args=parser.parse_args()
    args.gameplay=args.gameplay.resolve()
    inventory={r['path']:r for r in json.loads(args.voices_inventory.read_text())}
    for code in range(ord('a'),ord('z')+1):
        path=f':/gcompris/data/voices-ogg/pt/alphabet/U{code:04X}.ogg'
        assert inventory[path]['ogg'] and inventory[path]['bytes']>0
    report={'activities':{},'files':{},'actual_resources':{},'sound_routes_playing':[], 'alphabet_routes_playing':[]}
    sounds=set();alphabet=set()
    for activity in SIZES:
        folder=args.gameplay/activity/'gameplay';result=folder/'result.json'
        data=json.loads(result.read_text());assert data['passed'] and data['exit_code']==0 and not data['qml_errors']
        case=args.gameplay/activity/'gameplay-input.qml';assert sha(case)==data['case_sha256']
        report['files'][str(result.relative_to(ROOT))]=sha(result)
        report['files'][str(case.relative_to(ROOT))]=sha(case)
        native=data['case_result'];report['activities'][activity]=validate_gameplay(activity,native)
        requested={(e['serial'],e['route']) for e in native['requested']}
        playing={(e['serial'],e['route']) for e in native['playing']}
        for event in native['progressed']:
            key=event['serial'],event['route']
            assert key in requested and event['position']>0 and event['duration']>0
            if event['playbackState']==1:
                assert key in playing
                if '/memory-sound/resource/' in event['route']:sounds.add(event['route'])
                if '/pt/alphabet/' in event['route']:alphabet.add(event['route'])
        if activity in ['memory-sound','memory-sound-tux','memory-case-association-tux']:
            assert native['playing'] and native['progressed']
        for route,name in {**native['copiedRoutes'],**native['visualRoutes']}.items():
            actual=folder/name;digest=sha(actual)
            if route.startswith('qrc:/gcompris/src/'):
                original=ROOT/route.removeprefix('qrc:/gcompris/');assert sha(original)==digest
            else:
                original=inventory[route.removeprefix('qrc')];assert original['sha256']==digest
            report['actual_resources'][route]=digest
    report['sound_routes_playing']=sorted(sounds);report['alphabet_routes_playing']=sorted(alphabet)
    if args.resource_snapshot:
        assert args.rcc_inventory
        identities={}
        for activity in [*SIZES,'memory-case-association','core']:
            rcc=args.resource_snapshot/'share/gcompris-qt/rcc'/(activity+'.rcc')
            rows=json.loads(subprocess.check_output([str(args.rcc_inventory.resolve()),str(rcc.resolve())],text=True))
            for row in rows:
                original=ROOT/row['path'].removeprefix(':/gcompris/')
                assert sha(original)==row['sha256'],str(original)
            identities[activity]={'rcc_sha256':sha(rcc),'registered_source_files':len(rows),'files':{r['path']:r['sha256'] for r in rows}}
        report['source_identity']=identities
    report['scope']='Original Qt playback and decoded position without a physical audio device; no teacher audition or Windows certification.'
    args.output.write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({'activities':len(report['activities']),'routes':sum(v['routes'] for v in report['activities'].values()),'actual_resources':len(report['actual_resources']),'decoded_sound_routes':len(sounds),'decoded_alphabet_routes':len(alphabet)}))

if __name__=='__main__':main()
