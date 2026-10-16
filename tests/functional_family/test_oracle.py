# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from oracle import graph,relation
class VisibleKinship(unittest.TestCase):
 def test_married_parents_and_child_from_drawn_segments(self):
  people=[{'x':2.5,'y':1.5,'sex':'M'},{'x':4.5,'y':1.5,'sex':'F'},{'x':3.5,'y':3.5,'sex':'M'}];edges=[(2.5,1.5,4.5,1.5),(3.5,1.5,3.5,3.5)];rings=[(3.5,1.5)];g=graph(people,edges,rings);self.assertEqual(g['parents'],[[],[],[0,1]]);self.assertEqual(relation(g,2,0),'Pai');self.assertEqual(relation(g,2,1),'Mãe');self.assertEqual(relation(g,0,2),'Filho')
 def test_single_parent_siblings_cousins_and_nephew_are_distinct(self):
  people=[{'x':3.5,'y':0.5,'sex':'M'},{'x':2.5,'y':2.5,'sex':'M'},{'x':4.5,'y':2.5,'sex':'M'},{'x':2.5,'y':4.5,'sex':'F'},{'x':4.5,'y':4.5,'sex':'M'}];segments=[(3.5,.5,3.5,1.5),(2.5,1.5,4.5,1.5),(2.5,1.5,2.5,4.5),(4.5,1.5,4.5,4.5)];g=graph(people,segments,[]);self.assertEqual(relation(g,3,4),'Primo');self.assertEqual(relation(g,3,2),'Tio');self.assertEqual(relation(g,2,3),'Sobrinha');self.assertEqual(relation(g,1,2),'Irmão')
 def test_ring_defines_affinity_and_not_parenthood_for_spouse(self):
  people=[{'x':4.5,'y':.5,'sex':'M'},{'x':6.5,'y':.5,'sex':'F'},{'x':4.5,'y':2.5,'sex':'M'},{'x':2.5,'y':2.5,'sex':'F'},{'x':6.5,'y':2.5,'sex':'M'}];edges=[(4.5,.5,6.5,.5),(5.5,.5,5.5,1.5),(4.5,1.5,6.5,1.5),(4.5,1.5,4.5,2.5),(6.5,1.5,6.5,2.5),(2.5,2.5,4.5,2.5)];g=graph(people,edges,[(5.5,.5),(3.5,2.5)]);self.assertEqual(g['parents'][3],[]);self.assertEqual(relation(g,3,0),'Sogro');self.assertEqual(relation(g,0,3),'Nora');self.assertEqual(relation(g,3,4),'Cunhado');self.assertEqual(relation(g,4,3),'Cunhada')
 def test_unknown_avatar_category_has_no_gender_certainty(self):
  g={'people':[{'sex':'M'},{'sex':None}],'parents':[[1],[]],'spouses':[[],[]]};self.assertIsNone(relation(g,0,1))
if __name__=='__main__':unittest.main()
