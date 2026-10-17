# 02: Dominório para duas pessoas

Status: ready-for-agent
Type: task
Progress: open
Blocked by: None (can start immediately)
Parent: 01, Integrar os oito jogos CRJM no nosso fork do GCompris

**What to build:** O aluno abre Dominório pelo menu e joga uma partida completa com outra pessoa no mesmo dispositivo, com tabuleiro 8×8, colocação de dominós, turnos, vitória, ajuda PT-PT e reinício.

## Acceptance criteria

- [ ] Cada dominó ocupa duas casas vazias adjacentes na orientação do participante. A seleção mostra as duas casas antes da colocação.
- [ ] Vence quem deixa o participante seguinte sem jogada válida. O resultado identifica o vencedor e explica o bloqueio.
- [ ] O teste nativo cobre uma colocação válida, uma tentativa inválida, alternância e um final de referência CRJM.
- [ ] O percurso do menu à partida estabelece o precedente de teste nativo para as entregas seguintes.
- [ ] A atividade funciona sem rede e não exige contas, serviços CRJM, GPU ou runtime de browser.
- [ ] O aluno consulta ajuda PT-PT sem perder a posição, reinicia com o estado inicial correto e regressa ao menu.
- [ ] Rato, toque e teclado permitem executar as ações desta entrega. Participantes e turno são reconhecíveis por sinais além da cor.
- [ ] Textos usam o sistema de traduções GCompris. Recursos reutilizados conservam atribuição, origem e licença registadas.
- [ ] O teste de aceitação executa a aplicação Qt real, começa no menu e verifica ações e resultado observáveis. Usa posições CRJM para casos especiais, sem substituir a validação ou forçar o vencedor.
- [ ] Guardar os comandos e resultados da validação desta entrega. O build e os testes TypeScript originais não substituem o percurso nativo.

## Comments

Divisão e dependências aprovadas pelo utilizador. Aplicam-se as decisões da especificação principal.
