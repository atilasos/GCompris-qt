# Respeitar o retorno do launcher nos testes decimais

Status: ready-for-agent
Progress: claimed
Type: task
Blocked by: 30

## Âmbito

Revisão Standards do lote35 encontrou P2 no runner30: combina resultado Qt
verde e contagem completa sem exigir retorno0 do launcher. Este escreve o
JSON antes da limpeza; uma falha posterior poderia ser falsamente aprovada.
Reproduzir com subprocess fixture que retorna erro e JSONverde; exigir ambos
retorno0 e resultadoQt/contagem válida. Cobrir também o caso de retorno0 com
JSONfalhado e o caminho verde. Um único implementador trata os achados da
revisão. Não induzir crashes nem alterar jogos.

Os20casos finais arquivados têm retorno0 do launcher e Qt e permanecem válidos.
O erro histórico fora do índice final está identificado e não foi aprovado.
