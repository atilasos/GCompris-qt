# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from curriculum import text_target,COUNTS
class VisibleMeaning(unittest.TestCase):
 def test_farm_uses_taught_behaviour(self):
  lessons=[{'title':title} for title in ['Gato','Cão','Porco','Pato','Cavalo','Coruja','Galinha','Vaca','Ovelha']]
  for prompt,title in [('Este animal consegue ronronar.','Gato'),('Este animal produz lã.','Ovelha'),('Descende dos lobos.','Cão'),('Possui uma crista.','Galinha')]:self.assertEqual(text_target(prompt,lessons)['title'],title)
 def test_map_names_allow_a_country_suffix_but_no_guesses(self):
  self.assertEqual(text_target('Taj Mahal',[{'title':'Taj Mahal, Índia'}])['title'],'Taj Mahal, Índia')
  with self.assertRaises(ValueError):text_target('Um animal',[{'title':'Gato'},{'title':'Cão'}])
 def test_inventory_distinguishes_maps_and_presentations(self):
  self.assertEqual(sum(map(len,COUNTS.values())),14);self.assertEqual(sum(sum(x) for x in COUNTS.values()),98)
if __name__=='__main__':unittest.main()
