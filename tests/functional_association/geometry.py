#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Compare rendered outer silhouettes independently of authored board positions."""
from PIL import Image,ImageDraw,ImageChops
from pathlib import Path
from render import render


def mask(path,temp):
    if path.suffix=='.svg':render(path,temp);image=Image.open(temp).convert('RGBA')
    else:image=Image.open(path).convert('RGBA')
    alpha=image.getchannel('A').point(lambda v:255 if v>64 else 0)
    box=alpha.getbbox();assert box
    alpha=alpha.crop(box)
    # Fill internal holes; the outer contour is the invariant of these silhouettes.
    padded=Image.new('L',(alpha.width+2,alpha.height+2),0);padded.paste(alpha,(1,1));ImageDraw.floodfill(padded,(0,0),128)
    filled=padded.point(lambda v:0 if v==128 else 255).crop((1,1,alpha.width+1,alpha.height+1))
    return filled.resize((96,96),Image.Resampling.NEAREST)


def iou(a,b):
    intersection=sum(1 for x,y in zip(a.getdata(),b.getdata()) if x and y)
    union=sum(1 for x,y in zip(a.getdata(),b.getdata()) if x or y)
    return intersection/union
