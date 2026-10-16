# Retornos externos e âncoras históricas das provas60/62/63

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 60, 62, 63

## Aceitação

Corrigir os três P2 das revisões Standards60–63. Preservar os recibos
originais byte a byte e não repetir Qt. Arquivar observações reconstruídas
explicitamente identificadas dos retornos externos de calendários e dinheiro,
ligadas aos recibos/casos e fixadas em Git ou por hash imutável. Auditores e
indexadores devem rejeitar Qt verde com lançador falhado. Wrappers futuros
registam o retorno observado depois de esperar pelo subprocesso.

Fixar as raízes das três fases de fontes verticais fora do arquivo mutável;
rejeitar ataque que altera PO, manifestos, ligações, recibos e índice de forma
coerente. Testes CLI negativos e cópias de provas. Sem produção, build principal,
mapa, CSV ou push. Relatórios em /tmp/gcompris-review-standards61-62.md e
/tmp/gcompris-review-standards60-63-additional.md.


## Answer

Três P2 corrigidos. Observações forenses reais32 outcomes(14 calendários,
18 dinheiro) arquivadas separadamente e fixadas por hashes, ligadas a recibos
/casos sem os reescrever. Auditores/indexador exigem a conclusão externa e
recusam Qtverde/lançadorfalhado. Supervisor comum grava estado só após wait;
o runner de dinheiro passa por ele e calendários dispõe de CLI check-only.
As três raízes históricas de verticais são constantes do auditor, com lista
/bytes exatos; o ataque de reseal completo de PO/QML é rejeitado.

38 testes verdes, com negativos CLI, preservação do índice e cópias portáteis.
Todos os blobs originais dos três arquivos foram conferidos com Git9750a053a.
Provas/comandos/proveniência em `../proof-review65/README.md`. Sem Qt novo,
produção, build principal, mapa, CSV ou push; limites de aceitação inalterados.
