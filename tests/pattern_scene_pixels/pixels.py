# SPDX-License-Identifier: GPL-3.0-or-later
import math
class PixelMismatch(ValueError):
    pass
class UnsupportedScene(ValueError):
    pass

def check_cells(cells, scene, *, background=None):
    """Check opaque cells; report alpha as unverified unless background is supplied."""
    if not cells:raise UnsupportedScene('At least one observed cell is required')
    image=scene.convert('RGB')
    if background is not None and background.size != image.size:
        raise UnsupportedScene('Background and scene sizes differ')
    base=background.convert('RGB') if background is not None else None
    result={'opaque_checked':0,'alpha_checked':0,'alpha_unverified':0,'samples':0}
    for cell in cells:
        frame=cell['frame'];color=cell['color']
        if frame.get('visible',True) is not True or frame.get('opacity',1)!=1:
            raise UnsupportedScene('Cell must be fully visible')
        if not isinstance(color,str) or not color.startswith('#') or len(color) not in (7,9):
            raise UnsupportedScene('Expected Qt #rrggbb or #aarrggbb')
        try:channels=tuple(bytes.fromhex(color[1:]))
        except ValueError as error:raise UnsupportedScene('Invalid Qt color') from error
        alpha=channels[0] if len(channels)==4 else 255
        rgb=channels[-3:]
        x,y,w,h=(frame[k] for k in ('x','y','width','height'))
        if not all(math.isfinite(v) for v in (x,y,w,h)) or min(w,h)<12:
            raise UnsupportedScene('Finite cell geometry of at least12 pixels required')
        if alpha!=255 and base is None:
            result['alpha_unverified']+=1
            continue
        for ox,oy in [(0,0),(-.035,0),(.035,0),(0,-.035),(0,.035)]:
            px=math.floor(x+w*(.22+ox)+.5);py=math.floor(y+h*(-.24+oy)+.5)
            if not (0<=px<image.width and 0<=py<image.height):
                raise UnsupportedScene('Cell sample lies outside the scene')
            expected=rgb if alpha==255 else tuple(round((alpha*c+(255-alpha)*b)/255)
                                                  for c,b in zip(rgb,base.getpixel((px,py))))
            actual=image.getpixel((px,py))
            if any(abs(a-b)>2 for a,b in zip(actual,expected)):
                raise PixelMismatch(f'Cell color mismatch at{px,py}: {actual} != {expected}')
            result['samples']+=1
        result['opaque_checked' if alpha==255 else 'alpha_checked']+=1
    return result

def _ink(rgb):
    # Colour of the visible stroke, calibrated from the preserved scenes.
    return all(abs(a-b)<=24 for a,b in zip(rgb,(16,114,29)))


def _distance(point,a,b):
    dx,dy=b[0]-a[0],b[1]-a[1]
    length2=dx*dx+dy*dy
    if not length2:raise UnsupportedScene('Repeated adjacent vertex')
    t=max(0,min(1,((point[0]-a[0])*dx+(point[1]-a[1])*dy)/length2))
    return math.hypot(point[0]-a[0]-t*dx,point[1]-a[1]-t*dy)


def check_snapshot(state,scene):
    """Return True only after checking recorded ordered segments in real pixels."""
    snapshot_report(state,scene)
    return True


def snapshot_report(state,scene):
    image=scene.convert('RGB');frame=state['grid']
    x,y,w,h=(frame[k] for k in ('x','y','width','height'))
    if not all(math.isfinite(v) for v in (x,y,w,h)) or min(w,h)<=0:
        raise UnsupportedScene('Finite positive grid frame required')
    left,top,right,bottom=x-w/2,y-h/2,x+w/2,y+h/2
    if left<0 or top<0 or right>image.width or bottom>image.height:
        raise UnsupportedScene('Grid falls outside the scene')
    points=[];disks=[]
    for vertex in state['points']:
        p=vertex['sceneCenter'];point=(p['x'],p['y'])
        radius=max(vertex['frame']['width'],vertex['frame']['height'])/2+3
        if not all(math.isfinite(v) for v in (*point,radius)) or radius<3:
            raise UnsupportedScene('Invalid observed point geometry')
        if not (left<=point[0]<=right and top<=point[1]<=bottom):
            raise UnsupportedScene('Observed point outside grid')
        points.append(point);disks.append((*point,radius))
    label=state.get('label','')
    if 'closed' in state:
        closed=state['closed'];basis='explicit'
        if not isinstance(closed,bool):raise UnsupportedScene('Explicit closed must be boolean')
    elif any('color' in p or 'opacity' in p for p in state['points']):
        styles=[(p.get('color'),p.get('opacity')) for p in state['points']]
        blue=lambda style: style[0]=='#20a8dd' and style[1]==.3
        if len(styles)>=3 and all(blue(style) for style in styles):closed=True
        elif styles[-1]==('#00000000',.5) and all(blue(style) for style in styles[:-1]):closed=False
        else:raise UnsupportedScene('Point styles do not establish open/closed traversal')
        basis='public-point-style'
    else:
        closed='closed' in label or 'repaired' in label;basis='label-fallback'
    if closed and len(points)<3:raise UnsupportedScene('Closed figure requires at least3 points')
    segments=list(zip(points,points[1:]))
    if closed:segments.append((points[-1],points[0]))
    def obscured(px,py):
        return any((px-cx)**2+(py-cy)**2<=radius**2 for cx,cy,radius in disks)
    samples=0
    for a,b in segments:
        length=math.dist(a,b)
        if length==0:raise UnsupportedScene('Zero-length segment')
        count=math.ceil(length/4);supported=0
        for i in range(1,count):
            t=i/count;px=a[0]+(b[0]-a[0])*t;py=a[1]+(b[1]-a[1])*t
            if obscured(px,py):continue
            cx,cy=math.floor(px+.5),math.floor(py+.5)
            if not any(0<=xx<image.width and 0<=yy<image.height and _ink(image.getpixel((xx,yy)))
                       for yy in range(cy-2,cy+3) for xx in range(cx-2,cx+3)):
                raise PixelMismatch(f'Missing painted segment near{px,py}')
            supported+=1
        if not supported:raise UnsupportedScene('No unobscured segment support available')
        samples+=supported
    # Grey grid and blue vertex disks cannot establish or hide a green segment.
    ink_pixels=0
    for py in range(math.ceil(top),math.floor(bottom)):
        for px in range(math.ceil(left),math.floor(right)):
            if not _ink(image.getpixel((px,py))) or obscured(px,py):continue
            ink_pixels+=1
            if not segments or min(_distance((px,py),a,b) for a,b in segments)>3:
                raise PixelMismatch(f'Unexpected painted segment at{px,py}')
    return {'segments':len(segments),'supported_samples':samples,'unobscured_ink_pixels':ink_pixels,
            'closed':closed,'point_count':len(points),'closure_basis':basis}
