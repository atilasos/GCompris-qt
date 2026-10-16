import math,unittest
from curves import position,svg_paths,curve_error
class VisibleWheelGeometry(unittest.TestCase):
 def test_two_to_one_rolling_circle_with_equal_pen_offset_traces_line(self):
  route={'wheel':60,'gear':30,'initial':{'center':{'x':0,'y':0},'gear':{'x':0,'y':-1},'pen':{'x':0,'y':0}}}
  x,y=position(route,math.pi/2);self.assertAlmostEqual(x,2);self.assertAlmostEqual(y,0);self.assertLess(curve_error(route,[(0,0),(2,0),(0,0),(-2,0)]),.01)
 def test_pen_at_gear_center_follows_unit_circle_and_rejects_wrong_path(self):
  route={'wheel':60,'gear':30,'initial':{'center':{'x':0,'y':0},'gear':{'x':0,'y':-1},'pen':{'x':0,'y':-1}}}
  self.assertAlmostEqual(position(route,math.pi/2)[0],1);self.assertAlmostEqual(position(route,math.pi/2)[1],0);self.assertGreater(curve_error(route,[(4,4)]),4)
 def test_parse_physical_svg_vectors(self):
  paths=svg_paths(b'<svg xmlns="http://www.w3.org/2000/svg"><path d="M 0 1 L -2.5 4 Z" style="stroke:#000;stroke-width:2"/></svg>');self.assertEqual(paths[0]['points'],[(0.,1.),(-2.5,4.)]);self.assertEqual(paths[0]['style']['stroke-width'],'2')
if __name__=='__main__':unittest.main()
