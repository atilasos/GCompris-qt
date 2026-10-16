# Provar bloqueio dos discos inferiores nas Torres de Hanói

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 49

## Âmbito

Resolver o P2 da revisão Spec49. Acrescentar um arrasto real negativo de um
disco inferior identificado pela posição vertical visível em cada motor.
Confirmar que o disco está bloqueado e que a pilha, posições e pais não mudam.
Preservar as quatro campanhas completas finais e os seus hashes; adicionar
dois casos curtos ao índice/auditor, sem repetir todos os nove níveis nem
alterar produção sem defeito reproduzido. Mesmos limites Windows/hardware.


## Answer

Dois casos Qt curtos passaram e foram acrescentados ao auditor/índice, agora
seis casos/34 artefactos. Os28 hashes das quatro provas anteriores continuam
iguais. Inferior escolhido pela ordem vertical, disabled enquanto coberto,
pai/posição conservados até exposição e arrasto positivo depois de exposto.
A MouseArea expandida redireciona gestos nessa região para o topo, pelo que a
pilha inteira não é imóvel. O revisor Spec49 confirmou este contrato. A hipótese
inicial mais restritiva fica como diagnóstico, sem alegação de bug de produção.
Sem alteração de produção ou repetição dos nove níveis completos. Evidência e
comandos em `.scratch/pt-pt/functional-hanoi/README.md`.
