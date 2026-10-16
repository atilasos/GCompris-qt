# Aprender algarismos, adições e subtrações

Tarefa 66 concluída no âmbito Linux descrito. Os 11 processos terminaram,
com saídas do supervisor, launcher e aplicação iguais a 0. Há 17 níveis
originais e 112 perguntas fixas. Os nove níveis de algarismos passaram nas
três representações, cada uma com 54 perguntas. Adições passaram três níveis
e 19 perguntas; subtrações cinco níveis e 39 perguntas. Total: 35 conclusões
de nível, 220 respostas certas, 220 erradas rejeitadas e 35 Bonus naturais.
Não foi necessária nenhuma alteração de produção.

A resposta vem do algarismo ou da expressão realmente visível. Nos pontos,
contam-se os círculos do SVG carregado; nos dedos, uma tabela de exemplos
visuais liga os bytes da imagem ao número de dedos levantados. A folha
`hands-contact.png` foi conferida pelo agente: punho fechado, polegar,
polegar/indicador e assim sucessivamente; depois uma mão com cinco dedos
mais os dedos levantados da segunda. Isto não é aprovação docente.

O snapshot é independente, com 269 ficheiros. Os 278 ficheiros de fontes,
catálogo, casos, launcher e supervisor ficam em `archive/`, do commit
f7d88df532b778b2a54826abbec0f13f79b1f40b. Não há dependência de worktrees
antigas ou do catálogo corrente para auditar as provas.

O utilitário QtCore `resource-exporter.cpp` lê 33 recursos do RCC original:
20 SVG, fundo, dois WAV e dez vozes PT dos algarismos. Os SVG/fundo/efeitos
são comparados com os bytes Git arquivados. Os 12 WAV/OGG foram integralmente
descodificados com libsndfile, com contagem de frames e formatos conservados.
Não se afirma audição ou reprodução em equipamento físico. As vozes dos
algarismos são recursos existentes, distintos dos 32 clips novos aprovados.

Windows, dispositivos físicos, áudio e revisão docente continuam pendentes.

## Entradas e controlos

Os 220 screenshots de resposta confirmam também os píxeis dos círculos
selecionados. Cada pergunta usa cliques reais, erro com quantidade diferente,
bloqueio de input durante feedback, preenchimento correto e OK ou Enter.
Cada nível inclui seleção e desseleção por Espaço. Não se consulta resposta
oculta, chama solução, escreve progresso ou encurta Score/Bonus/animações.
As permutações aleatórias não foram esgotadas, mas todas as perguntas fixas
foram resolvidas exatamente uma vez em cada campanha.

Três casos de teclado conferem uma posição por seta, seleção/desseleção e
retorno nas extremidades. Três casos de controlos verificam reinício de
resposta parcial, anterior/seguinte com retorno, ajuda PT, foco e input após
fechar ajuda e menu por Home/Escape. Desativar o primeiro dataset reduz a
contagem pública 9→8, 3→2 e 5→4; reabrir conserva a escolha e permite repor
todos. As representações são escolhidas por cliques no menu e conservadas
nas definições guardadas. O interruptor de vozes é guardado, reaberto e
reposto no caso dos algarismos.

## Auditoria e reprodução

O SHA-256 do manifesto de fontes é
`4bf989a00e0c00bf10d3fcd82fd5923cb85ac98ca2e5e66f90a9f4a82fff9ed4`.
`index.json` resume as contagens e `lock.json` sela 600 ficheiros. Cada
`launcher-status.json` é escrito depois de esperar pelo launcher e liga o
seu código de saída ao SHA-256 do recibo nativo. A auditoria exige os 11
recibos e conserva separadamente os códigos do supervisor e da aplicação.
Os 269 recursos runtime são conferidos contra o manifesto original, com
exceções explícitas apenas para o RCC de teste e o QM PT privado.

Auditar uma cópia desta pasta, sem a árvore Git original:

```sh
python3 -B auditor/audit.py --evidence .
```

Requer Python com Pillow, Node e `lconvert` Qt 6. Não segue os caminhos
históricos absolutos dos recibos. O manifesto de fontes tem um hash fixo no
auditor; recalcular manifestos de uma fonte alterada não é aceite. O mesmo
se aplica ao inventário dos recursos exportados.

Oito testes passaram, dois de exemplos aritméticos e seis de provas:
cópia independente, resposta errada, saída externa não zero, supervisor
alterado com manifesto recalculado, percurso vazio e píxel de resposta
alterado. Os hashes dos recibos e respetivos status são recalculados nos
ataques relevantes, para testar os contratos e não apenas o selo externo.
Resultado conservado em `audit-tests.txt`.

```sh
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests/functional_learning -p 'test_*.py'
PYTHONDONTWRITEBYTECODE=1 python3 tests/functional_learning/run.py --archive .scratch/pt-pt/functional-learning/archive --snapshot build/learning-final-snapshot --output build/learning-replay
```

O replay exige o snapshot privado disponível e um destino novo. Os binários
grandes do snapshot não são necessários para auditar as provas já arquivadas.
`prepare.py` prepara uma cópia privada; nunca deve receber um build partilhado
ou snapshot em uso. `seal.py` publica apenas provas já verificadas. A identidade
histórica está deliberadamente fixada para este lote.

## Limites

Qt 6.10, software, janela 800×800, perfis novos e rede Docker desativada.
Os recibos de jogo arrancam mudos. A descodificação dos dez clips existentes
e dos dois efeitos não prova audição, pronúncia ou saída por altifalantes.
A repetição sonora por Tab e pelo botão de voz não é certificada por estes
recibos mudos. A persistência do interruptor de vozes foi verificada; não há
uma segunda campanha completa de cada representação com esse interruptor
inativo. Windows 10, rato/teclado/toque físicos, outras geometrias de janela,
áudio e revisão docente permanecem pendentes. A matriz global mantém a
decisão de aceitação.
