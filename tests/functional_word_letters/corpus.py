#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Audit the complete PT spelling corpus without the activity JS loaders."""
import hashlib
import json
from pathlib import Path
import unicodedata

ROOT=Path(__file__).resolve().parents[2]
RESOURCE=ROOT/'src/activities/lang/resource'


def corpus():
    translations=json.loads((RESOURCE/'content-pt.json').read_text())
    datasets={}
    for filename in ('words.json','words_sample.json'):
        chapters=json.loads((RESOURCE/filename).read_text())
        lessons=[]
        for chapter in chapters:
            for lesson in chapter['content']:
                words=[]
                omitted=[]
                for entry in lesson['content']:
                    key=entry['voice'].split('/')[-1].replace('$CA','ogg')
                    if translations.get(key):
                        text=translations[key]
                        assert unicodedata.is_normalized('NFC',text), (key,text)
                        assert text.strip()==text and text, (key,text)
                        words.append({'key':key,'text':text,'image':chapter.get('imgPrefix','')+entry['image']})
                    else:omitted.append(key)
                assert words,lesson['name']
                lessons.append({'name':lesson['name'],'words':words,'omitted':omitted,
                    'characters':sorted(set(''.join(word['text'].lower() for word in words))-{' '})})
        datasets[filename]=lessons
    return {'translation_sha256':hashlib.sha256((RESOURCE/'content-pt.json').read_bytes()).hexdigest(),
            'translation_entries':len(translations),'datasets':datasets,
            'policy':'Exact NFC accents; Hangman folds case, letter-in-word matches exact source characters; spaces auto-revealed/ignored; hyphens remain characters.'}


if __name__=='__main__':
    print(json.dumps(corpus(),ensure_ascii=False,indent=2))
