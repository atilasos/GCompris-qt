#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Prove the recorded PT catalogue remains equivalent for the exercised sources."""
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]
BASELINE = '52be6feb5'
PREFIXES = ('core/', 'activities/erase/', 'activities/erase_clic/', 'activities/erase_2clic/')


def messages(catalogue, ts):
    subprocess.run(['/usr/lib/qt6/bin/lconvert', '-i', str(catalogue), '-o', str(ts),
                    '-target-language', 'pt_PT'], check=True)
    result, relevant = {}, set()
    for context in ET.parse(ts).findall('context'):
        for message in context.findall('message'):
            key = (context.findtext('name'), message.findtext('source'), message.findtext('comment'), message.get('numerus'))
            translation = message.find('translation')
            result[key] = {'text':translation.text or '', 'forms':[form.text for form in translation.findall('numerusform')],
                           'type':translation.get('type')}
            if any(location.get('filename','').startswith(PREFIXES) for location in message.findall('location')):
                relevant.add(key)
    return result, relevant


def verify(current=ROOT / 'poqm/pt/gcompris_qt.po'):
    baseline = subprocess.check_output(['git','show',BASELINE+':poqm/pt/gcompris_qt.po'],cwd=ROOT)
    with tempfile.TemporaryDirectory() as directory:
        directory = Path(directory)
        original = directory / 'original.po';original.write_bytes(baseline)
        before, before_keys = messages(original,directory/'before.ts')
        after, after_keys = messages(current,directory/'after.ts')
    relevant = before_keys | after_keys
    assert relevant and before_keys == after_keys
    changed_relevant = [key for key in relevant if before.get(key) != after.get(key)]
    assert not changed_relevant, changed_relevant
    changed = [{'key':key,'before':before.get(key),'after':after.get(key)}
               for key in sorted(before.keys() | after.keys(),key=str) if before.get(key) != after.get(key)]
    return {'baseline_commit':BASELINE, 'recorded_catalogue_sha256':hashlib.sha256(baseline).hexdigest(),
            'current_catalogue_sha256':hashlib.sha256(current.read_bytes()).hexdigest(),
            'relevant_prefixes':PREFIXES, 'unchanged_relevant_messages':len(relevant),
            'unrelated_changed_messages':changed,
            'scope':'Actual lconvert PT_PT projections for all core and three erase source references; original native receipt hashes retained.'}


if __name__ == '__main__':
    report = verify()
    (ROOT / '.scratch/pt-pt/functional-erase/catalogue-compatibility.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({'unchanged_messages':report['unchanged_relevant_messages'],
                      'unrelated_changes':len(report['unrelated_changed_messages'])}))
