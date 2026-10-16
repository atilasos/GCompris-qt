# SPDX-License-Identifier: GPL-3.0-or-later
import unittest,xml.etree.ElementTree as ET
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
RESOURCE=ROOT/'src/activities/fifteen/resource'
class LocalizedCoastalVector(unittest.TestCase):
 def test_only_three_words_change_and_geometry_number_and_license_survive(self):
  original=list(ET.parse(RESOURCE/'Coastal_Path.svg').iter());localized=list(ET.parse(RESOURCE/'Coastal_Path-pt.svg').iter());self.assertEqual(len(original),len(localized));changed=[]
  for before,after in zip(original,localized):
   self.assertEqual((before.tag,before.attrib,before.tail),(after.tag,after.attrib,after.tail))
   if before.text!=after.text:changed.append((before.attrib.get('id'),before.text,after.text))
  self.assertEqual(changed,[('tspan137','Miles','milhas'),('tspan138','Coast','Rota'),('tspan139','Path','Costeira')]);text=[node.text for node in localized if node.tag.endswith('tspan')];self.assertEqual(text,['125','milhas','Rota','Costeira']);self.assertFalse({'Coast','Path','Miles'}&set(text))
if __name__=='__main__':unittest.main()
