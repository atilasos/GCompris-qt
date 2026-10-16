# SPDX-License-Identifier: GPL-3.0-or-later
"""Convert recorded public widget centers and a neutral scale probe to pixels."""
import math
from solver import solve

def solve_observed(images_by_source, board, calibration, **options):
 """The probe measures size only; its destination never supplies an answer."""
 if board['level']!=calibration['level']:raise ValueError('Calibration belongs to another visible board')
 frame=board['frame']
 for key in ['x','y','width','height']:
  if not math.isfinite(frame[key]) or abs(frame[key]-calibration['frame'][key])>1e-6:raise ValueError('Visible frames differ or are nonfinite')
 if frame['width']<=0 or frame['height']<=0:raise ValueError('Empty visible frame')
 expected={piece['source'] for page in board['pages'] for piece in page}
 if set(images_by_source)!=expected:raise ValueError('Image set differs from all publicly exposed pieces')
 placed=calibration['placed'];image=images_by_source[placed['source']]
 scale=placed['width']/image.width;vertical=placed['height']/image.height
 if not math.isfinite(scale) or scale<=0 or abs(scale-vertical)>scale*1e-6:raise ValueError('Scale probe has inconsistent width/height')
 canvas=[round(frame['width']/scale),round(frame['height']/scale)]
 left=frame['x']-frame['width']/2;top=frame['y']-frame['height']/2
 slots=[((circle['x']-left)/scale,(circle['y']-top)/scale) for circle in board['drawnCircles']]
 result=solve(images_by_source,slots,canvas,**options)
 result['geometry']={'scale':scale,'canvas_size':canvas,'visible_slots_in_canvas_pixels':slots,'position_semantics':'recorded widget centers; neutral probe destination unused'}
 return result
