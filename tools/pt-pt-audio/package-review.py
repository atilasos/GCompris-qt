#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Package the 32 new PT-PT recordings for offline teacher review."""
import argparse
import csv
import hashlib
import html
import io
import json
from pathlib import Path, PurePosixPath
import zipfile

ROOT = Path(__file__).resolve().parents[2]
GROUPS = {'alphabet': 'Caracteres', 'france': 'Topónimos',
          'geography': 'Topónimos', 'intro': 'Instruções'}


def render_page(recordings):
    sections = []
    for group_number, group in enumerate(dict.fromkeys(GROUPS.values())):
        clips = []
        for number, row in enumerate(recordings, 1):
            if GROUPS[PurePosixPath(row['file']).parts[0]] != group:
                continue
            name = html.escape(row['file'], quote=True)
            text = html.escape(row['text'], quote=True)
            clips.append(f'''<article id="clip-{number:02d}">
<h3>{number:02d}. {name}</h3>
<p class="transcription">{text}</p>
<audio controls preload="none" aria-label="Gravação {number:02d}" src="{name}">
O browser não reproduz este áudio. <a href="{name}">Abrir o ficheiro OGG</a>.
</audio>
</article>''')
        sections.append(f'<section id="grupo-{group_number}"><h2>{group}</h2>\n' + '\n'.join(clips) + '\n</section>')
    return '''<!doctype html>
<html lang="pt-PT">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Audição das 32 novas gravações PT-PT</title>
<style>
body { font-family: system-ui, sans-serif; line-height: 1.5; margin: auto;
       padding: 1.5rem; max-width: 60rem; color: #20313b; background: #f6f8fa; }
h1 { font-size: 1.8rem; line-height: 1.2; }
h2 { margin-top: 2rem; }
h3 { font-size: 1rem; overflow-wrap: anywhere; }
article { padding: 1rem 1.25rem; margin: 1rem 0; border: 1px solid #c8d3db;
          border-radius: .5rem; background: white; }
a { color: #154e85; }
audio { width: 100%; max-width: 35rem; }
.transcription { font-size: 1.1rem; }
.instructions { border-left: .3rem solid #236b80; padding-left: 1rem; }
</style>
</head>
<body>
<h1>Audição das 32 novas gravações PT-PT</h1>
<div class="instructions">
<p>A geração destas gravações foi autorizada. A audição e a revisão pedagógica
final de cada gravação continuam pendentes.</p>
<p>Ouve cada gravação e compara-a com a transcrição. Nos caracteres, avalia o nome
explícito da letra com o acento ou a cedilha. Estes nomes não substituem fonemas.</p>
<p>Para comunicar uma correção, indica o número e o nome do ficheiro apresentados
no cartão, a palavra ou passagem a corrigir e a pronúncia ou o texto pretendido.</p>
<p>Podes preencher a coluna <strong>correcoes</strong> de <a href="review.csv">review.csv</a>.
Todas as linhas começam com o estado <code>pending</code>. Esta página não guarda
respostas nem marca aprovações.</p>
</div>
<nav aria-label="Grupos"><a href="#grupo-0">Caracteres</a> ·
<a href="#grupo-1">Topónimos</a> · <a href="#grupo-2">Instruções</a></nav>
''' + '\n'.join(sections) + '''
<footer><p>Os ficheiros OGG são os originais, sem alterações. Consulta o
<a href="manifest.json">manifesto</a> e o <a href="NOTICE.md">aviso de origem e licenças</a>.
A pasta extraída funciona sem Internet e sem instalar o jogo.</p></footer>
</body>
</html>
'''


def package_review(source, output):
    manifest_bytes = (source / 'manifest.json').read_bytes()
    manifest = json.loads(manifest_bytes)
    recordings = manifest['recordings']
    if manifest['locale'] != 'pt_PT' or len(recordings) != 32:
        raise ValueError('O manifesto tem de identificar 32 gravações em pt_PT')
    payloads = {}
    csv_buffer = io.StringIO(newline='')
    writer = csv.writer(csv_buffer, delimiter=';')
    writer.writerow(['numero', 'ficheiro', 'grupo', 'transcricao', 'estado', 'correcoes'])
    for number, row in enumerate(recordings, 1):
        name = row['file']
        path = PurePosixPath(name)
        if (len(path.parts) != 2 or path.parts[0] not in GROUPS
                or path.suffix != '.ogg' or '..' in path.parts or '\\' in name
                or name != path.as_posix() or name in payloads):
            raise ValueError(f'Nome de gravação inválido ou repetido: {name}')
        data = (source / name).read_bytes()
        if len(data) != row['bytes'] or hashlib.sha256(data).hexdigest() != row['sha256']:
            raise ValueError(f'SHA-256 ou tamanho diferente do manifesto: {name}')
        payloads[name] = data
        writer.writerow([f'{number:02d}', name, GROUPS[path.parts[0]], row['text'], 'pending', ''])
    payloads['manifest.json'] = manifest_bytes
    payloads['NOTICE.md'] = (source / 'NOTICE.md').read_bytes()
    payloads['review.csv'] = csv_buffer.getvalue().encode('utf-8-sig')
    payloads['index.html'] = render_page(recordings).encode('utf-8')
    output.parent.mkdir(parents=True, exist_ok=True)
    # Exclusive creation preserves any review archive already prepared by a teacher.
    with output.open('xb') as stream:
        with zipfile.ZipFile(stream, 'w', compression=zipfile.ZIP_DEFLATED) as archive:
            for name, data in payloads.items():
                info = zipfile.ZipInfo(name, date_time=(1980, 1, 1, 0, 0, 0))
                info.compress_type = zipfile.ZIP_DEFLATED
                info.external_attr = 0o100644 << 16
                archive.writestr(info, data)
    return {'output': str(output.resolve()), 'recordings': len(recordings),
            'sha256': hashlib.sha256(output.read_bytes()).hexdigest(), 'review_status': 'pending'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, default=ROOT / 'resources/pt-pt-voices')
    parser.add_argument('--output', type=Path, required=True, help='new offline ZIP archive')
    args = parser.parse_args()
    try:
        result = package_review(args.source, args.output)
    except (ValueError, KeyError, OSError) as error:
        parser.error(str(error))
    print(json.dumps(result, ensure_ascii=False))


if __name__ == '__main__':
    main()
