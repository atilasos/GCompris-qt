#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Verify complete fraction data against independently interpreted PT quantities."""
from fractions import Fraction
import json
from pathlib import Path
from inventory import collect
from oracles import instruction_fraction


def audit(datasets):
    summary=[]
    for dataset in datasets:
        activity=dataset['path'].split('/')[2]
        for index,level in enumerate(dataset['levels'],1):
            assert level['shuffle'] and level['subLevels']
            for question in level['subLevels']:
                assert question['chartType'] in ('pie','rectangle')
                if activity=='fractions_create':
                    n,d=question['numerator'],question['denominator']
                    assert isinstance(n,int) and isinstance(d,int) and 0<n<2*d and 2<=d<=12
                    assert instruction_fraction(question['instruction'],d)==Fraction(n,d),question
                else:
                    assert question['random'] and question['maxFractions'] in (1,2)
                    assert not (question['fixedNumerator'] and question['fixedDenominator'])
            summary.append({'activity':activity,'dataset':Path(dataset['path']).parent.name,'entry':index,
                            'questions':len(level['subLevels']),'chart':level['subLevels'][0]['chartType']})
    assert len(summary)==30
    assert sum(row['questions'] for row in summary if row['activity']=='fractions_create')==78
    assert sum(row['questions'] for row in summary if row['activity']=='fractions_find')==60
    return summary


if __name__=='__main__':
    datasets=collect()
    summary=audit(datasets)
    output=Path(__file__).resolve().parents[2]/'.scratch/pt-pt/functional-fractions/inventory.json'
    output.write_text(json.dumps({'datasets':datasets,'summary':summary},ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({'levels':len(summary),'questions':sum(row['questions'] for row in summary)}))
