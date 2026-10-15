# Validar decimais e quantidades por interação

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 02, 25, 28

## Âmbito

learn_decimals, learn_decimals_additions, learn_decimals_subtractions e
learn_quantities. Todos os datasets, níveis e modos expostos, com quantidades
e operações verificadas por referência independente. Completar os puzzles
por eventos Qt reais, incluindo arrastar/clicar quando necessário, sem preparar
a fase final por atribuição de estado. Respostas certas/erradas, vírgula PT,
transições, pontuação, navegação, ajuda, reinício e menu.

A tarefa28 só demonstrou a entrada nas fases preparadas e não fecha este lote.
Recursos selados25, perfis privados, comandos/hashes e limites explícitos.
Windows, audição, hardware e professor continuam critérios separados.


## Answer

Para revisão do agente:16 campanhas nativas offline verdes,316 puzzles
concluídos por arrastar/clicar/teclar, cobrindo15 datasets e79 subníveis nas
duas orientações e nos dois estados do teclado virtual. Oráculo independente
sobre perguntas PT visíveis, rejeições, vírgula, pontuação e transições naturais.
Quatro casos offline verdes cobrem configuração/gravação/reinício, níveis,
ajuda PT e menu. Quatro testes do auditor Python passaram.

Provas e limites: `.scratch/pt-pt/functional-decimals/README.md` e
`index.json`; hashes em cada resultado. Core33 recompilado só em snapshot
privado. Sem mudança de produção: o corte da barra era a animação de entrada
1500ms, demonstrada por timeline; o ensaio estável usa o centro dos botões.
Cada subnível gera uma amostra, não todos os valores possíveis. Windows,
audição, hardware e aceitação docente permanecem separados.
