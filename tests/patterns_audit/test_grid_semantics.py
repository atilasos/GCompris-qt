# SPDX-License-Identifier: GPL-3.0-or-later
import copy
import json
import unittest
from pathlib import Path
from grid_semantics import validate_board

class ActualGridObservation(unittest.TestCase):
    def setUp(self):
        self.board = json.loads(Path(__file__).with_name('grid-fixture.json').read_text())['board']
    def test_actual_native_board(self):
        self.assertEqual(validate_board(self.board, mirror=False), 3)
    def test_coherent_wrong_geometry_is_rejected(self):
        altered = copy.deepcopy(self.board)
        altered['plan']['placements'][0]['target_frame']['x'] += 126
        with self.assertRaises(ValueError):
            validate_board(altered, mirror=False)
    def test_fabricated_repair_is_rejected(self):
        altered = copy.deepcopy(self.board)
        altered['repair']['after']['signature'] = altered['wrong']['observed_signature']
        altered['repaired']['answer'][0]['signature'] = altered['wrong']['observed_signature']
        with self.assertRaises(ValueError):
            validate_board(altered, mirror=False)
    def test_wrong_feedback_cannot_claim_win(self):
        altered = copy.deepcopy(self.board)
        altered['wrong']['wins_after'] += 1
        with self.assertRaises(ValueError):
            validate_board(altered, mirror=False)
    def test_click_cannot_be_relocated(self):
        altered = copy.deepcopy(self.board)
        altered['actions'][0]['click']['x'] += 126
        with self.assertRaises(ValueError):
            validate_board(altered, mirror=False)

if __name__ == '__main__':
    unittest.main()
