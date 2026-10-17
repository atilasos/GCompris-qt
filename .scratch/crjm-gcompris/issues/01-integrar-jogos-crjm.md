# Integrar os oito jogos CRJM no nosso fork do GCompris

Status: ready-for-agent
Type: task
Progress: resolved

## Scope

Implementar a [especificação](../spec.md) em entregas jogáveis, começando por
Dominório. Prosseguir por Gatos & Cães, Faísca, Quelhas, Atari Go, Produto,
Y e Nex. Concluir o piloto não resolve esta tarefa inteira.

## Acceptance criteria

- Os oito jogos são atividades nativas acessíveis no menu do fork.
- Cada jogo funciona sem rede, com duas pessoas ou contra Tux.
- As partidas completas preservam as regras CRJM e distinguem exercícios didáticos.
- Ajuda, pistas graduais, introdução e revisão estão disponíveis em PT-PT.
- Os testes exercitam a atividade real e usam os casos CRJM como referência.
- Cada entrega regista validação funcional, recursos, atribuições e limitações.
- Os componentes reutilizados têm permissões compatíveis antes da distribuição.

## Comments

2026-10-17: Especificação sintetizada da análise e da confirmação do utilizador.
O destino é o nosso fork. A aceitação upstream não faz parte da tarefa.
O utilizador confirmou testes centrados na atividade nativa completa.

Implementação iniciada na branch `integration/crjm-games`. O coordenador acompanha a tarefa principal e os agentes assumem as subtarefas desbloqueadas.


## Answer

Integração concluída na branch `integration/crjm-games`: Dominório, Gatos & Cães,
Faísca, Quelhas, Atari Go, Produto, Y e Nex. Os tickets 02–18 estão resolvidos.
Cada atividade abre pelo menu, funciona sem rede com duas pessoas ou Tux,
preserva as regras de referência e inclui ajuda PT-PT, exercícios, pistas e revisão.

A [build completa](../evidence/18-build/README.md) passou 18 percursos nativos
com 1 CPU e 512 MiB, zero falhas, erros QML ou OOM. A
[revisão final](../final-review.md) registou zero violações documentadas e zero
desvios funcionais confirmados; as três observações de manutenção foram
corrigidas e os quatro percursos afetados voltaram a passar.

Artefacto local: `build/crjm-complete/run-crjm.sh`. Os manifestos finais,
proveniência e comandos reproduzíveis acompanham a evidência. O CRJM original
foi preservado. Não houve publicação nem distribuição; validação em hardware
escolar e ecrãs táteis físicos, som físico e observação com crianças ficam
explicitamente pendentes.
