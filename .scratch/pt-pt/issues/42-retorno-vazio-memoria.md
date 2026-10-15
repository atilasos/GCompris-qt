# Rejeitar seleções sem casos no runner de memória

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 37

## Âmbito

Corrigir o achado P2 da revisão Standards37: combinações como memory/audio_probe
e memory-tux/configuration não podem terminar com sucesso e zero casos.
Construir a seleção antes de preparar recursos, rejeitar seleções vazias e
exigir resultados não vazios para declarar sucesso. Regressão pela CLI real.
Preservar os 25 recibos Qt existentes, sem repetir percursos longos.

## Answer

Seleção validada antes da preparação e sucesso condicionado a resultados não
vazios. Duas regressões pela CLI real passam; a primeira reproduziu código0
e cases0 antes da correção. Um caso compatível passou no Qt offline original.
Os 343 hashes/25 recibos da tarefa37 foram verificados sem alterações.
Provas: `../memory-runner-selection/README.md`. Não altera aceitação global.
