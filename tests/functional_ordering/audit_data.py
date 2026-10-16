#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Audit all ordering datasets through the real Qt translation conversion."""
import argparse
import ast
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tempfile
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]


def translated_messages(catalogue):
    with tempfile.TemporaryDirectory() as directory:
        ts = Path(directory) / 'pt.ts'
        subprocess.run(['/usr/lib/qt6/bin/lconvert', '-i', str(catalogue),
                        '-o', str(ts), '-target-language', 'pt_PT'], check=True)
        tree = ET.parse(ts)
        return {message.findtext('source'): message.findtext('translation')
                for context in tree.findall('context') if context.findtext('name') == 'Data'
                for message in context.findall('message')}


def audit(catalogue):
    messages = translated_messages(catalogue)
    rows, errors = [], []
    for dataset, minimum, maximum in [(1, 3, 5), (2, 6, 10)]:
        source = ROOT / f'src/activities/ordering_sentences/resource/{dataset}/Data.qml'
        expression = re.search(r'sentences:\s*qsTr\((.*?)\)\s*\n', source.read_text(), re.S)[1]
        english = ''.join(ast.literal_eval(token) for token in re.findall(r"'(?:[^'\\]|\\.)*'", expression))
        translated = messages[english]
        sentences = translated.split('\n')
        assert len(sentences) >= 10
        for level, sentence in enumerate(sentences, 1):
            tokens = sentence.split('|')
            words = sentence.replace('|', ' ').split()
            if not minimum <= len(words) <= maximum:
                errors.append(f'dataset {dataset}, sentence {level}: {len(words)} words outside {minimum}..{maximum}: {sentence}')
            assert all(token and token == token.strip() for token in tokens)
            assert sentence[0].isupper() and sentence[-1] in '.!?'
            rows.append({'dataset': dataset, 'sentence': level, 'words': len(words), 'cards': len(tokens), 'text': sentence.replace('|', ' ')})
    alphabet_rows = []
    for dataset in range(1, 7):
        path = ROOT / f'src/activities/ordering_alphabets/resource/{dataset}/Data.qml'
        text = path.read_text()
        entries = re.findall(r'string:\s*qsTr\("([^"]+)"\)', text)
        assert len(entries) == (2 if dataset <= 2 else 1)
        for entry in entries:
            letters = messages.get(entry, entry).split('|')
            assert all(len(letter) == 1 and letter in 'abcdefghijklmnopqrstuvwxyz' for letter in letters)
            assert len(set(letters)) == len(letters)
            assert letters == sorted(letters)
            assert len(letters) == (5 if dataset <= 2 else 26)
            alphabet_rows.append({'dataset': dataset, 'alphabet': ''.join(letters), 'direction': 'ascending' if dataset % 2 else 'descending'})
    number_rows = []
    for dataset in range(1, 9):
        path = ROOT / f'src/activities/ordering_numbers/resource/{dataset}/Data.qml'
        text = path.read_text()
        direction = re.search(r'mode:\s*"([^"]+)"', text)[1]
        assert direction == ('ascending' if dataset % 2 else 'descending')
        if dataset <= 2:
            values = json.loads(re.search(r'values:\s*(\[[^\]]+\])', text)[1])
            assert values == [1, 2, 3, 4, 5]
            number_rows.append({'dataset': dataset, 'fixed': values, 'direction': direction})
        else:
            parameters = {name: int(re.search(name + r':\s*(\d+)', text)[1])
                          for name in ('minNumber', 'maxNumber', 'numberOfElementsToOrder')}
            assert parameters['maxNumber'] - parameters['minNumber'] + 1 >= parameters['numberOfElementsToOrder']
            number_rows.append({'dataset': dataset, 'random': parameters, 'direction': direction})
    resources = {}
    for activity in ('ordering_numbers', 'ordering_alphabets', 'ordering_sentences'):
        for path in sorted((ROOT / 'src/activities' / activity).rglob('*')):
            if path.is_file():
                resources[str(path.relative_to(ROOT))] = hashlib.sha256(path.read_bytes()).hexdigest()
    assert not errors, '\n'.join(errors)
    return {'sentences': rows, 'alphabet_levels': alphabet_rows, 'number_levels': number_rows, 'source_files_sha256': resources,
            'scope': 'All translated sentence word-count bands and all three source resource inventories; native gameplay separately.'}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--catalogue', type=Path, default=ROOT / 'poqm/pt/gcompris_qt.po')
    args = parser.parse_args()
    print(json.dumps(audit(args.catalogue), ensure_ascii=False, indent=2))
