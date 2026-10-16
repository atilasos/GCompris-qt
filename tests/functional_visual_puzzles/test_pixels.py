# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from PIL import Image
from pixels import locate_detail, difference_points

class DetailFromPixels(unittest.TestCase):
    def test_two_visible_changes_produce_two_pixel_candidates(self):
        left = Image.new('RGB', (20, 20), 'white')
        right = left.copy()
        left.paste('red', (2, 3, 5, 6))
        left.paste('blue', (13, 14, 16, 17))
        result = difference_points(left, right)
        self.assertEqual(len(result), 2)
        self.assertEqual([row['box'] for row in result], [[2, 3, 5, 6], [13, 14, 16, 17]])

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
