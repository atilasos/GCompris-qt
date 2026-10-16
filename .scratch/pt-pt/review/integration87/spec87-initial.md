# Revisão Spec independente — tarefa 87

Intervalo fixo `62bbef03fc773f67c6fde234ce700414790ea2e7...08e730b27f099b7b55af58133da67dcb57b46940`; commits e diff revistos. Sem Qt/build/push ou alterações de capturas.

**P2 — Menu após sucesso pedido nesta revisão não demonstrado; confiança alta.** Ticket87:22–23 pede «conclusão natural, continuação […] menu»; spec35 exige «Cada conclusão é sustentada por evidência». O ticket não contém literalmente «menu após sucesso», mas esse controlo foi explicitamente solicitado no mandato desta revisão. `tests/functional_grids/controls.qml` termina após inserir uma peça (`focusMove`) e abrir o menu; não conclui uma grelha/nível nesse caso. `gameplay.qml` verifica todas as conclusões/Bonus e termina no wrap, sem executar o menu. O auditor aceita `e['menu']` apenas nos controlos parciais. Assim, não é possível confirmar o percurso adicional pedido.

Remédio: suplemento independente que conclua naturalmente um nível de cada atividade, aguarde Bonus/continuação e regresse ao menu real, preservando screenshots, casos, recursos e retornos físicos; exigir essas observações no auditor. Manter a cápsula histórica e as168 conclusões intactas. Trata-se de cobertura ausente, não de defeito demonstrado no produto nem de invalidação das partidas concluídas.

Restante âmbito examinado é coerente. O solver usa unicamente símbolos/paleta, células, regiões desenhadas e paredes/rótulos de gaiolas, com regras independentes de Latin/aritmética. Não impõe caixas3×3 nas grelhas pequenas nem lê campos de solução. O parser estático verifica inventário/multiconjunto separadamente da resolução.

O auditor confirmou quatro conjuntos Sudoku/68 fixos/13 níveis, cinco Calcudoku/100 gerados/cinco níveis,18 conflitos reparados,2128 colocações e19 recibos. A geração é explicitamente amostrada. Configuração combinada persistida, dimensões/fronteiras, navegação/extremos, pista fixa imutável, remoção/recolocação, reinício parcial e ajuda/Escape/foco estão cobertos.

Só muda o verbo da ajuda Sudoku, com par exato vermelho/verde. A composição168 baseline/controlos finais é honesta e não altera regras ou áudio; sem scope creep. Dezanove RCC/QM,863 extrações, fontes/instrumentação/retornos separados têm cadeia física e âncora literal.

Comandos observados: auditor puro e19 testes passaram; `-O` é recusado explicitamente. Cópia física/adulteração coerente/vazio/saída existente estão exercitados. Linux, runtime selecionado, hardware, audição, Windows, revisão docente e estabilidade83 mantêm limites explícitos.
