# Respeitar o retorno do launcher nos testes decimais

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 30

## Âmbito

Revisão Standards do lote35 encontrou P2 no runner30: combina resultado Qt
verde e contagem completa sem exigir retorno 0 do launcher. Este escreve o
JSON antes da limpeza; uma falha posterior poderia ser falsamente aprovada.
Reproduzir com subprocess fixture que retorna erro e JSON verde; exigir ambos
retorno 0 e resultadoQt/contagem válida. Cobrir também o caso de retorno 0 com
JSON falhado e o caminho verde. Um único implementador trata os achados da
revisão. Não induzir crashes nem alterar jogos.

Os 20casos finais arquivados têm retorno 0 do launcher e Qt e permanecem válidos.
O erro histórico fora do índice final está identificado e não foi aprovado.


## Answer

Reproduzido por CLI real e launcher subprocess fixture normal: antes,
launcher 1+JSON verde produzia sucesso 0. Correção mínima exige retorno 0 além
de JSON/contagem válidos. Depois, os três percursos de aceitação/rejeição
passam; sete testes locais verdes incluindo o auditor anterior.

Provas em `.scratch/pt-pt/decimal-runner-boundary/README.md`, red/green.log
e historical-proof-audit.json. Os 20 resultados finais30 mantêm launcher 0,
Qt 0 e hashes originais. Sem repetição dos 316 puzzles nem alteração de jogos.
