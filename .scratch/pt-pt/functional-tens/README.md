# Conclusão funcional dos quatro jogos de complemento de dez

Os oito casos finais passaram com recursos privados selados e o core da tarefa
33. Foram concluídos 90 puzzles completos, com 253 linhas matemáticas auditadas
independentemente em Python. Foram rejeitadas 88 disposições ou respostas erradas.

| Jogo | Níveis por modo | Puzzles | Linhas | Negativos rejeitados |
| --- | --- | --- | --- | --- |
| tens_complement_find | 8 | 40 | 120 | 38 |
| tens_complement_swap | 12 | 12 | 45 | 12 |
| tens_complement_calculate | 4 × 2 teclados | 8 | 28 | 8 |
| tens_complement_use | 6 | 30 | 60 | 30 |

Todos os 12 datasets expostos estavam selecionados nos perfis novos. Find/use
concluem as cinco rondas de cada nível antes de esperar o Bonus e a transição.
Swap/calculate resolvem todas as linhas de cada tabuleiro antes de validar.
Calculate percorre os quatro níveis com teclado físico simulado e depois com
NumPad visual, incluindo Backspace, OK e Enter. Os três jogos de cartões expõem
cliques para seleção/troca; não têm um gesto de arrasto.

Os negativos de find são permutações das respostas e ocorreram em todos os
níveis, com contagens 5, 4, 5, 4, 5, 5, 5 e 5. Duas rondas ficaram só com o
positivo porque a troca considerada não alterava a validade. Isto não afirma
que todos os erros possíveis foram enumerados. Use rejeitou um negativo em
cada ronda, e swap/calculate em cada tabuleiro ou modo executado.

Os casos leem os valores do tabuleiro e resolvem por aritmética/busca separada
do código do jogo. Só entregam respostas com cliques e teclas Qt; não atribuem
respostas, estados de validação, pontuação ou fases. O auditor Python verifica
somas, pares de dez, conservação dos cartões e decomposição da parcela original.
Três controlos negativos do auditor passaram, rejeitando somas, pares e
substituição de cartões mesmo perante um resultado de conclusão.

Os quatro casos de controlos passaram anterior/próximo, reinício pelo botão
Gravar após uma seleção ou entrada parcial, abertura/fecho da ajuda PT e regresso real ao
menu. As transições do StackView são aguardadas pelo estado busy. Os ensaios
iniciais do próprio teste foram ajustados para esperar o layout dos novos
delegates e o fim dessas transições, sem alterações ao código dos jogos.

`summary.json` indexa as oito execuções, resultados e hashes. `final/` conserva
logs completos, JSON, auditorias e capturas. Todos terminaram com código 0,
sem timeout ou erros QML, com UID/GID 1000:1000 e deployments removidos normalmente.
O manifesto do snapshot é comum a todos os casos. `core-build.json` regista a
preparação do core atual numa cópia privada a partir do core.qrc já existente.
O build principal foi usado apenas como origem de cópia e leitura do QRC.

Comandos reproduzíveis e critérios em `tests/functional_tens/README.md`.
Os datasets geram valores aleatórios, pelo que esta prova cobre os níveis e
modos com os sorteios observados. Subconjuntos de datasets, Windows, hardware,
audição física e revisão linguística/pedagógica docente permanecem separados.
Não foram executados testes antigos de indução de falhas nem alterados mapa/CSV.
