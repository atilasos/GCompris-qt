# SPDX-License-Identifier: GPL-3.0-or-later
"""Separate source audit. Never supplies the native movement solver with answers."""
import re


def catalogue_alphabet(catalogue):
    pattern=r'msgctxt "AlphabetSequence\|"\nmsgid "a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z"\nmsgstr "([^"]+)"'
    matches=re.findall(pattern,catalogue.read_text())
    assert len(matches)==1
    return matches[0].replace('/','')


def inventory(source):
    from oracle import sequence
    report={}
    for activity,filename in [('planegame','Sequence.qml'),('numbers-odd-even','NumbersOddEven.qml')]:
        content=(source/'src/activities'/activity/filename).read_text()
        rows=re.findall(r'data:\s*"([0-9 ]+)"\.split\(" "\),\s*showNext:\s*(true|false)',content)
        assert len(rows)==4
        levels=[]
        for index,(text,shown) in enumerate(rows):
            values=text.split();assert values==sequence(activity,index+1)
            assert (shown=='true')==(index<2)
            levels.append({'level':index+1,'values':values,'show_next':shown=='true'})
        report[activity]=levels
    alphabet=catalogue_alphabet(source/'poqm/pt/gcompris_qt.po')
    content=(source/'src/activities/alphabet-sequence/AlphabetSequence.qml').read_text()
    assert re.findall(r'showNext:\s*(true|false)',content)==['true','true','false','false']
    report['alphabet-sequence']=[{'level':level,'values':list(alphabet if level%2 else alphabet.upper()),'show_next':level<=2} for level in range(1,5)]
    return report
