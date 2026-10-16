# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from audit import validate_mix, validate_name

class RecordedColorEvidence(unittest.TestCase):
    def test_recorded_steps_must_match_the_displayed_color(self):
        row = {'level': 3, 'displayedTarget': [1, 0, 0], 'steps': [3, 0, 0], 'result': [1, 0, 0]}
        validate_mix(row, True)
        row['steps'] = [2, 0, 0]
        with self.assertRaises(AssertionError):
            validate_mix(row, True)

    def test_color_name_cannot_be_matched_to_a_different_image(self):
        vocabulary = {'Descobrir a borboleta grená': 'garnet_butterfly.svg'}
        row = {'text': 'Descobrir a borboleta grená', 'source': 'qrc:/gcompris/src/activities/advanced_colors/resource/garnet_butterfly.svg'}
        validate_name(row, vocabulary)
        row['source'] = row['source'].replace('garnet', 'ruby')
        with self.assertRaises(AssertionError):
            validate_name(row, vocabulary)
