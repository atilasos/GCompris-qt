# Integrar os oito jogos CRJM no nosso fork do GCompris

Status: ready-for-agent
Type: task
Progress: claimed

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
