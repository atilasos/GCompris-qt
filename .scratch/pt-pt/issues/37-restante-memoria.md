# Validar as cinco variantes restantes de memória

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 21, 25, 29

## Âmbito

memory, memory-tux, memory-sound, memory-sound-tux e
memory-case-association-tux. Todos os datasets, níveis e modos expostos,
pares certos/errados, bloqueio, turnos/pontuação, Bonus e transições, incluindo
vitória/derrota contra Tux. Dados e identidades visuais/sonoras com referência
independente, sem usar matchCode nem atribuir correspondências/pontuação.
Nos sons, observar os recursos efetivamente reproduzidos e verificar igualdade
de bytes/rota, distinguindo isso de uma audição física ou revisão docente.

Ajuda PT, reinício, navegação/menu e recursos privados selados. Não encurtar
temporizadores nem simular turnos. Identificar seletores/gestos não cobertos
e critérios Windows/hardware/áudio físico/docente pendentes.

## Checkpoint: ajuda (parcial)

Duas correções PO comprovadas com ajuda Qt real: limite de duas cartas nas
variantes de imagens e concordância «os gémeos» nas variantes de sons.
Red em duas atividades; green nas cinco, com navegação/ajuda/Home.
Provas: `../functional-memory-rest/help-review.md`. A tarefa mantém-se claimed;
percursos completos e restantes critérios continuam pendentes.

## Answer

Verificação delimitada concluída: 25 casos Qt reais passaram, incluindo 43
percursos de níveis/modos, 292 pares do jogador +11 de Tux, 82 pares errados
e bloqueios, 43 Bonus bons e três derrotas forçadas com Bonus mau. Os dois
seletores de jogadores têm gravação real pela interface. Três testes de dados
e cinco controlos do auditor passam. As duas correções PO foram a única
alteração de produção (checkpoint anterior).

O auditor compara 115 recursos efetivamente carregados com os originais e os
296 ficheiros expostos nos sete RCC com a fonte. Todos os 30 sons distintos
atingiram reprodução/posição positiva; 18 das 26 vozes de letras foram sorteadas
e reproduzidas. As 26 rotas existem no RCC, sem declarar audição/pronúncia física.
Relatório e hashes: `../functional-memory-rest/README.md` e `index.json`.

A falha Escape inicial pertencia ao fixture que destruía o aviso sem fechar;
o fecho pelo evento real resolveu a regressão nas cinco atividades, sem mudar
a produção. Os resultados globais permanecem pending: Windows, dispositivos,
audição/pronúncia e revisão docente final não são aprovados por estes testes.
