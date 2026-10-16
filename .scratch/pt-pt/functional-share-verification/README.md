# Verificação final da tarefa 74

`tests.log`: 14 testes Python passaram. Incluem o oráculo, as fronteiras CLI,
três regressões de preparação concorrente/interrompida/corrompida, o auditor
sobre uma cópia, quatro ataques de adulteração com hashes recalculados em
Python normal e -O, cópia portátil num contentor sem os caminhos originais, e
um subprocesso Python de fixture: JSON verde/retorno1 rejeitado, JSON
falhado/retorno0 rejeitado, JSON verde/retorno0 aceite. A fixture não é uma
execução Qt e não conta como prova nativa.

`audit.json` e `audit-optimized.json`: 146 perguntas, 30 níveis nos dois modos,
30 erros reparados, 47 perguntas com resto e 544 arrastos de redistribuição,
além dos arrastos de crianças e do primeiro doce. Os 14 recibos e os
manifestos mantêm os bytes do commit imutável de prova
`ec31c9fb9` (comparação em `preserved.json`).

Nenhum processo ficou pendente. Windows, equipamento, áudio audível e revisão
docente continuam por validar.
