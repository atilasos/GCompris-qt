#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Check identifiability of published examples from the four visible pairs."""
import ast
import hashlib
import json
from pathlib import Path
import re

ROOT=Path(__file__).resolve().parents[2]


def complete(reference,prefix):
    if len(reference)!=8 or len(prefix)!=4:raise ValueError('Eight reference and four visible answer images required')
    mapping={}
    for original,replacement in zip(reference[:4],prefix):
        if original in mapping and mapping[original]!=replacement:raise ValueError('Inconsistent visible pair')
        mapping[original]=replacement
    if len(set(mapping.values()))!=len(mapping) or set(reference)-mapping.keys():raise ValueError('Visible pairs must identify a bijection for every symbol')
    return [mapping[image] for image in reference[4:]]


def inventory():
    path=ROOT/'src/activities/algorithm/algorithm.js';text=path.read_text()
    start=text.index('[',text.index('var sample ='));depth=0
    for end in range(start,len(text)):
        depth+=(text[end]=='[')-(text[end]==']')
        if depth==0:break
    samples=ast.literal_eval(re.sub(r'//[^\n]*','',text[start:end+1]))
    assert len(samples)==7 and all(len(level)==4 for level in samples)
    for level in samples:
        for sample in level:
            prefix=[f'fruit-{value}' for value in sample[:4]]
            assert complete(sample,prefix)==[f'fruit-{value}' for value in sample[4:]]
    return {'source':str(path.relative_to(ROOT)),'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'levels':samples,'examples':sum(map(len,samples)),'unique_patterns':sum(len({tuple(p) for p in level}) for level in samples)}


if __name__=='__main__':print(json.dumps(inventory(),indent=2))
