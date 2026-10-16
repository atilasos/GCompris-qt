# SPDX-License-Identifier: GPL-3.0-or-later
import copy,json,tempfile,unittest
from pathlib import Path
from store import Writer,Reader
from semantics import photo_level,count_levels

def fixture():
 candidate={'box':[2,2,3,3],'pixel':[2,2],'pixels':1,'peak_difference':255,'threshold':25};initial={'text':'0/1','found':0,'total':1};complete={'text':'1/1','found':1,'total':1}
 rule={'image_size':[4,4],'wrong_pixel':[0,0],'candidates':[candidate]}
 record={'level':1,'frame':{'x':2,'y':2,'width':4,'height':4},'initial':initial,'wrong':{'point':{'x':.5,'y':.5},'mark':{'source':'qrc:/cross.svg'},'score':initial},'attempts':[{'candidate':candidate,'point':{'x':2.5,'y':2.5},'before':initial,'after':complete,'circles':[{'x':2.5,'y':2.5}]}],'complete':complete,'bonus':'qrc:/gcompris/src/core/resource/bonus/flower_good.svg'}
 return rule,record
class FiniteSemantics(unittest.TestCase):
 def test_literal_photo_counter_and_wrong_repair(self):
  rule,record=fixture();self.assertEqual(photo_level(rule,record),1)
 def test_coherent_object_reseal_passes_hashes_but_fails_counter_contract(self):
  rule,record=fixture();record=copy.deepcopy(record);record['attempts'][0]['after']['found']=2
  with tempfile.TemporaryDirectory() as tmp:
   root=Path(tmp);raw=root/'record.json';raw.write_text(json.dumps({'rule':rule,'record':record}));writer=Writer(root/'tampered');writer.file('observed.json',raw);forged_anchor=writer.finish({'purpose':'coherently recalculated physical negative fixture'});reader=Reader(root/'tampered',forged_anchor);observed=reader.json('observed.json')
   with self.assertRaisesRegex(ValueError,'counter progression'):photo_level(observed['rule'],observed['record'])
 def test_empty_finite_coverage_is_not_a_success(self):
  with self.assertRaisesRegex(ValueError,'Nonempty complete finite level coverage'):count_levels([],21)
if __name__=='__main__':unittest.main()
