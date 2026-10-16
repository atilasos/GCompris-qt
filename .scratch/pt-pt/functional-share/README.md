# Partilhar doces — tarefa 74

Concluídas 146 perguntas primárias: os 15 níveis dos três datasets, em cada
um dos dois modos disponíveis (com/sem contadores). Os seis processos do
executor terminaram com retorno 0, observado pelo coordenador em
`full/summary.json`. Cada nível tem erro e reparação, Score e Bonus naturais:
30 níveis e 30 erros reparados. Os 25 modelos aleatórios foram exercitados uma
vez por modo, sem fixar o gerador; não se afirma exaustão de todos os sorteios.

O oráculo conta os SVG efetivamente criados nas caixas, esgota o fornecimento
até ao ícone atenuar e calcula divisão inteira e resto independentemente.
Arrasta crianças da barra, um doce da barra em cada pergunta e doces entre
caixas; os restantes doces são colocados com cliques reais. Confere os
contadores desenhados e a conservação da quantidade total. Não lê soluções,
Client, modelos, totais ocultos, expectedShare ou rest. Não escreve no
progresso, respostas, cronómetros ou gerador aleatório.

## Defeitos e pares idênticos

`portuguese-red` / `portuguese-green`: a instrução da Maria omitia que as
raparigas já tinham doces. A mesma omissão existia no dataset com resto.
Restaurou-se essa informação, a composição de outro grupo e corrigiram-se
concordâncias, palavras coladas, referência à Alice, singular e «partilhar».
O caso vermelho completa quatro perguntas e falha na instrução da quinta;
não constitui um nível completo. O verde conclui esse nível. Fontes Git:
`dfcd3d9ca77d548a93282ad5b6e893c5858aefb3` e
`ea1db0ab206fb7d6bec5d848de94084c880ecd1e`.

`drag-red` / `drag-green`: no modo sem contadores, arrastar um doce para a
segunda criança não o colocava na caixa. CandyWidget somava duas vezes o
deslocamento na conversão de coordenadas. A correção usa a origem do elemento,
como o ramo com contadores. Os casos são byte a byte iguais; o vermelho tem
retorno externo 1, o verde 0. Fonte corrigida:
`4382e3ecd23d99294e04fe5eeccfa374c6d2b5a7`.

## Controlos e recursos

Dois casos separados confirmam ajuda PT, Escape e foco pelo arrasto seguinte,
reinício de uma distribuição parcial, navegação após progresso, persistência
de modo e seleção ao reabrir a configuração, reposição dos três datasets,
botão de instrução, teclas sem função sem alteração e Ctrl+W para o menu.
A persistência demonstrada é na mesma execução; não se afirma reabertura
entre processos. Duas perguntas adicionais de controlo não contam nas 146.

`resources-ready` e `resources-effective` confirmam os quatro SVG como
Image.Ready e a criança/doce desenhados. A exportação Qt contém os 17 ficheiros
da atividade e dois WAV do core. `resources` documenta o RCC original do
snapshot; `effective` guarda o RCC privado realmente usado pelo segundo teste
de imagens, com a correção e a instrumentação exatas. O auditor confere as
fontes próprias de cada um. Os dois WAV de acerto/erro foram descodificados por
GStreamer com retorno 0 para fakesink: isto não demonstra audição ou pronúncia.
A atividade não declara voz de introdução ativa. Nenhuma nova gravação foi
aprovada. `resource-commands.json` regista apenas comandos realmente executados.

## Identidades e reprodução

Há 14 recibos nativos selecionados: seis campanhas completas, dois controlos,
dois de imagens e quatro membros dos pares vermelho/verde. Todos têm status
do supervisor gravado após wait; os dois vermelhos têm retorno externo 1,
os outros doze 0. O processo Qt dos vermelhos termina normalmente com 0,
mas a asserção falha; estas duas camadas estão separadas.

O snapshot privado contém 269 ficheiros físicos e foi selado antes das
campanhas. Cada árvore histórica é preparada uma vez antes do pool e publicada
atomicamente. Os manifestos de fonte são conferidos contra objetos Git
históricos, e o índice contra um commit imutável. Caminhos absolutos dos
recibos são observações históricas, não dependências do auditor. Os testes
incluem uma cópia sem acesso à worktree original, adulteração com hashes
recalculados e execução com Python -O.

```
python3 tests/functional_share/audit.py
python3 -O tests/functional_share/audit.py
python3 -m unittest discover -s tests/functional_share -v
```

Para novas campanhas, criar snapshot próprio com
`tools/native_qml_resources.py`, e usar `tests/functional_share/campaigns.py`
com `--revision`, `--snapshot` e `--output` novos. Recibos antigos não são
reescritos. A primeira tentativa de matriz, anterior à correção do arrasto,
e os ensaios de ajuste da espera de UI ficam no build privado, fora da
conclusão final. A espera usa os controlos visíveis habilitados após o erro.
Não foi necessária alteração de temporizadores de produção.

Âmbito: Linux offline com Qt real/software. Windows 10, dispositivos físicos,
audição e revisão docente continuam pendentes. Não se afirma cobertura de
todos os gestos possíveis, de todas as dimensões de janela ou dos 203 jogos.
