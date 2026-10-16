# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from inventory import inventory
from solver import chain
class PublishedArithmetic(unittest.TestCase):
 def test_every_published_linear_puzzle_has_an_integer_chain_for_the_visible_rows(self):
  data=inventory();groups=[(str(dataset),next(row for row in data['guesscount'] if row['dataset']==dataset)['groups']) for dataset in range(1,5)]+[('admin',data['admin']['data'])]
  for mode,buckets in groups:
   for group in buckets:
    for operators,questions in group:
     for values,target in questions:
      with self.subTest(mode=mode,values=values,target=target):self.assertIsNotNone(chain(values,target,operators))
if __name__=='__main__':unittest.main()
