import struct,zlib,unittest
from pixels import png,pixel,changed,bounds

def fixture(rows):
 def chunk(tag,data):return struct.pack('>I',len(data))+tag+data+struct.pack('>I',zlib.crc32(tag+data)&0xffffffff)
 return b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',2,2,8,2,0,0,0))+chunk(b'IDAT',zlib.compress(rows))+chunk(b'IEND',b'')
class DrawnPixels(unittest.TestCase):
 def test_literal_coloured_pixels_and_crop_difference(self):
  image=png(fixture(b'\x00\xff\x00\x00\x00\xff\x00\x00\x00\x00\xff\xff\xff\xff'));self.assertEqual(pixel(image,0,0),(255,0,0));self.assertEqual(pixel(image,1,0),(0,255,0));self.assertEqual(pixel(image,0,1),(0,0,255));self.assertEqual(changed(image,image,(0,0,2,2)),0)
 def test_changed_region_bounds_are_measured_from_pixels(self):
  a=png(fixture(b'\x00'+bytes(6)+b'\x00'+bytes(6)));b=png(fixture(b'\x00'+bytes(6)+b'\x00'+b'\xff\x00\x00'+bytes(3)));self.assertEqual(bounds(a,b,(0,0,2,2)),(1,(0,1,1,2)))
 def test_sub_filter_and_crc_corruption(self):
  raw=fixture(b'\x01\x10\x20\x30\x01\x02\x03\x00\x00\x00\x00\x00\x00\x00');self.assertEqual(pixel(png(raw),1,0),(17,34,51))
  with self.assertRaises(ValueError):png(raw[:-1]+b'x')
if __name__=='__main__':unittest.main()
