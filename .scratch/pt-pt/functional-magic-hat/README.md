# Chapéu mágico de adição e subtração

A tarefa 71 conclui os nove datasets e 41 níveis de cada jogo, `magic-hat-plus` e `magic-hat-minus`: 82 puzzles naturais completos. Em cada puzzle houve resposta vazia errada, Bonus negativo, reparação por cliques nas estrelas, Bonus positivo e passagem natural. São 30 puzzles com coeficientes e 12 com conjuntos de estrelas diferentes. Não há alterações de produção neste lote.

O Qt Linux usa `pt_PT`, perfis novos, rede Docker desativada e snapshot físico privado de 269 ficheiros. A origem foi o snapshot já imutável de comparações, copiado para `build/magic-origin`; não se copiou nem modificou o build principal. Os RCC de adição, subtração e core foram reconstruídos privadamente com as fontes Git `8ea79102f473c1a9ff8b2b8e2e7b7fa7bf9def47`.

## O que o solver observa

Na adição, os dois operandos são contados antes do clique no chapéu. Na subtração, o primeiro é contado antes do clique e o segundo apenas depois de as estrelas animadas saírem do chapéu e chegarem à segunda linha. As animações decorrem sem alterações de relógios ou velocidades.

A contagem percorre imagens SVG de estrelas preenchidas que estão prontas, visíveis, com opacidade efetiva mínima de 0,9 e geometria dentro do campo. Estrelas apagadas não contam. A opacidade dos antepassados exclui as estrelas móveis ainda invisíveis na fase inicial; a contagem da segunda linha na subtração inclui as imagens realmente reparentadas pela animação. Não se consultam `nbStarsOn`, operandos/soluções JavaScript, Client ou flags privadas de seleção para resolver.

Os coeficientes são extraídos dos textos desenhados, como `5x` ou `1000x`; sem texto, cada estrela vale uma unidade. A identidade visual do conjunto é obtida do SVG de cada forma. O oráculo calcula um vetor por conjunto, soma ou subtrai os operandos e procura uma representação de 0 a 10 estrelas em cada uma das três linhas. Quando o conjunto é comum, aceita qualquer soma ponderada correta; com conjuntos diferentes, conserva cada componente do vetor. Não chama o validador nem atribui estados, posições, operandos ou progresso.

O oráculo Python separado verifica a aritmética e a representação a partir do registo visível, incluindo os pesos de resposta 1/5/10 multiplicados por 1/10/100. A auditoria dos dados é independente do solver UI. Demonstra que as três linhas de 0–10 estrelas com pesos 1/5/10 representam todos os inteiros 0–160; os dados ponderados têm limite base 100, escalado pelo multiplicador. As respostas sem coeficientes têm limite de dez estrelas por linha/conjunto.

Uma configuração aleatória normal foi concluída por nível. A prova não esgota todas as combinações aleatórias possíveis. O tracer inicial de subtração conclui mais um puzzle e fica fora da contagem 82.

## Controlos e diagnóstico

Dois casos separados comprovam resposta parcial descartada por Gravar, nove entradas de dataset, exclusão/reabertura persistida do primeiro conjunto e reposição, contagem 41→39→41, navegação anterior/seguinte com volta circular, ajuda PT/Escape, entrada após a ajuda e menu. A interface das estrelas expõe cliques, sem teclado de resposta. Escape verifica o foco no diálogo de ajuda. Esperam-se 1800 ms quando os ícones da barra mudam, respeitando a animação normal de 1500 ms.

`help-vocabulary-diagnostic` conserva uma falha do harness: procurava “chapéu” dentro do manual, que usa “cartola”, um termo português válido. Foi corrigida apenas a asserção do teste. Esse recibo não aprova um percurso nem demonstra defeito do produto. As provas verdes posteriores conservam os seus casos exatos.

## Conclusão e identidades

Todos os seis processos Qt terminaram com código 0, sem timeout. Cinco provas verdes têm lançador 0; o diagnóstico tem lançador 1 por asserção esperada. Os seis estados `launcher-status.json` são emitidos pelo supervisor só depois de esperar pela conclusão do lançador, incluindo a limpeza, e ligam SHA-256 de recibo, caso e lançador.

Nos cinco percursos executados por `run.py`, `supervisor-exit.json` observa ainda o retorno do processo supervisor depois de `subprocess.run()` terminar e liga o hash do estado intermédio. `tool-outer-observations.json` regista separadamente os seis retornos efetivos observados em `write_stdin`, com sessão/chunk e hashes de recibo/caso. O estado nativo nunca é usado para inferir um retorno externo.

O auditor fixa um commit histórico com o índice e os bytes dos artefactos. Confere os 250 ficheiros de fonte, catálogo, launcher, supervisor e helper com blobs Git exatos; os mapas QResource conferem todos os ficheiros dos três RCC. O manifesto sela os 269 ficheiros transitivos. O auditor não abre caminhos absolutos antigos dos recibos nem depende do PO atual. Os testes copiam as provas para outra pasta e adulteram contagens, casos, catálogo/mapas, RCC, estados e retornos, recalculando selos, sem conseguir aprová-los. As ferramentas recusam Python `-O` explicitamente.

```sh
python3 tests/functional_magic_hat/audit.py
python3 tests/functional_magic_hat/audit.py --evidence '/copia/provas cartola' --repository /clone/GCompris-qt
python3 -m unittest discover -s tests/functional_magic_hat -p 'test_*.py'
```

Para um novo ensaio, usar saídas novas e o caminho completo de fonte devolvido pelo primeiro comando. Não substituir a prova histórica.

```sh
python3 tests/functional_magic_hat/phase.py --revision COMMIT
python3 tests/functional_magic_hat/prepare.py --origin-snapshot SNAPSHOT_IMUTAVEL --source-root FONTE_CONGELADA --output NOVO_SNAPSHOT
python3 tests/functional_magic_hat/run.py --source-root FONTE_CONGELADA --snapshot NOVO_SNAPSHOT --activity magic-hat-minus --output NOVA_SAIDA
python3 tests/functional_magic_hat/run.py --source-root FONTE_CONGELADA --snapshot NOVO_SNAPSHOT --activity magic-hat-plus --controls --output OUTRA_SAIDA
python3 tests/functional_magic_hat/capture.py --source-root FONTE_CONGELADA --snapshot NOVO_SNAPSHOT --output NOVAS_IDENTIDADES
```

Os processos nativos têm de terminar antes de indexar ou entregar o lote. Linhas de progresso não contam como recibos finais.

## Limites humanos

Os WAV de deslocação das estrelas, erro e bónus passaram em GStreamer para `fakesink`, com hashes originais preservados. O Qt correu muted e offscreen. Isso não prova audição, pronúncia ou reprodução física. Não foram geradas vozes, e a aprovação das 32 adições anteriores não se transfere para outros recursos.

Windows 10/11, dispositivos físicos, acessibilidade, perceção visual e revisão pedagógica/docente continuam pendentes. Todos os critérios globais permanecem pendentes.
