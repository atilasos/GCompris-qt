# SPDX-License-Identifier: GPL-3.0-or-later
from pathlib import Path
import sys
import unittest
from PIL import Image, ImageDraw
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from pattern_scene_pixels import check_cells, check_snapshot, snapshot_report, PixelMismatch, UnsupportedScene

class CellPixels(unittest.TestCase):
    def test_opaque_color_comes_from_scene_not_metadata(self):
        cells=[{'frame':{'x':50,'y':50,'width':60,'height':60},'color':'#cc0000'}]
        scene=Image.new('RGB',(100,100),'white')
        with self.assertRaises(PixelMismatch):check_cells(cells,scene)
        ImageDraw.Draw(scene).rectangle((20,20,79,79),fill='#cc0000')
        self.assertEqual(check_cells(cells,scene),{'opaque_checked':1,'alpha_checked':0,'alpha_unverified':0,'samples':5})


    def test_argb_alpha_is_unverified_without_an_independent_background(self):
        cells=[{'frame':{'x':50,'y':50,'width':60,'height':60},'color':'#33ffffff'}]
        background=Image.new('RGB',(100,100),(100,150,200))
        scene=Image.new('RGB',(100,100),(131,171,211))
        self.assertEqual(check_cells(cells,scene)['alpha_unverified'],1)
        checked=check_cells(cells,scene,background=background)
        self.assertEqual((checked['alpha_checked'],checked['alpha_unverified']), (1,0))
        with self.assertRaises(PixelMismatch):
            check_cells(cells,Image.new('RGB',(100,100),'white'),background=background)
        with self.assertRaises(PixelMismatch):
            check_cells(cells,scene,background=Image.new('RGB',(100,100),'white'))

    def test_color_or_geometry_tampering_is_not_ignored(self):
        scene=Image.new('RGB',(100,100),'#cc0000')
        cell={'frame':{'x':50,'y':50,'width':60,'height':60},'color':'#cc0000'}
        with self.assertRaises(PixelMismatch):check_cells([dict(cell,color='#0000cc')],scene)
        for frame in [dict(cell['frame'],x=999),dict(cell['frame'],opacity=.5),dict(cell['frame'],width=0)]:
            with self.subTest(frame=frame),self.assertRaises(UnsupportedScene):
                check_cells([dict(cell,frame=frame)],scene)
        with self.assertRaises(UnsupportedScene):check_cells([dict(cell,color='white')],scene)
        with self.assertRaises(UnsupportedScene):check_cells([],scene)


class PolygonPixels(unittest.TestCase):
    def fixture(self, closed=True):
        points=[(40,40),(160,40),(160,160),(40,160)]
        state={'label':'literal-closed' if closed else 'literal-point-3',
               'grid':{'x':100,'y':100,'width':180,'height':180},
               'points':[{'sceneCenter':{'x':x,'y':y},'frame':{'width':12,'height':12}} for x,y in points]}
        image=Image.new('RGB',(200,200),'white');draw=ImageDraw.Draw(image)
        for n in range(20,181,20):
            draw.line((n,10,n,190),fill='#d9d9d9');draw.line((10,n,190,n),fill='#d9d9d9')
        draw.line(points+([points[0]] if closed else []),fill=(16,114,29),width=3)
        for x,y in points:draw.ellipse((x-6,y-6,x+6,y+6),fill=(189,229,245))
        return state,image

    def test_pixels_prove_the_ordered_segments_not_grid_or_point_metadata(self):
        state,image=self.fixture()
        self.assertTrue(check_snapshot(state,image))
        self.assertEqual(snapshot_report(state,image)['segments'],4)
        with self.assertRaises(PixelMismatch):check_snapshot(state,Image.new('RGB',image.size,'white'))
        missing=image.copy();ImageDraw.Draw(missing).rectangle((75,35,125,45),fill='white')
        with self.assertRaises(PixelMismatch):check_snapshot(state,missing)
        # Metadata alone cannot turn a square scene into a different polygon.
        changed=dict(state,points=[dict(p) for p in state['points']])
        changed['points'][1]=dict(changed['points'][1],sceneCenter={'x':140,'y':70})
        with self.assertRaises(PixelMismatch):check_snapshot(changed,image)


    def test_grid_and_blue_disks_cannot_replace_green_segments(self):
        state,image=self.fixture()
        fake=Image.new('RGB',image.size,'white');draw=ImageDraw.Draw(fake)
        for n in range(20,181,20):
            draw.line((n,10,n,190),fill='#d9d9d9');draw.line((10,n,190,n),fill='#d9d9d9')
        for p in state['points']:
            x,y=p['sceneCenter']['x'],p['sceneCenter']['y']
            draw.ellipse((x-6,y-6,x+6,y+6),fill=(189,229,245))
        with self.assertRaises(PixelMismatch):check_snapshot(state,fake)

    def test_extra_line_is_rejected_and_cyclic_order_is_preserved(self):
        state,image=self.fixture()
        rotated=dict(state,points=state['points'][2:]+state['points'][:2])
        self.assertTrue(check_snapshot(rotated,image))
        reversed_state=dict(state,points=list(reversed(state['points'])))
        self.assertTrue(check_snapshot(reversed_state,image))
        extra=image.copy();ImageDraw.Draw(extra).line((40,40,160,160),fill=(16,114,29),width=3)
        with self.assertRaises(PixelMismatch):check_snapshot(state,extra)
        # Coherently claim an open contour while the pixels retain a closing edge.
        with self.assertRaises(PixelMismatch):check_snapshot(dict(state,closed=False),image)

    def test_public_point_style_closes_an_edited_figure_without_a_closed_label(self):
        state,image=self.fixture()
        state=dict(state,label='keyboard-moved',points=[dict(p,color='#20a8dd',opacity=.3) for p in state['points']])
        self.assertTrue(check_snapshot(state,image))
        self.assertEqual(snapshot_report(state,image)['closure_basis'],'public-point-style')
        open_state,open_image=self.fixture(closed=False)
        open_state=dict(open_state,points=[dict(p,color='#20a8dd',opacity=.3) for p in open_state['points']])
        open_state['points'][-1]=dict(open_state['points'][-1],color='#00000000',opacity=.5)
        self.assertFalse(snapshot_report(open_state,open_image)['closed'])

    def test_first_open_point_has_no_invented_segment(self):
        state,image=self.fixture(closed=False)
        state=dict(state,label='first-point-0',points=state['points'][:1])
        blank=Image.new('RGB',image.size,'white')
        result=snapshot_report(state,blank)
        self.assertEqual((result['segments'],result['supported_samples']), (0,0))
        with self.assertRaises(UnsupportedScene):check_snapshot(dict(state,closed=True),blank)

if __name__=='__main__':unittest.main()
