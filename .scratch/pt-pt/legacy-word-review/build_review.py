#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Build two provisional word samples; never modifies game resources or approvals."""
import argparse
import hashlib
from html import escape
import importlib.metadata
import json
from pathlib import Path
import shutil
import wave
import zipfile

ROOT = Path(__file__).resolve().parents[3]
CAPTURES = ROOT / '.scratch/pt-pt/functional-word-letters/linguistic-captures'
PROPOSALS = {'fawn.ogg': 'cervato', 'tick.ogg': 'carraça'}


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--model', type=Path, required=True)
    parser.add_argument('--output-dir', type=Path, required=True)
    args = parser.parse_args()
    approved = json.loads((ROOT / 'resources/pt-pt-voices/texts.json').read_text())
    if sha(args.model) != approved['model_sha256'] or sha(Path(str(args.model) + '.json')) != approved['config_sha256']:
        parser.error('Model/configuration differs from the previous voice samples')
    if importlib.metadata.version('piper-tts') != '1.8.0':
        parser.error('Requires the existing pinned Piper 1.8.0 environment')
    if args.output_dir.exists():
        parser.error('Use a new output directory; never overwrite a review package')
    pairs = json.loads((CAPTURES / 'capture-index.json').read_text())
    for pair in pairs:
        for entry in pair['captured_files']:
            if sha(CAPTURES / entry['file']) != entry['sha256']:
                parser.error('Captured original differs from its Qt receipt')
    from piper import PiperVoice
    voice = PiperVoice.load(args.model)
    args.output_dir.mkdir(parents=True)
    rows = []
    cards = []
    for number, pair in enumerate(pairs, 1):
        stem = Path(pair['key']).stem
        proposed = PROPOSALS[pair['key']]
        image = f'{stem}.webp'
        original = f'{stem}-original.ogg'
        sample = f'{stem}-proposta.wav'
        shutil.copyfile(CAPTURES / image, args.output_dir / image)
        shutil.copyfile(CAPTURES / pair['key'], args.output_dir / original)
        with wave.open(str(args.output_dir / sample), 'wb') as wav:
            voice.synthesize_wav(proposed, wav)
        with wave.open(str(args.output_dir / sample)) as wav:
            audio = {'frames': wav.getnframes(), 'sample_rate': wav.getframerate(), 'channels': wav.getnchannels()}
            assert audio['frames'] > 0 and audio['sample_rate'] == 22050 and audio['channels'] == 1
        files = {name: sha(args.output_dir / name) for name in [image, original, sample]}
        rows.append(dict(pair, number=number, proposed_text=proposed, proposed_audio=sample,
                         review_status='pending', files_sha256=files, audio=audio))
        cards.append(f'''<article><h2>{number}. {escape(proposed)}</h2>
<img src="{image}" alt="Imagem original do recurso {stem}">
<p>Texto atual do corpus: <strong>{escape(pair['translatedText'])}</strong>.</p>
<p>Gravação antiga. A palavra pronunciada ainda precisa de ser confirmada:</p>
<audio controls preload="metadata" src="{original}"></audio>
<p>Proposta de texto e nova amostra: <strong>{escape(proposed)}</strong>.</p>
<audio controls preload="metadata" src="{sample}"></audio>
<p>Se a gravação antiga já disser a palavra correta, indica que deve ser conservada.</p></article>''')
    manifest = {'status': 'awaiting-teacher-review', 'sample_only': True, 'installed': False,
                'piper_version': '1.8.0', 'model_sha256': sha(args.model),
                'config_sha256': sha(Path(str(args.model) + '.json')), 'config_override': False,
                'scope': 'Two legacy vocabulary pairs; the 32 approved recordings are unchanged',
                'pairs': rows}
    (args.output_dir / 'manifest.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n')
    (args.output_dir / 'index.html').write_text('''<!doctype html><html lang="pt-PT"><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1"><title>Revisão de dois pares antigos</title>
<style>body{font:18px system-ui;max-width:850px;margin:2rem auto;padding:1rem;line-height:1.5;background:#f4f6fa;color:#172433}article{background:white;border:1px solid #bac7d5;border-radius:12px;padding:1.5rem;margin:2rem 0}img{width:220px;height:220px;object-fit:contain;float:right}audio{display:block;max-width:100%;margin-bottom:1rem}article:after{content:"";display:block;clear:both}</style>
<h1>Revisão de dois pares antigos</h1>
<p>Extrai o ZIP inteiro e abre este ficheiro no Edge ou Chrome. Funciona sem Internet.</p>
<p>Estes dois pares pertencem ao vocabulário antigo. As 32 gravações que já aprovaste mantêm a aprovação e não precisam de ser ouvidas novamente.</p>
<p>Compara cada imagem com o nome proposto e ouve os dois áudios. Confirma os nomes e a pronúncia, ou indica uma correção por número. As propostas ainda não estão instaladas no jogo.</p>
''' + ''.join(cards) + '''<p>Referências: <a href="https://dicionario.priberam.org/cervato">cervato</a> e <a href="https://dicionario.priberam.org/carra%C3%A7a">carraça</a>. Os links são opcionais; os áudios e as imagens estão incluídos no ZIP.</p><p>Origem, direitos e hashes: NOTICE.md e manifest.json.</p></html>''')
    (args.output_dir / 'NOTICE.md').write_text('''# Origem e direitos

Imagens originais Art4Apps, CC BY-SA 3.0, com derivados ampliados/suavizados
pelo GCompris. Crédito conservado de src/activities/lang/ActivityInfo.qml.
https://creativecommons.org/licenses/by-sa/3.0/
https://web.archive.org/web/20120908214126/http://www.art4apps.org/

Áudios antigos copiados sem alteração dos recursos Qt do pacote de vozes PT
GCompris. Os caminhos e hashes originais estão no manifesto; mantêm as licenças
de origem. Este pacote é material de revisão local, não uma publicação.

Novas amostras/textos/script: GPL-3.0-or-later, como este fork. Piper 1.8.0,
GPL-3.0; modelo pt_PT-tugão-medium com os mesmos hashes/configuração usados
nas amostras anteriores. O repositório distribuidor declara MIT; o model card
identifica conjunto de treino CC0. Modelo e motor não estão incluídos no ZIP.
https://github.com/OHF-Voice/piper1-gpl
https://huggingface.co/rhasspy/piper-voices/tree/main/pt/pt_PT/tug%C3%A3o/medium

As duas amostras são provisórias, sem aprovação docente. Não substituem
ficheiros do jogo nem alteram a aprovação das 32 gravações anteriores.
''')
    archive = args.output_dir / 'revisao-2-pares.zip'
    members = sorted(path for path in args.output_dir.iterdir() if path != archive)
    with zipfile.ZipFile(archive, 'x', compression=zipfile.ZIP_DEFLATED) as bundle:
        for path in members:
            bundle.write(path, path.name)
    with zipfile.ZipFile(archive) as bundle:
        assert len(bundle.namelist()) == 9 and bundle.testzip() is None
        for path in members:
            assert hashlib.sha256(bundle.read(path.name)).hexdigest() == sha(path)
    print(json.dumps({'archive': str(archive), 'sha256': sha(archive), 'pairs': len(rows), 'status': manifest['status']}))


if __name__ == '__main__':
    main()
