# SPDX-License-Identifier: GPL-3.0-or-later
"""Read visible SVG artwork, never the falling item's matching key."""
import re
import xml.etree.ElementTree as ET


def dice_pips(path):
    # The light top-face pips are separate closed subpaths. The darker pips
    # on decorative side faces do not describe the face the child counts.
    return sum(len(re.findall(r'[Mm]', shape.get('d', '')))
               for shape in ET.parse(path).iter()
               if 'fill:#f2dbd4' in shape.get('style', ''))
