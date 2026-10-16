# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from PIL import Image
from pixels import locate_detail

class DetailFromPixels(unittest.TestCase):
    def test_unique_cut_out_is_located_without_board_coordinates(self):
        background = Image.new('RGB', (20, 20), 'white')
        patch = Image.new('RGB', (3, 3))
        patch.putdata([(255, 0, 0), (0, 255, 0), (0, 0, 255),
                       (255, 255, 0), (128, 0, 128), (0, 255, 255),
                       (10, 20, 30), (80, 90, 100), (200, 150, 100)])
        background.paste(patch, (4, 6))
        result = locate_detail(patch, background)
        self.assertEqual(result['top_left'], [4, 6])
        self.assertEqual(result['pixel_box'], [4, 6, 7, 9])

    def test_repeated_detail_is_not_treated_as_a_unique_answer(self):
        background = Image.new('RGB', (20, 20), 'white')
        patch = Image.new('RGB', (3, 3), 'red')
        patch.putpixel((1, 1), (0, 0, 255))
        background.paste(patch, (2, 2))
        background.paste(patch, (12, 12))
        with self.assertRaises(ValueError):
            locate_detail(patch, background)

if __name__ == '__main__':
    unittest.main()
