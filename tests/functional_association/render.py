#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Render original SVGs for visual review and silhouette geometry comparison."""
import ctypes as C
from pathlib import Path
from PIL import Image,ImageDraw

class Dimensions(C.Structure):
    _fields_=[('width',C.c_int),('height',C.c_int),('em',C.c_double),('ex',C.c_double)]


def render(source,target,size=160):
    r=C.CDLL('librsvg-2.so.2');c=C.CDLL('libcairo.so.2');g=C.CDLL('libgobject-2.0.so.0')
    r.rsvg_handle_new_from_file.argtypes=[C.c_char_p,C.c_void_p];r.rsvg_handle_new_from_file.restype=C.c_void_p
    r.rsvg_handle_get_dimensions.argtypes=[C.c_void_p,C.POINTER(Dimensions)]
    r.rsvg_handle_render_cairo.argtypes=[C.c_void_p,C.c_void_p]
    c.cairo_image_surface_create.argtypes=[C.c_int,C.c_int,C.c_int];c.cairo_image_surface_create.restype=C.c_void_p
    c.cairo_create.argtypes=[C.c_void_p];c.cairo_create.restype=C.c_void_p
    c.cairo_translate.argtypes=[C.c_void_p,C.c_double,C.c_double];c.cairo_scale.argtypes=[C.c_void_p,C.c_double,C.c_double]
    c.cairo_surface_write_to_png.argtypes=[C.c_void_p,C.c_char_p]
    c.cairo_destroy.argtypes=[C.c_void_p];c.cairo_surface_destroy.argtypes=[C.c_void_p];g.g_object_unref.argtypes=[C.c_void_p]
    h=r.rsvg_handle_new_from_file(str(source).encode(),None);assert h
    dims=Dimensions();r.rsvg_handle_get_dimensions(h,C.byref(dims));assert dims.width>0 and dims.height>0
    surface=c.cairo_image_surface_create(0,size,size);cr=c.cairo_create(surface)
    scale=min((size-8)/dims.width,(size-8)/dims.height);c.cairo_translate(cr,(size-dims.width*scale)/2,(size-dims.height*scale)/2);c.cairo_scale(cr,scale,scale)
    assert r.rsvg_handle_render_cairo(h,cr);assert c.cairo_surface_write_to_png(surface,str(target).encode())==0
    c.cairo_destroy(cr);c.cairo_surface_destroy(surface);g.g_object_unref(h)


def sheet(paths,output):
    columns=6;w=180;h=195
    image=Image.new('RGB',(columns*w,((len(paths)+columns-1)//columns)*h),'white');draw=ImageDraw.Draw(image)
    output.parent.mkdir(parents=True,exist_ok=True)
    for i,path in enumerate(paths):
        target=output.parent/(str(i)+'.png');render(path,target);tile=Image.open(target);x=i%columns*w;y=i//columns*h;image.paste(tile,(x,y),tile);draw.text((x,y+162),path.name,fill='black')
    image.save(output)
