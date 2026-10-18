# 12: Produto para duas pessoas

Status: ready-for-agent
Type: task
Progress: resolved
Blocked by: 03
Parent: 01, Integrar os oito jogos CRJM no nosso fork do GCompris

**What to build:** O aluno abre Produto pelo menu e joga uma partida completa com outra pessoa no mesmo dispositivo, com tabuleiro hexagonal, colocações compostas, escolha de cores, pontuação visível e desempate.

O ticket 03 conclui o piloto nativo e estabelece o precedente de integração e validação reutilizado nesta entrega. Não depende da implementação dos outros jogos.

## Acceptance criteria

- [x] O tabuleiro hexagonal tem 61 casas. A primeira jogada coloca uma peça e os turnos seguintes colocam duas, com as cores permitidas pelas regras CRJM.
- [x] A seleção composta permite corrigir as peças antes de concluir o turno. Uma tentativa inválida não consome o turno.
- [x] A pontuação mostra as dimensões dos dois maiores grupos de cada cor e o seu produto. Menos de dois grupos dá zero.
- [x] O preenchimento do tabuleiro termina a partida. Aplica-se o desempate por menor número de peças e preservam-se os restantes resultados da referência CRJM.
- [x] O teste nativo cobre abertura, turno de duas peças, união de grupos, pontuação e desempate.
- [x] A atividade funciona sem rede e não exige contas, serviços CRJM, GPU ou runtime de browser.
- [x] O aluno consulta ajuda PT-PT sem perder a posição, reinicia com o estado inicial correto e regressa ao menu.
- [x] Rato, toque e teclado permitem executar as ações desta entrega. Participantes e turno são reconhecíveis por sinais além da cor.
- [x] Textos usam o sistema de traduções GCompris. Recursos reutilizados conservam atribuição, origem e licença registadas.
- [x] O teste de aceitação executa a aplicação Qt real, começa no menu e verifica ações e resultado observáveis. Usa posições CRJM para casos especiais, sem substituir a validação ou forçar o vencedor.
- [x] Guardar os comandos e resultados da validação desta entrega. O build e os testes TypeScript originais não substituem o percurso nativo.

## Comments

Divisão e dependências aprovadas pelo utilizador. Aplicam-se as decisões da especificação principal.

## Answer

Atividade Produto nativa para duas pessoas implementada, incluindo seleção corrigível antes de confirmar, abertura de qualquer cor, grupos e produto, final ao preencher as 61 casas e desempate por menor número de peças. Regras e SVG são uma implementação independente; não foi copiado código ou material CRJM.

Validação Qt real offline pelo menu: 2 passes, 0 falhas, sem erros QML. O teste confirma abertura branca, duas colocações, casas ocupadas, correção/cancelamento, grupos 2×2 e união em grupo único com produto zero, ajuda preservando seleção, Tab+Espaço em todos os botões e teclado no tabuleiro, toque sintético, partida completa legal 30 negras/31 brancas com vitória do participante 1 por desempate, reinício e menu. Capturas de computador 1100×700 e retrato 600×900 foram inspecionadas; alvos mantêm dimensões práticas. Evidência e comando em evidence/12-produto.

A verificação de toque é sintética, não um teste num tablet físico. Tux/aprendizagem são o ticket 13.
