# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from oracle import relation,meaning
class SpatialRelations(unittest.TestCase):
 def test_independent_geometry_and_painted_layers(self):
  for dx,dy,z,lid,wanted in [(-.8,0,15,True,'left'),(.8,0,0,True,'right'),(0,-.9,15,True,'above'),(0,.9,0,True,'under'),(0,-.2,5,False,'inside'),(-.1,-.4,0,True,'behind'),(.1,.2,15,True,'front')]:
   with self.subTest(wanted=wanted):self.assertEqual(relation({'dx':dx,'dy':dy,'boy_z':z,'front_z':10,'lid':lid}),wanted)
 def test_portuguese_instructions_and_labels(self):
  self.assertEqual(meaning('Seleciona a imagem onde a criança está à frente da caixa.'),'front')
  self.assertEqual(meaning('ao lado'),'beside');self.assertEqual(meaning('esquerda'),'left')
  with self.assertRaises(ValueError):meaning('unknown')
if __name__=='__main__':unittest.main()
