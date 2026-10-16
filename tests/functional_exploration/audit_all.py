#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Compose the three immutable task-84 evidence generations."""
import argparse,json
from pathlib import Path
from audit_supplement import combined,verify
SECOND_INDEX_SHA256='75e6dd5028d64dcdf3e6e18a3fb948aa2f3820af6d5dbf44f3e0707212f48437'
def audit_all(base):
 result=combined(base)
 second=verify(base/'supplement2-archive',base/'archive',anchor=SECOND_INDEX_SHA256,before='supplement',after='supplement2',count=8,run_prefix='supplement2',previous=base/'supplement-archive')
 result['second_supplemental_presentations']=second['supplemental_presentations'];result['second_supplemental_red_green_pairs']=1
 return result
if __name__=='__main__':
 parser=argparse.ArgumentParser();parser.add_argument('--evidence',type=Path,default=Path(__file__).resolve().parents[2]/'.scratch/pt-pt/functional-exploration');args=parser.parse_args();print(json.dumps(audit_all(args.evidence)))
