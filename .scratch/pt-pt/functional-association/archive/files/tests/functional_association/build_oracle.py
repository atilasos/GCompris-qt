#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Build visual matches solely from inspected images and rendered silhouettes."""
import hashlib
import json
from pathlib import Path
from PIL import Image
from inventory import collect,ROOT
from geometry import mask,iou
from holes import white_holes,coloured_holes,continuity


def build(root=ROOT,temporary=None):
    assert temporary is not None
    semantics=json.loads((root/'tests/functional_association/semantics.json').read_text())
    output={'semantic':semantics,'silhouettes':{},'holes':{}}
    base=root/'src/activities/babyshapes/resource';temporary.mkdir(parents=True,exist_ok=True)
    for board in collect(root):
        if board['activity']!='babyshapes' or board['level']>4:continue
        targets={part['pixmapfile']:mask(base/part['pixmapfile'],temporary/'render.png') for part in board['parts'] if part.get('type')=='SHAPE_BACKGROUND'}
        for part in board['parts']:
            if part.get('type') is not None:continue
            name=part['pixmapfile'];source=mask(base/name,temporary/'render.png')
            scores=sorted(((iou(source,target),path) for path,target in targets.items()),reverse=True)
            assert scores[0][0]>.85 and scores[0][0]-scores[1][0]>.05
            result={'target':scores[0][1],'iou':scores[0][0],'runnerUp':scores[1][0]}
            if name in output['silhouettes']:assert output['silhouettes'][name]['target']==result['target']
            output['silhouettes'][name]=result
    for board in collect(root):
        if board['activity']!='babyshapes' or board['level']<6:continue
        background=next(p['pixmapfile'] for p in board['parts'] if p.get('type')=='SHAPE_BACKGROUND_IMAGE')
        image=Image.open(base/background).convert('RGBA');regions=coloured_holes(image) if board['level']==6 else white_holes(image)
        pieces=[p['pixmapfile'] for p in board['parts'] if p.get('type') is None];assert len(regions)==len(pieces)
        chosen=[]
        for name in pieces:
            piece=Image.open(base/name).convert('RGBA');source=mask(base/name,temporary/'render.png');box=piece.getchannel('A').point(lambda v:255 if v>64 else 0).getbbox()
            width,height=box[2]-box[0],box[3]-box[1];scores=[]
            for region in regions:
                overlap=iou(source,region['mask'].resize((96,96),Image.Resampling.NEAREST));b=region['box'];error=abs(width-(b[2]-b[0]))+abs(height-(b[3]-b[1]))
                edge=continuity(piece,image,b) if board['level']==6 and piece.getextrema()[-1][0]==255 else 0
                scores.append((overlap-error/(100 if board['level']==6 else 1000)-edge/1000000,overlap,error,edge,b))
            scores.sort(reverse=True);score,overlap,error,edge,b=scores[0]
            assert score>0.6 and score-scores[1][0]>.01,(name,scores[:2])
            chosen.append(b)
            output['holes'][name]={'background':background,'center':[(b[0]+b[2])/2/image.width,(b[1]+b[3])/2/image.height],
                                   'pixelBox':b,'iou':overlap,'edgeContinuityCost':edge,'score':score,'runnerUp':scores[1][0]}
        assert len(chosen)==len(set(chosen)),background
    return output


if __name__=='__main__':
    import argparse
    parser=argparse.ArgumentParser();parser.add_argument('--output',type=Path,required=True);parser.add_argument('--temporary',type=Path,required=True);args=parser.parse_args()
    args.output.write_text(json.dumps(build(temporary=args.temporary),ensure_ascii=False,indent=2)+'\n')
