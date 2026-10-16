Recheck Standards dos três P2, intervalo fixo `371d620...827485564f13d74ea54f077ea0f838b8e173b5b2`, incluindo `4b1277c11` e supervisor `dd5a27b9b`.

Os três P2 ficam fechados. Sem novos achados neste âmbito.

Calendários62: `audit.py` exige as observações retrospetivas fixadas por SHA e liga os 14 resultados aos bytes exatos dos recibos e casos. Confirmei os hashes dos eventos de conclusão nos rollouts efetivamente retidos: dez lançadores0 e quatro negativos esperados1. A proveniência distingue reconstrução posterior de sidecar contemporâneo e distingue o retorno do coordenador dos retornos individuais após wait. O negativo Qtverde/lançadorfalhado é rejeitado; a CLI check-only não reescreve o índice.

Dinheiro60: `completion.py` exige as 18 observações fixadas, com ligação ao recibo/caso; conferi os hashes dos eventos reais de conclusão, quinze retornos0 e três negativos esperados1. `index.py` verifica a conclusão antes de escrever; a regressão demonstra que um retorno externo errado deixa o índice anterior intacto. Para novas execuções, o runner usa o supervisor comum, que espera o subprocesso e só depois grava o retorno externo ligado aos hashes. A reconstrução histórica não é apresentada como nova execução.

Verticais63: os três hashes constantes de manifesto fixam baseline/green/complete fora do arquivo mutável. O auditor exige listas exatas, bytes e ausência de symlinks. O ataque anterior, agora abrangendo PO e QML com manifesto, bindings, recibos e índice coerentemente recalculados, é rejeitado. A cópia portátil continua válida sem Git ou worktree antiga.

Passaram 38 testes: 13 calendários, 14 dinheiro, nove verticais e dois supervisor. Os três auditores passaram sem escrita. Conferi independentemente todos os 1795 blobs originais contra Git9750a053a, incluindo 97 recibos e os índices originais: nenhuma alteração. As contagens funcionais e os limites anteriores mantêm-se; não houve Qt, nova campanha nem aumento de cobertura. `dd5a27b9b` está integrado, removendo também a dependência pendente assinalada no relatório64.
