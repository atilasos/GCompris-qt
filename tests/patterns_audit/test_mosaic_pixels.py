# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from PIL import Image, ImageDraw
from mosaic_pixels import classify_crop

class ActualScenePictures(unittest.TestCase):
    def setUp(self):
        self.models = {}
        for name,color in [('red',(200,0,0,255)),('green',(0,200,0,255))]:
            picture=Image.new('RGBA',(160,160))
            ImageDraw.Draw(picture).rectangle((4,4,155,155), fill=color)
            self.models[name]=picture
        self.frame={'x':30,'y':30,'width':40,'height':40}
        self.scene=Image.new('RGB',(60,60),(200,0,0))
    def test_pixels_choose_without_expected_uri(self):
        self.assertEqual(classify_crop(self.scene,self.frame,self.models)['id'],'red')
    def test_altered_scene_changes_the_answer(self):
        self.assertEqual(classify_crop(Image.new('RGB',(60,60),(0,200,0)),self.frame,self.models)['id'],'green')
    def test_alias_images_are_refused(self):
        self.models['alias']=self.models['red'].copy()
        with self.assertRaisesRegex(ValueError,'unique'):
            classify_crop(self.scene,self.frame,self.models)
    def test_unrelated_pixels_are_refused(self):
        with self.assertRaisesRegex(ValueError,'render discrepancy'):
            classify_crop(Image.new('RGB',(60,60),'blue'),self.frame,self.models)
    def test_outside_frame_is_refused(self):
        self.frame['x']=0
        with self.assertRaisesRegex(ValueError,'outside'):
            classify_crop(self.scene,self.frame,self.models)

if __name__=='__main__': unittest.main()
