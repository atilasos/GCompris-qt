# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from audit import validate_gameplay

class EvidenceContract(unittest.TestCase):
    def fixture(self):
        sizes=[3,4,5,6,9,10]
        return dict(failures=0, completed=[dict(players=p,level=i+1,pairs=n,score1=n,score2=0,won=True) for p in [1,2] for i,n in enumerate(sizes)],correctPairs=74,tuxPairs=0,wrongPairs=12,blockedClicks=12,tuxTurns=0,losses=0,forcedDefeats=0,winSignals=12,lossSignals=0,audioErrors=[])
    def test_complete_native_ledger(self):
        validate_gameplay('memory',self.fixture())
    def test_reject_missing_level(self):
        data=self.fixture();data['completed'].pop()
        with self.assertRaises(AssertionError):validate_gameplay('memory',data)
    def test_reject_invented_score(self):
        data=self.fixture();data['completed'][0]['score1']=2
        with self.assertRaises(AssertionError):validate_gameplay('memory',data)
    def test_reject_wrong_pair_budget(self):
        data=self.fixture();data['correctPairs']+=1
        with self.assertRaises(AssertionError):validate_gameplay('memory',data)
    def test_reject_audio_decoder_error(self):
        data=self.fixture();data['audioErrors']=[{'error':1}]
        with self.assertRaises(AssertionError):validate_gameplay('memory',data)

if __name__=='__main__':unittest.main()
