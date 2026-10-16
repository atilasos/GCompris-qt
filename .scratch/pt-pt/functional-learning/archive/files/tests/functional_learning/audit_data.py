#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Check every original question against independent integer and quantity bounds."""
from inventory import collect
from oracles import quantity

COUNTS={'learn_digits':list(range(2,11)),'learn_additions':[3,6,10],'learn_subtractions':[3,6,10,10,10]}


def audit(root=None):
    datasets=collect() if root is None else collect(root)
    result={name:[] for name in COUNTS}
    for dataset in datasets:
        name=dataset['path'].split('/')[2];assert len(dataset['levels'])==1
        level=dataset['levels'][0];questions=level['questionsArray']
        assert level['randomOrder'] and len(questions)==len(set(questions))
        assert all(0<=quantity(text)<=level['circlesModel'] for text in questions)
        result[name].append(level)
    assert {name:[len(level['questionsArray']) for level in levels] for name,levels in result.items()}==COUNTS
    return result


if __name__=='__main__':
    import json
    print(json.dumps(audit(),ensure_ascii=False,indent=2))
