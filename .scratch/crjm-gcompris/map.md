# Integração CRJM no nosso fork

## Documentos

- [Especificação](spec.md).
- [Tarefa principal 01](issues/01-integrar-jogos-crjm.md), preservada. A execução usa os tickets 02 a 18.
- [Análise de viabilidade](analise.md).
- [Requisitos técnicos e comparação com o catálogo](requisitos-gcompris.md).

## Decisões

- Integrar os oito jogos no nosso fork, sem submissão upstream.
- Começar pelo piloto de Dominório, tickets 02 e 03. Depois, seguir a ordem recomendada dos jogos sem criar dependências entre jogos independentes.
- Usar QML e JavaScript, modos locais e componentes GCompris existentes.
- Testar a atividade nativa completa. Confirmação expressa do utilizador em 2026-10-17.
- Usar testes e posições CRJM como referência para os casos especiais.
- Manter a plataforma web e os seus serviços fora da integração.
- Verificar permissões dos componentes antes de distribuir o fork.

## Estado

A investigação e a especificação estão concluídas. A implementação decorre na branch
`integration/crjm-games`, a partir de `620fde9e5`.
Os 17 tickets de execução estão publicados como `ready-for-agent`. Os tickets 02,
03, 04, 05, 06, 08 e 09 estão resolvidos e integrados; 07 e 10 estão assumidos.
A fronteira disponível é 12, 14 e 16; a primeira tarefa é 12. A tarefa 01 agrega o âmbito e não deve
ser assumida como uma implementação concorrente das subtarefas. A tarefa principal está assumida pelo coordenador. A implementação e a integração
são verificadas antes de resolver cada ticket.


## Tickets aprovados

| Ticket | Entrega | Bloqueado por | Progresso |
| --- | --- | --- | --- |
| [02](issues/02-dominorio-duas-pessoas.md) | Dominório para duas pessoas | Nenhum | resolved |
| [03](issues/03-dominorio-tux-aprendizagem.md) | Dominório contra Tux e aprendizagem guiada | 02 | resolved |
| [04](issues/04-gatos-caes-duas-pessoas.md) | Gatos & Cães para duas pessoas | 03 | resolved |
| [05](issues/05-gatos-caes-tux-aprendizagem.md) | Gatos & Cães contra Tux e aprendizagem guiada | 04 | resolved |
| [06](issues/06-faisca-duas-pessoas.md) | Faísca para duas pessoas | 03 | resolved |
| [07](issues/07-faisca-tux-aprendizagem.md) | Faísca contra Tux e aprendizagem guiada | 06 | claimed |
| [08](issues/08-quelhas-duas-pessoas.md) | Quelhas para duas pessoas | 03 | resolved |
| [09](issues/09-quelhas-tux-aprendizagem.md) | Quelhas contra Tux e aprendizagem guiada | 08 | resolved |
| [10](issues/10-atari-go-duas-pessoas.md) | Atari Go para duas pessoas | 03 | claimed |
| [11](issues/11-atari-go-tux-aprendizagem.md) | Atari Go contra Tux e aprendizagem guiada | 10 | open |
| [12](issues/12-produto-duas-pessoas.md) | Produto para duas pessoas | 03 | claimed |
| [13](issues/13-produto-tux-aprendizagem.md) | Produto contra Tux e aprendizagem guiada | 12 | open |
| [14](issues/14-y-duas-pessoas.md) | Y para duas pessoas | 03 | open |
| [15](issues/15-y-tux-aprendizagem.md) | Y contra Tux e aprendizagem guiada | 14 | open |
| [16](issues/16-nex-duas-pessoas.md) | Nex para duas pessoas | 03 | open |
| [17](issues/17-nex-tux-aprendizagem.md) | Nex contra Tux e aprendizagem guiada | 16 | open |
| [18](issues/18-validar-build-oito-jogos.md) | Validar os oito jogos numa build do fork | 05, 07, 09, 11, 13, 15, 17 | open |

Os números de bloqueio são condições de início, não a ordem preferida de execução.
O ticket 18 depende transitivamente de 02 e 03 e das entregas para duas pessoas
através dos tickets finais de cada jogo. Não acrescentar esses bloqueios redundantes.

Para validar a estrutura do tracker, executar `python3 .scratch/crjm-gcompris/verify-tickets.py`.

Decisão da entrega 02: atividade original nativa com teste pelo menu e transcript
CRJM completo. Evidência em `evidence/02-dominorio/green`; runner suporta
`--from-menu` e `--extra-activity` apenas no runtime privado. Ticket 03 desbloqueado.

Decisão da entrega03: piloto nativo completo com worker ES limitado, regras
partilhadas, três níveis, exercício e revisão por mobilidade. Evidência em
`evidence/03-dominorio/README.md`. Orçamentos piloto: resposta2s, heartbeat250ms,
ajuda1.5s. Host desktop real, sem dispositivo modesto disponível; repetir medição
nesse alvo antes da distribuição. Fronteira04/06/08/10/12/14/16 desbloqueada.

Decisão da entrega 04: atividade independente com abertura especial, vizinhança e
partida completa pelo menu. Evidência em `evidence/04-gatos-caes/README.md`;
aceitação nativa com 2 passes, 0 falhas e 0 erros QML. Ticket 05 desbloqueado.

Decisão da entrega 08: Quelhas nativo com segmentos, troca inicial e resultado
misère, verificado pelo menu após sincronização com a integração. Evidência em
`evidence/08-quelhas/README.md`; 2 passes, 0 falhas e 0 erros QML. Ticket 09 desbloqueado.

Decisão da entrega 06: Faísca nativo com direção, distância, previsão e reservas,
partida completa e botões acessíveis por Tab. Evidência em `evidence/06-faisca/README.md`;
2 passes, 0 falhas e 0 erros QML. Ticket 07 desbloqueado.

Decisão da entrega 05: Gatos & Cães com adversário local em worker, três níveis,
introdução, exercício, pistas e revisão. Evidência em `evidence/05-gatos-caes/README.md`;
Tux e regressão de duas pessoas com 2 passes, 0 falhas e 0 erros QML cada.

Decisão da entrega 09: Quelhas com Tux local, troca inicial real, três níveis,
exercício misère, pistas e revisão. Evidência em `evidence/09-quelhas/README.md`;
Tux e regressão 08 com 2 passes, 0 falhas e 0 erros QML cada. Heartbeat máximo
observado de 247 ms no host partilhado; não constitui medição em hardware físico modesto.
