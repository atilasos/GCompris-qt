# Frações em PT-PT no Qt nativo

Os quatro processos terminaram: os recibos do launcher e da aplicação têm
saída 0. `fractions_create` concluiu 18 níveis/78 perguntas e `fractions_find`
12 níveis/60 perguntas, com 138 respostas erradas rejeitadas e 30 Bonus
naturais. Dois percursos adicionais verificaram os controlos de cada jogo.
`index.json` resume as provas; `final/` conserva logs, recibos e 276 imagens
com as partes coloridas conferidas também pelos píxeis capturados.

Os 16 datasets originais incluem tartes e retângulos, frações próprias e
impróprias, simplificadas e não simplificadas, decimais com vírgula,
percentagens, limite de metade e seletores fixos/livres. O auditor racional
interpreta o texto visível ou conta as partes desenhadas. Confere as 78
perguntas fixas e as restrições das 60 perguntas aleatórias, sem consultar
numeradores de resposta internos. Estas 60 amostras não esgotam o espaço
aleatório. Os cliques reais selecionam/deselecionam segmentos ou usam os
seletores e OK. Erros, bloqueio durante feedback, Score, transições e Bonus
usam os tempos originais. Não se escreve progresso nem se chama a solução.

Os controlos passaram: reinício limpa uma resposta parcial, anterior/seguinte
com retorno entre extremos, desativação persistida do primeiro dataset
(18→16 e 12→10 níveis) e reposição, ajuda em PT, foco e entrada após fechar
ajuda, Home/Escape e regresso ao menu. Não há modalidades adicionais de
teclado expostas por estes jogos.

A única alteração de produção remove hifens indevidos de dez traduções de
nomes de frações: dois terços, dois quintos, três quartos e três quintos.
O mesmo `first-level.qml` falha antes e conclui cinco perguntas e Bonus
depois. `history/identity.json` liga o PO anterior ao commit 5953a4bce e o
verde a 8eeedc44a; os logs e imagens estão em `wording-red-final/` e
`wording-green/`. Os dados numéricos e o motor JavaScript não mudaram.
`msgfmt --check --check-format` passou. Revisão docente pendente.

## Identidades e reprodução

As campanhas executaram a cópia arquivada de 252 ficheiros Git do commit
`a32b458613048ed6190fcac8ff271533e0d468d8`, incluindo QML, recursos,
PO, launcher e casos. SHA-256 do manifesto de fontes:
`c6f7815a18fe2ba3938656f26133a4e2e6d17357571d26d5298396132f7890e9`.
O snapshot privado contém 269 ficheiros, sem ligação a worktrees antigas.
Cada recibo liga todos os recursos, binário e os dois overlays privados
(QM PT e RCC de frações) às suas identidades. O manifesto original do
snapshot permanece arquivado; os seus ficheiros binários grandes ficam no
build privado e não são necessários para auditar os recibos existentes.

Auditar uma cópia desta pasta, sem Git nem catálogo corrente:

```sh
python3 -B auditor/audit.py --evidence .
```

Requer Python com Pillow, Node e `lconvert` Qt 6. A auditoria usa as fontes
arquivadas, os racionais, a geometria e os píxeis. Sete testes passaram:
dois do oráculo e cinco de cópia/adulteração material (atividade trocada,
resposta alterada, imagem substituída e fonte mais manifesto reescritos).
`audit-tests.txt` conserva o resultado. Para os repetir na árvore do projeto:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests/functional_fractions -p 'test_*.py'
```

Novo replay, com um snapshot privado disponível e destino novo:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 tests/functional_fractions/run.py --archive .scratch/pt-pt/functional-fractions/archive --snapshot build/fractions-snapshot --output build/fractions-replay
```

O arquivo é deliberadamente fixo nesta identidade histórica. Novas provas
exigem nova identidade e revisão; `seal.py` publica provas já validadas.
A verificação estrita detetou caches Python geradas junto do launcher
arquivado; foram removidas após os processos terminarem. Os 252 ficheiros
originais mantiveram os mesmos hashes. O runner agora impede a criação de
bytecode nos subprocessos, sem mudar os casos Qt já executados.

## Limites

Qt 6.10/QtGraphs, software e perfil novo, rede Docker desativada. O ramo antigo
QtCharts não foi exercitado. Não se afirma reprodução ou audição de áudio,
teclado/rato/toque físicos, compatibilidade Windows nem aprovação pedagógica.
Essas aceitações e os critérios globais continuam pendentes nas tarefas
próprias. Os recibos provam os percursos Linux descritos.
