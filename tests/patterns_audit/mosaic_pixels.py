# SPDX-License-Identifier: GPL-3.0-or-later
"""Classify actual scene crops against physical normalized RGBA pictures."""
from PIL import Image, ImageChops, ImageFilter, ImageStat
from store import require

def classify_crop(scene, frame, pictures):
    box=tuple(round(v) for v in (frame['x']-frame['width']/2,frame['y']-frame['height']/2,frame['x']+frame['width']/2,frame['y']+frame['height']/2))
    require(0<=box[0]<box[2]<=scene.width and 0<=box[1]<box[3]<=scene.height,'Image frame outside full scene')
    crop=scene.convert('RGB').crop(box)
    scores=[]
    for identity,picture in pictures.items():
        require(picture.size==(160,160),'Physical normalized picture dimensions')
        # The historical renderer adds four transparent pixels on each edge.
        candidate=picture.convert('RGBA').crop((4,4,156,156)).resize(crop.size,Image.Resampling.LANCZOS)
        mask=candidate.getchannel('A').point(lambda a:255 if a>=254 else 0).filter(ImageFilter.MinFilter(3))
        require(mask.getbbox() is not None,'Picture has an opaque interior')
        difference=ImageChops.difference(crop,candidate.convert('RGB'))
        scores.append((max(ImageStat.Stat(difference,mask).mean),identity))
    scores.sort()
    require(len(scores)>1,'At least two physical candidate pictures')
    require(scores[0][0]<=8,'Excessive Qt/librsvg render discrepancy in opaque interiors')
    require(scores[1][0]-scores[0][0]>=1,'Picture classification must be unique with at least one RGB level of margin')
    return {'id':scores[0][1],'maximum_channel_mean_absolute_error':scores[0][0],'next_candidate_margin':scores[1][0]-scores[0][0],'box':list(box)}
