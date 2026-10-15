#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Apply the reviewed PT-PT interface corrections; --check never edits files.

Only translation fields change. Pronunciation-dependent variants such as facto,
contacto, carácter, espectador and insecto are deliberately outside this list.
The JSON report is a review aid, not a record of teacher approval.
"""
import argparse
import ast
import importlib.util
import json
from pathlib import Path
import re
import textwrap

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('audit_pt_pt', ROOT / 'tools/audit-pt-pt.py')
AUDIT = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(AUDIT)

# Complete words only; avoid changing msgids, references, HTML or proper names.
STEMS = {
    'acç': 'aç', 'activ': 'ativ', 'actual': 'atual', 'object': 'objet',
    'selecç': 'seleç', 'selecc': 'selec', 'selector': 'seletor', 'direcç': 'direç', 'efect': 'efet', 'direct': 'diret',
    'correcç': 'correç', 'correct': 'corret',
    'respect': 'respet', 'exact': 'exat', 'interacç': 'interaç',
    'interactiv': 'interativ', 'reactiv': 'reativ', 'reacç': 'reaç',
    'subtracç': 'subtraç', 'subtract': 'subtrat', 'fracç': 'fraç',
    'atracç': 'atraç', 'protecç': 'proteç', 'protect': 'protet',
    'rectâng': 'retâng', 'rectang': 'retang', 'arquitect': 'arquitet',
    'electric': 'eletric', 'project': 'projet', 'adopt': 'adot',
    'excepç': 'exceç',
}
# The full-word allowlist keeps the codemod conservative and rerunnable.
WORDS = '''acção acções actividade actividades activar activo activos activada activas
activam actual actualmente actualizada actualizadas actualizados actualizado actualização
actualizações actualizar objecto objectos objectivo selecciona seleccionar seleccionada
seleccionado seleccionares seleccionaste seleccionadas seleccionados seleccionou
seleccionas seleccioná selecção selector deseleccionares deseleccionar efectuar
directa directamente direcção direcções correcto correcta correctos correctas correctamente
incorrectos incorrectas incorrectamente correcção correcções respectivo respectiva
respectivos respectivas exactamente interacção interactiva reactivar reactivares reacção
subtracção subtracções subtractiva fracção fracções atracção atracções protecção protectivos
rectângulo rectângulos rectangulares arquitectura arquitectónico arquitectónicos arquitectos
arquitectural electricidade projectada projectos adoptar excepções activar desactivar
desactivados desactivado desactivam desactive activa recta óptimo'''.split()
REPLACEMENTS = {}
for word in WORDS:
    replacement = word
    for old, new in STEMS.items():
        replacement = replacement.replace(old, new)
    replacement = replacement.replace('recta', 'reta').replace('óptimo', 'ótimo')
    for original, result in ((word, replacement), (word.capitalize(), replacement.capitalize()),
                             (word.upper(), replacement.upper())):
        REPLACEMENTS[original] = result
WORD = re.compile(r'\b[^\W\d_]+\b', re.UNICODE)

EXACT = {
    'Find the day of the week 5 months and 2 days after July 3rd.':
        'Descobre o dia da semana 5 meses e 2 dias depois de 3 de julho.',
    'Find the day of the week 1 month and 3 days before December 28th.':
        'Descobre o dia da semana 1 mês e 3 dias antes de 28 de dezembro.',
    'Find the date 2 months, 1 week and 5 days after January 12th.':
        'Descobre a data 2 meses, 1 semana e 5 dias depois de 12 de janeiro.',
    'Human Rights Day is celebrated five days after December 5.<br> Find the date of Human Rights Day in 2017.':
        'O Dia dos Direitos Humanos celebra-se cinco dias depois de 5 de dezembro.<br>Descobre a data do Dia dos Direitos Humanos em 2017.',
    "Mark's birthday is on November 4. In 2017 his party was exactly two weeks later.<br> Find the date of his party in 2017":
        'O aniversário do Marco é a 4 de novembro. Em 2017, a sua festa foi exatamente duas semanas depois.<br>Descobre a data da festa em 2017',

    'Find the day of the week 17 days before August 16th.':
        'Descobre o dia da semana 17 dias antes de 16 de agosto.',
    'Ctrl + V: paste copied or cut text': 'Ctrl + V: colar o texto copiado ou cortado',
    'Space or Enter: select an answer': 'Espaço ou Enter: selecionar uma resposta',
    'Enter or Return: replay the rhythm': 'Enter ou Return: repetir o ritmo',
    'Enter or Return: submit your answer': 'Enter ou Return: enviar a resposta',
    '''Catch the alphabet letters. With a keyboard use the arrow keys to move the helicopter. With a pointing device you just click or tap on the target location. To know which letter you have to catch you can either remember it or check the bottom right corner.''':
        'Apanha as letras do alfabeto. Usa as teclas de direção para mover o helicóptero. Com o rato ou num ecrã tátil, clica ou toca no local de destino. Para saberes qual a letra que tens de apanhar, podes recordá-la ou consultá-la no canto inferior direito.',
    'First, properly organize the items so that you can count them. Then, click on an item of the answers list in the top left area and enter the corresponding answer with the keyboard.':
        'Primeiro, organiza os objetos para os poderes contar. Depois, clica num elemento da lista de respostas no canto superior esquerdo e escreve a resposta correspondente com o teclado.',
    'Vertical subtraction': 'Subtração vertical',
    'Practice subtraction.': 'Pratica a subtração.',
    'Write and solve addition, 2 digits, 2 lines, without carry.':
        'Escreve e resolve a adição, 2 dígitos, 2 linhas, sem transportar.',
}
REGROUPING = (
    'Na subtração vertical, os números são escritos um abaixo do outro, alinhados pela direita. '
    'O número superior chama-se minuendo: é a quantidade inicial, da qual se subtrai outro '
    'número para obter a diferença. O número inferior chama-se subtrativo: é a quantidade '
    'a subtrair ao minuendo. O resultado escreve-se na linha inferior. '
    'Começa pela coluna da direita: subtrai o algarismo inferior ao superior e escreve o '
    'resultado na mesma coluna, na linha inferior. Se o algarismo superior for menor que '
    'o inferior, podes reagrupar uma unidade da coluna seguinte do minuendo. Por exemplo, '
    'ao acrescentares 10 unidades ao número superior de uma coluna, tens de retirar uma '
    'unidade ao número superior da coluna seguinte. Este é o método de reagrupamento. '
    'Nesta atividade, clica no retângulo vazio à esquerda do número superior e seleciona 1. '
    'Na coluna seguinte, clica no retângulo vazio à direita do número superior e seleciona -1. '
    'Escreve o resultado da coluna na linha inferior e repete o processo nas colunas seguintes '
    'até terminares a operação. Clica em OK para validar a resposta. Nalguns níveis, tens de '
    'escrever a operação apresentada antes de a resolveres. Nesse caso, clica em Pronto '
    'quando a operação estiver escrita corretamente e depois resolve-a.'
)


def revised(source, text, field='msgstr'):
    plurals = {
        'Find the %n previous number(s).': ('Encontra %n número anterior.', 'Encontra os %n números anteriores.'),
        'Find the %n next number(s).': ('Encontra %n número seguinte.', 'Encontra os %n números seguintes.'),
        'Find the %n in-between number(s)': ('Encontra %n número intermédio.', 'Encontra os %n números intermédios.'),
        'Find the %n missing numbers': ('Encontra %n número em falta.', 'Encontra os %n números em falta.'),
    }
    if source in plurals and field in ('msgstr[0]', 'msgstr[1]'):
        return plurals[source][field == 'msgstr[1]']
    if source in EXACT:
        return EXACT[source]
    if source.startswith('In a vertical subtraction,') and 'borrowing by regrouping method' in source:
        return REGROUPING
    if source.startswith('Write and solve subtraction,'):
        text = text.replace('Resolver e resolver', 'Escreve e resolve')
    # Joined words came from incorrectly joined PO continuations.
    for old, new in {
        'paraseleccionares': 'para selecionares', 'paraa área': 'para a área',
        'largadascorresponda': 'largadas corresponda', 'validares atua resposta': 'validares a tua resposta',
        'rápido a enviares e resposta': 'rápido a enviar a resposta',
        'rápido e enviares a resposta': 'rápido a enviar a resposta',
    }.items():
        text = text.replace(old, new)
    return WORD.sub(lambda m: REPLACEMENTS.get(m.group(), m.group()), text)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    parser.add_argument('--report', type=Path)
    args = parser.parse_args()
    path = ROOT / 'poqm/pt/gcompris_qt.po'
    entries = AUDIT.read_po(path)
    changes = []
    targets = {}
    for entry in entries:
        for key, old in entry.items():
            if not key.startswith('msgstr'):
                continue
            new = revised(entry['msgid'], old, key)
            if old != new:
                targets[(entry.get('msgctxt', ''), entry['msgid'], key)] = new
                changes.append({'context': entry.get('msgctxt', ''), 'source': entry['msgid'],
                                'field': key, 'before': old, 'after': new,
                                'references': entry['references'], 'teacher_review': 'pending'})
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(json.dumps(changes, ensure_ascii=False, indent=2) + '\n')
    if args.check:
        print(f'{len(changes)} translation fields still need the reviewed corrections.')
        return bool(changes)
    # Parse each block with the existing PO reader's field grammar. Preserve all
    # unchanged formatting, translator comments, source keys and header metadata.
    blocks = re.split(r'(\n\s*\n)', path.read_text())
    for index in range(0, len(blocks), 2):
        lines = blocks[index].splitlines(keepends=True)
        values = {}
        field = None
        spans = {}
        for number, line in enumerate(lines):
            match = AUDIT.FIELD.fullmatch(line.strip())
            if match:
                field, quoted = match.groups()
                values[field] = ast.literal_eval(quoted)
                spans[field] = [number, number + 1]
            elif line.strip().startswith('"') and field:
                values[field] += ast.literal_eval(line.strip())
                spans[field][1] = number + 1
            elif line.strip().startswith('#'):
                field = None
        for field, (start, end) in sorted(spans.items(), key=lambda pair: pair[1][0], reverse=True):
            key = (values.get('msgctxt', ''), values.get('msgid', ''), field)
            if key in targets:
                ending = '\n' if lines[end - 1].endswith('\n') else ''
                encoded = json.dumps(targets[key], ensure_ascii=False)
                if len(field) + 1 + len(encoded) <= 79:
                    lines[start:end] = [field + ' ' + encoded + ending]
                else:
                    chunks = textwrap.wrap(encoded[1:-1], width=75, break_long_words=False,
                                           break_on_hyphens=False, drop_whitespace=False,
                                           replace_whitespace=False)
                    lines[start:end] = [field + ' ""\n'] + [
                        '"' + chunk + '"' + ('\n' if i < len(chunks) - 1 else ending)
                        for i, chunk in enumerate(chunks)]
        blocks[index] = ''.join(lines)
    path.write_text(''.join(blocks))
    print(f'Corrected {len(changes)} translation fields. Teacher review remains pending.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
