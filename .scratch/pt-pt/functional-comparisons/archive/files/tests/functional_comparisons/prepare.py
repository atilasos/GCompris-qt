#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Generate native cases without overwriting past evidence."""
import argparse
import json
from pathlib import Path
from data import inventory
HERE=Path(__file__).resolve().parent


def case(activity,controls=False,manual=False,pilot=False):
    data=inventory()[activity]
    template=(HERE/('comparator.qml' if activity=='comparator' else 'adjacent.qml')).read_text()
    if manual:template=template.replace('property bool manual: false','property bool manual: true')
    if not controls:
        return template.replace('property int targetLevels: 1','property int targetLevels: '+str(1 if pilot else len(data['levels'])))
    fragment=(HERE/'controls.fragment').read_text()
    if activity=='comparator':
        replacements={'__TITLE__':'Comparar os números','__PARTIAL__':'        selectRow(0,false);enter("<",true);keyClick(Qt.Key_Backspace);checked(texts(lineRepeater.itemAt(0))[1].text,"");keyClick(Qt.Key_Right);keyClick(Qt.Key_Space);ensure(texts(lineRepeater.itemAt(0))[1].text!=="");keyClick(Qt.Key_Up);checked(selectedRow(),4);keyClick(Qt.Key_Down);checked(selectedRow(),0);',
          '__RESTART__':'        checked(texts(lineRepeater.itemAt(0))[1].text,"");checked(okButton.visible,false);',
          '__FOCUS__':'        keyClick(Qt.Key_Down);checked(selectedRow(),1);enter("=",true);checked(texts(lineRepeater.itemAt(1))[1].text,"=");'}
    else:
        replacements={'__TITLE__':'Descobrir os números sequenciais.',
          '__PARTIAL__':'        configure();var question=tiles(questionTilesFlow,true),blank=question.filter(function(t){return shown(t)==="?";})[0];var anchor=question.findIndex(function(t){return shown(t)!=="?";}),index=question.indexOf(blank),expected=value(shown(question[anchor]))+index-anchor;drag(proposal(expected),blank);checked(shown(blank),String(expected));checked(score.currentSubLevel,0);ensure(okButton.visible);',
          '__RESTART__':'        ensure(tiles(questionTilesFlow,true).some(function(t){return shown(t)==="?";}));checked(okButton.visible,false);',
          '__FOCUS__':'        question=tiles(questionTilesFlow,true);blank=question.filter(function(t){return shown(t)==="?";})[0];anchor=question.findIndex(function(t){return shown(t)!=="?";});index=question.indexOf(blank);expected=value(shown(question[anchor]))+index-anchor;drag(proposal(expected),blank);ensure(okButton.visible);keyClick(Qt.Key_Return);tryCompare(score,"currentSubLevel",1,2500);'}
    for key,value in replacements.items():fragment=fragment.replace(key,json.dumps(value,ensure_ascii=False) if key=='__TITLE__' else value)
    count=sum(level['source']==data['levels'][0]['source'] for level in data['levels'])
    fragment=fragment.replace('__TOTAL__',str(len(data['levels']))).replace('__DATASETS__',str(data['datasets'])).replace('__REDUCED__',str(len(data['levels'])-count))
    return template.split('    function test_complete()')[0]+fragment


if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('activity',choices=['comparator','adjacent_numbers']);parser.add_argument('--controls',action='store_true');parser.add_argument('--manual',action='store_true');parser.add_argument('--pilot',action='store_true');parser.add_argument('--output',type=Path,required=True);args=parser.parse_args()
    with args.output.open('x') as stream:stream.write(case(args.activity,args.controls,args.manual,args.pilot))
