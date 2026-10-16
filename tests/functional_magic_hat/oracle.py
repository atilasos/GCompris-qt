# SPDX-License-Identifier: GPL-3.0-or-later
"""Arithmetic and bounded star representations from visible evidence only."""
from itertools import product


def result_vector(first,second,mode):
    if mode not in ['plus','minus']:raise ValueError(mode)
    result={}
    for sign,rows in [(1,first),(1 if mode=='plus' else -1,second)]:
        for row in rows:
            if row is not None:result[row['group']]=result.get(row['group'],0)+sign*row['count']*row['weight']
    return result


def representation(target,rows):
    candidates=[]
    for counts in product(*(range(11) if row else [0] for row in rows)):
        actual={key:0 for key in target}
        for count,row in zip(counts,rows):
            if row:actual[row['group']]=actual.get(row['group'],0)+count*row['weight']
        if actual==target:candidates.append(counts)
    return min(candidates,key=lambda counts:(sum(counts),counts)) if candidates else None
