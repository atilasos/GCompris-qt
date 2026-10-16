# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from PIL import Image
from solver import solve, AmbiguousPuzzle, NoSolution, SearchLimit

class PixelPlacement(unittest.TestCase):
 def test_complementary_silhouettes_choose_the_only_nonoverlapping_placement(self):
  # A3x2 canvas, left has a tab into the upper right square.
  a=Image.new('RGBA',(2,2));a.putdata([(200,20,10,255),(200,20,10,255),(200,20,10,255),(0,0,0,0)])
  b=Image.new('RGBA',(2,2));b.putdata([(0,0,0,0),(10,20,200,255),(10,20,200,255),(10,20,200,255)])
  result=solve({'arbitrary-z':b,'arbitrary-a':a},[(1,1),(2,1)],(3,2),flat_border_constraints=True)
  self.assertEqual(result['mapping'],{'arbitrary-a':0,'arbitrary-z':1})
  self.assertEqual(result['diagnostics']['status'],'unique')
 def test_rgb_continuity_resolves_repeated_rectangles_without_id_order(self):
  left=Image.new('RGBA',(2,2));left.putdata([(0,0,0,255),(10,10,10,255)]*2)
  right=Image.new('RGBA',(2,2));right.putdata([(11,11,11,255),(21,21,21,255)]*2)
  result=solve({'first':right,'last':left},[(1,1),(3,1)],(4,2))
  self.assertEqual(result['mapping'],{'last':0,'first':1})
 def test_calibration_uses_only_public_painted_geometry(self):
  from observation import solve_observed
  left=Image.new('RGBA',(2,2));left.putdata([(0,0,0,255),(10,10,10,255)]*2)
  right=Image.new('RGBA',(2,2));right.putdata([(11,11,11,255),(21,21,21,255)]*2)
  frame={'x':100,'y':60,'width':8,'height':4}
  board={'level':7,'frame':frame,'pages':[[{'source':'opaque-left'},{'source':'opaque-right'}]],'drawnCircles':[{'x':98,'y':60},{'x':102,'y':60}]}
  calibration={'level':7,'frame':frame,'placed':{'source':'opaque-right','width':4,'height':4}}
  result=solve_observed({'opaque-right':right,'opaque-left':left},board,calibration)
  self.assertEqual(result['mapping'],{'opaque-left':0,'opaque-right':1})
  self.assertEqual(result['geometry']['canvas_size'],[4,2])
  self.assertEqual(result['geometry']['scale'],2)
 def test_identical_texture_and_masks_refuse_instead_of_sorting_ids(self):
  blank=Image.new('RGBA',(2,2),(40,40,40,255))
  with self.assertRaises(AmbiguousPuzzle):solve({'z':blank,'a':blank},[(1,1),(3,1)],(4,2))
 def test_search_limit_refuses_an_uncertified_best_candidate(self):
  images={str(n):Image.new('RGBA',(2,2),(n*30,n*30,n*30,255)) for n in range(3)}
  with self.assertRaises(SearchLimit):solve(images,[(1,1),(3,1),(5,1)],(6,2),max_nodes=4)
 def test_piece_outside_the_visible_canvas_refuses(self):
  with self.assertRaises(NoSolution):solve({'piece':Image.new('RGBA',(4,4),(10,20,30,255))},[(1,1)],(2,2))
 def test_height_must_confirm_the_scale_instead_of_using_a_response(self):
  from observation import solve_observed
  image=Image.new('RGBA',(2,2),(10,20,30,255));frame={'x':10,'y':10,'width':4,'height':4}
  board={'level':1,'frame':frame,'pages':[[{'source':'opaque'}]],'drawnCircles':[{'x':10,'y':10}]}
  cal={'level':1,'frame':frame,'placed':{'source':'opaque','width':4,'height':3}}
  with self.assertRaisesRegex(ValueError,'inconsistent width/height'):solve_observed({'opaque':image},board,cal)
if __name__=='__main__':unittest.main()
