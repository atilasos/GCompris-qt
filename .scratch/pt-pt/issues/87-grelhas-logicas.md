# Concluir Sudoku e Calcudoku por regras independentes

Status: ready-for-agent
Progress: ready-for-review
Type: task
Blocked by: 02, 25

## Aceitação

Inventariar todos os conjuntos configuráveis, níveis e subníveis de `sudoku`
e `calcudoku`, distinguindo tabuleiros fixos e gerados. Completar em Qt Linux
um percurso por cada nível/conjunto oferecido e todos os tabuleiros finitos
fixos apresentados nesse percurso. Não prometer esgotar a geração aleatória.

Resolver usando apenas símbolos/números, posições e pistas desenhadas. Em
Sudoku usar unicidade de linhas, colunas e regiões efetivamente apresentadas;
não presumir caixas 3×3 nas grelhas pequenas. Em Calcudoku usar linhas/colunas,
limites das regiões, alvos e operadores visíveis. Resolver num módulo puro
independente, sem consultar grelhas de solução, campos ocultos, validação do
motor ou funções de vitória. Usar controlos reais para colocar e corrigir.

Cobrir erro/recuperação por nível, conclusão natural, continuação, ajuda PT,
Escape/foco, reinício parcial, menu e configuração/seleção de conjuntos.
Cada defeito exige o mesmo caso negativo/positivo antes/depois. Confirmar
português europeu em instruções e termos matemáticos. Não alterar conteúdos
corretos nem gravações aprovadas por conveniência dos testes.

Usar snapshot269 físico independente, fontes congeladas atomicamente antes
das campanhas e deployments únicos. Preservar RCC/QM efetivos e extrações,
fontes/PO/casos, geometria/pistas e ações, imagens e retornos reais do processo
Qt, supervisor e capturador após espera. Não substituir nem resselar provas
históricas para aceitar uma correção posterior.

Auditor puro portátil sem Git/Qt/checkout original, âncora externa literal,
recusa de vazio e adulteração coerente, testes normais e -O ou recusa explícita,
cópia física independente e proteção contra saída existente. Windows,
dispositivos, audição, revisão docente e estabilidade83 permanecem pendentes.

## Entrega 87

Review: ready-for-review

Implementação concluída; Progress permanece claimed até revisão e integração por merger separado. Inventário real: quatro conjuntos Sudoku (13 níveis, 68 grelhas fixas) e cinco Calcudoku (cinco níveis, 100 amostras geradas). 168 conclusões, 18 conflitos/reparações, navegação/configuração/reinício/ajuda/menu por entradas reais. Corrigido apenas o verbo da ajuda Sudoku, com caso exato red/green; a prova composta separa 168 grelhas baseline dos controlos/ajuda finais.

[Provas físicas e limites](../functional-grids/README.md). Auditor portátil `python3 tests/functional_grids/audit.py`; 19 testes passam, incluindo adulterações coerentes e recusa -O. Cápsula SHA-256 d5332fa4e421521e55a67e1e3da85790e64716fefd5055a5005a67865603a8e7. Todos os processos Qt, launchers e supervisores terminaram e os retornos externos observados foram registados separadamente. Geração não esgotada, Windows/dispositivos/audição/docente/estabilidade83 pendentes.

## Integração

Provas integradas para Standards e Spec independentes. `ready-for-review`
não representa resolução final ou aceitação global. Os 100 Calcudoku gerados
não representam todas as possibilidades aleatórias.

## Suplemento de revisão — menu após sucesso

A condição «após sucesso» foi pedida no mandato complementar de revisão; o ticket original dizia apenas menu. Não se demonstrou defeito no produto. Dois novos casos completaram naturalmente cinco grelhas Sudoku 3×3 e 20 Calcudoku 3×3, aguardaram Bonus/continuação e regressaram ao menu estável por controlo real. São 25 conclusões repetidas, sem ampliar a cobertura única. Todos os quatro retornos observados são 0 em ambos.

[Suplemento físico independente](../functional-grids-success/README.md), SHA literal cf4a74a7c18017e3522a5e5c28172442e342ddb79c2618b541dc976333d5c4be. Auditor `python3 tests/functional_grids_success/audit.py`, seis testes de cópia/adulteração/-O. Cápsula original e 19 recibos intactos. Sem alterações de produto ou novos âmbitos. Ready-for-review para recheck independente.
