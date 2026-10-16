#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Extract authored questions and independently verify their Gregorian answers."""
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
from oracle import solve

ROOT=Path(__file__).resolve().parents[2]
SPEC=importlib.util.spec_from_file_location('pt_po',ROOT/'tools/audit-pt-pt.py')
PO=importlib.util.module_from_spec(SPEC);SPEC.loader.exec_module(PO)
ACTIVITIES=['calendar','find_the_day']


def inventory():
    translations={(e.get('msgctxt',''),e['msgid']):e.get('msgstr','') for e in PO.read_po(ROOT/'poqm/pt/gcompris_qt.po')}
    result={}
    for activity in ACTIVITIES:
        path=ROOT/f'src/activities/{activity}/{activity}_dataset.js'
        code="const fs=require('fs'),vm=require('vm');let c={qsTr:x=>x};vm.createContext(c);vm.runInContext(fs.readFileSync(process.argv[1],'utf8'),c);process.stdout.write(JSON.stringify(c.get()));"
        authored=json.loads(subprocess.check_output(['node','-e',code,str(path)],text=True))
        levels=[]
        for index,(configs,questions) in enumerate(authored):
            assert len(configs)==1
            config=configs[0];year=config['visibleYear'];month=config['visibleMonth']+1
            rows=[]
            for entry in questions:
                expected=solve(entry['question'],year,month)
                answer=entry['answer']
                if 'dates' in expected:
                    assert expected['dates']==[[answer['year'],answer['month']+1,answer['day']]],entry
                elif 'weekdays' in expected:assert expected['weekdays']==[answer['dayOfWeek']],entry
                else:assert expected['months']==[m+1 for m in answer['month']],entry
                translated=translations[(activity+'_dataset|',entry['question'])]
                assert translated and translated!=entry['question']
                rows.append({'question':entry['question'],'portuguese':translated,'expected':expected})
            assert len({r['portuguese'] for r in rows})==len(rows)
            levels.append({'level':index+1,'configuration':config,'questions':rows})
        result[activity]={'source':str(path.relative_to(ROOT)),'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'levels':levels}
    return result


if __name__=='__main__':print(json.dumps(inventory(),indent=2,ensure_ascii=False))
