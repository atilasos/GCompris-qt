#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Read existing physical scenes only; never execute Qt or use authored models."""
import argparse,hashlib,json,sys
from pathlib import Path
from PIL import Image
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from pattern_scene_pixels import check_cells,snapshot_report


def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()


def probe(base,background=None):
    report={'scope':'Physical pixel checks only; not game completion or native exits',
            'sources':{name:sha(Path(__file__).with_name(name)) for name in ('pixels.py','probe.py','__init__.py')},
            'receipts':{},'images':{},'cells':{},'polygons':{},'missing_scenes':[]}
    bg=Image.open(background) if background else None
    report['background_sha256']=sha(background) if background else None
    for name in ('complete-redraw','complete-redraw_symmetrical'):
        folder=base/name;receipt=folder/'result.json';report['receipts'][name]=sha(receipt)
        totals={'opaque_checked':0,'alpha_checked':0,'alpha_unverified':0,'samples':0,'scenes':0}
        for board in json.loads(receipt.read_text())['case_result']['boards']:
            for phase,cells in [('question',board['question']+board['answerInitial']),
                                ('wrong',board['question']+board['wrong']['answer']),
                                ('success',board['question']+board['repaired']['answer'])]:
                image=folder/f"level-{board['level']}-{phase}.png"
                if not image.is_file():report['missing_scenes'].append(str(image.relative_to(base)));continue
                counts=check_cells(cells,Image.open(image),background=bg)
                for key,value in counts.items():totals[key]+=value
                totals['scenes']+=1;report['images'][str(image.relative_to(base))]=sha(image)
        report['cells'][name]=totals
    for name in ('polygons-tutorial-nine','polygons-pilot','polygons-controls2'):
        folder=base/name;receipt=folder/'result.json';report['receipts'][name]=sha(receipt);states={}
        def collect(value):
            if isinstance(value,dict):
                if all(k in value for k in ('label','grid','points')):
                    label=value['label']
                    if label in states and states[label]!=value:raise ValueError('Conflicting state labels')
                    states[label]=value
                for child in value.values():collect(child)
            elif isinstance(value,list):
                for child in value:collect(child)
        collect(json.loads(receipt.read_text())['case_result'])
        runs=[]
        for label,state in states.items():
            image=folder/(label+'.png')
            if not image.is_file():report['missing_scenes'].append(str(image.relative_to(base)));continue
            result=snapshot_report(state,Image.open(image));runs.append({'label':label,**result})
            report['images'][str(image.relative_to(base))]=sha(image)
        report['polygons'][name]=runs
    return report


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--proof-root',required=True,type=Path)
    parser.add_argument('--background',type=Path)
    args=parser.parse_args()
    print(json.dumps(probe(args.proof_root,args.background),indent=2))
