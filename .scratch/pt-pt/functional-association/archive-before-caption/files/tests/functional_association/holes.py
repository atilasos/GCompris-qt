#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Locate visible blank/coloured regions in original image pixels, not board data."""
from collections import deque
from PIL import Image


def components(image,predicate,minimum=200):
    width,height=image.size;pixels=list(image.getdata());remaining={i for i,color in enumerate(pixels) if predicate(color)};regions=[]
    while remaining:
        start=remaining.pop();todo=[start];points=[]
        while todo:
            point=todo.pop();points.append(point);x,y=point%width,point//width
            for other in ([point-1] if x else [])+([point+1] if x+1<width else [])+([point-width] if y else [])+([point+width] if y+1<height else []):
                if other in remaining:remaining.remove(other);todo.append(other)
        if len(points)>=minimum:
            xs=[p%width for p in points];ys=[p//width for p in points];box=(min(xs),min(ys),max(xs)+1,max(ys)+1)
            mask=Image.new('L',(box[2]-box[0],box[3]-box[1]),0);local=mask.load()
            for p in points:local[p%width-box[0],p//width-box[1]]=255
            regions.append({'box':box,'mask':mask,'area':len(points)})
    return regions


def white_holes(image):return components(image.convert('RGBA'),lambda p:min(p[:3])>=245 and p[3]>200,500)


def coloured_holes(image):
    colors=sorted(image.convert('RGB').getcolors(image.width*image.height),reverse=True);palette=[]
    for count,color in colors:
        if count<500:break
        if max(color)-min(color)<50:continue
        if all(max(abs(a-b) for a,b in zip(color,prior))>30 for prior in palette):palette.append(color)
        if len(palette)==6:break
    assert len(palette)>=4
    result=[]
    for color in palette:
        regions=components(image.convert('RGBA'),lambda p:max(abs(a-b) for a,b in zip(p[:3],color))<15,500)
        for region in regions:
            region['color']=color;result.append(region)
    assert len(result)==6
    return result


def continuity(piece,image,box):
    piece=piece.convert('RGB');image=image.convert('RGB');samples=[];left,top,right,bottom=box
    for x in range(3,piece.width-3,5):
        xx=left+round(x*(right-left-1)/(piece.width-1))
        for py,yy in [(0,top-2),(piece.height-1,bottom+1)]:
            if 0<=yy<image.height:samples.append(sum((a-b)**2 for a,b in zip(piece.getpixel((x,py)),image.getpixel((xx,yy)))))
    for y in range(3,piece.height-3,5):
        yy=top+round(y*(bottom-top-1)/(piece.height-1))
        for px,xx in [(0,left-2),(piece.width-1,right+1)]:
            if 0<=xx<image.width:samples.append(sum((a-b)**2 for a,b in zip(piece.getpixel((px,y)),image.getpixel((xx,yy)))))
    return sum(samples)/len(samples)
