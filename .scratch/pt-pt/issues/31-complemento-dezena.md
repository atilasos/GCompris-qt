# Validar os quatro jogos de complemento da dezena

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 02, 25, 28

## Âmbito

tens_complement_find, tens_complement_swap, tens_complement_calculate e
tens_complement_use. Todos os níveis, datasets e modos expostos: puzzles
completos por cliques/arrastos/teclas Qt reais, referência matemática independente,
respostas certas/erradas, fases de calculadora, Bonus e transições. Navegação,
ajuda PT, reinício e menu. Não atribuir estado para simular resolução.

A tarefa28 só verifica entrada em fases preparadas, não puzzles completos.
Recursos privados selados25, perfis novos, evidência/hash e comandos repetíveis.
Windows, audição, hardware e professor permanecem critérios separados.

## Answer

Os quatro jogos foram concluídos com cliques e teclas Qt reais em todos os
níveis e datasets expostos. Calculate passou também os dois modos de teclado:
90 puzzles, 253 linhas verificadas por auditor matemático Python independente,
88 negativos rejeitados, Bonus e transições naturais. Os quatro casos de
controlos passaram ajuda PT, anterior/próximo, reinício com seleção ou entrada parcial
pelo diálogo de datasets e regresso ao menu. Não foram preparados estados finais
nem atribuídas respostas ou pontuação pelo teste. Não houve alteração de produção.

O core33 foi reconstruído só numa cópia privada, selada num snapshot novo.
As oito execuções finais passaram sem rede, sem erros QML e sem timeout,
com dono local e limpeza normal. Três controlos negativos do auditor passaram.

Evidência: `../functional-tens/README.md` e `../functional-tens/summary.json`.
Reprodução: `tests/functional_tens/README.md`. Limites de sorteios, subconjuntos
de datasets, Windows, hardware, audição e revisão docente estão documentados.
Mapa e CSV global não foram alterados.
