# 12: Produto para duas pessoas

Status: ready-for-agent
Type: task
Progress: open
Blocked by: 03
Parent: 01, Integrar os oito jogos CRJM no nosso fork do GCompris

**What to build:** O aluno abre Produto pelo menu e joga uma partida completa com outra pessoa no mesmo dispositivo, com tabuleiro hexagonal, colocações compostas, escolha de cores, pontuação visível e desempate.

O ticket 03 conclui o piloto nativo e estabelece o precedente de integração e validação reutilizado nesta entrega. Não depende da implementação dos outros jogos.

## Acceptance criteria

- [ ] O tabuleiro hexagonal tem 61 casas. A primeira jogada coloca uma peça e os turnos seguintes colocam duas, com as cores permitidas pelas regras CRJM.
- [ ] A seleção composta permite corrigir as peças antes de concluir o turno. Uma tentativa inválida não consome o turno.
- [ ] A pontuação mostra as dimensões dos dois maiores grupos de cada cor e o seu produto. Menos de dois grupos dá zero.
- [ ] O preenchimento do tabuleiro termina a partida. Aplica-se o desempate por menor número de peças e preservam-se os restantes resultados da referência CRJM.
- [ ] O teste nativo cobre abertura, turno de duas peças, união de grupos, pontuação e desempate.
- [ ] A atividade funciona sem rede e não exige contas, serviços CRJM, GPU ou runtime de browser.
- [ ] O aluno consulta ajuda PT-PT sem perder a posição, reinicia com o estado inicial correto e regressa ao menu.
- [ ] Rato, toque e teclado permitem executar as ações desta entrega. Participantes e turno são reconhecíveis por sinais além da cor.
- [ ] Textos usam o sistema de traduções GCompris. Recursos reutilizados conservam atribuição, origem e licença registadas.
- [ ] O teste de aceitação executa a aplicação Qt real, começa no menu e verifica ações e resultado observáveis. Usa posições CRJM para casos especiais, sem substituir a validação ou forçar o vencedor.
- [ ] Guardar os comandos e resultados da validação desta entrega. O build e os testes TypeScript originais não substituem o percurso nativo.

## Comments

Divisão e dependências aprovadas pelo utilizador. Aplicam-se as decisões da especificação principal.
