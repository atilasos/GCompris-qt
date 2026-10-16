import ctypes as C
from pathlib import Path
from PIL import Image,ImageDraw
r=C.CDLL('librsvg-2.so.2');c=C.CDLL('libcairo.so.2')
r.rsvg_handle_new_from_file.argtypes=[C.c_char_p,C.c_void_p];r.rsvg_handle_new_from_file.restype=C.c_void_p
r.rsvg_handle_render_cairo.argtypes=[C.c_void_p,C.c_void_p]
c.cairo_image_surface_create.argtypes=[C.c_int,C.c_int,C.c_int];c.cairo_image_surface_create.restype=C.c_void_p
c.cairo_create.argtypes=[C.c_void_p];c.cairo_create.restype=C.c_void_p
c.cairo_surface_write_to_png.argtypes=[C.c_void_p,C.c_char_p]
sheet=Image.new('RGB',(1000,240),'white');d=ImageDraw.Draw(sheet)
for i in range(10):
 p=Path(f'src/activities/learn_digits/resource/hands-{i}.svg');out=Path('build')/f'hand-{i}.png'
 surf=c.cairo_image_surface_create(0,100,200);cr=c.cairo_create(surf);h=r.rsvg_handle_new_from_file(str(p).encode(),None);r.rsvg_handle_render_cairo(h,cr);c.cairo_surface_write_to_png(surf,str(out).encode())
 im=Image.open(out);sheet.paste(im,(i*100,0),im);d.text((i*100+40,220),str(i),fill='black')
sheet.save('build/hands-contact.png')
