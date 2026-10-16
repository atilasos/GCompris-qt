# SPDX-License-Identifier: GPL-3.0-or-later
"""Inventory fixed visible assets from the frozen activity declarations."""
import re
from pathlib import Path

def strings(text,name):
 match=re.search(r'\b'+re.escape(name)+r'\s*(?:=|:)\s*\[(.*?)\]',text,re.S)
 if not match:raise ValueError('Missing fixed list '+name)
 return re.findall(r'[\'"]([^\'"\n]+)[\'"]',match[1])

def inventory(source):
 source=Path(source);simple=(source/'src/activities/simplepaint/simplepaint.js').read_text();sketch=(source/'src/activities/sketch/sketch.js').read_text();stamps=(source/'src/activities/sketch/StampTool.qml').read_text();backgrounds=strings(simple,'backgrounds');sketch_backgrounds=strings(sketch,'backgroundImageSet');stamp_images=strings(stamps,'stamps');assets=set(backgrounds+sketch_backgrounds+stamp_images)
 for activity in ['simplepaint','sketch','drawing_wheels']:
  for path in (source/'src/activities'/activity).rglob('*'):
   if path.suffix.lower() in ['.svg','.png','.jpg','.webp']:assets.add('qrc:/gcompris/'+path.relative_to(source).as_posix())
 providers=sorted({re.search(r'/activities/([^/]+)/',name)[1] if '/activities/' in name else 'core' for name in assets})
 return {'simple_backgrounds':backgrounds,'simple_palette':strings(simple,'colorsSimple'),'advanced_palette':strings(simple,'colorsAdvanced'),'sketch_backgrounds':sketch_backgrounds,'stamps':stamp_images,'assets':sorted(assets),'providers':providers}
