# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from static_data import dataset,fixed_fingerprint,drawn_fingerprint
class FiniteInventory(unittest.TestCase):
 def test_comment_example_is_not_an_offered_fixed_board(self):
  text='/* data: [{random:false,data:[1,2,3]}] */\n property var symbols:[{imgName:"1.svg",text:"1"}]\n data: [{"symbols":symbols,"random":true,"length":20,"size":3,"operators":["+"]}]';self.assertEqual(dataset(text)[0]['length'],20);self.assertTrue(dataset(text)[0]['random'])
 def test_initial_clue_fingerprint_uses_public_symbols_without_solving(self):
  symbols=[{'text':'A','imgName':'circle.svg'}];self.assertEqual(fixed_fingerprint([['A','.'],['.','A']],symbols),('circle.svg','','','circle.svg'))
if __name__=='__main__':unittest.main()
