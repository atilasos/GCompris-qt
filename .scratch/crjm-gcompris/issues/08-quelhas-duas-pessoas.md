# 08: Quelhas para duas pessoas

Status: ready-for-agent
Type: task
Progress: claimed
Blocked by: 03
Parent: 01, Integrar os oito jogos CRJM no nosso fork do GCompris

**What to build:** O aluno abre Quelhas pelo menu e joga uma partida completa com outra pessoa no mesmo dispositivo, com seleção e confirmação de segmentos, troca inicial e resultado misère explicado.

O ticket 03 conclui o piloto nativo e estabelece o precedente de integração e validação reutilizado nesta entrega. Não depende da implementação dos outros jogos.

## Acceptance criteria

- [ ] O tabuleiro tem 10×10 casas. Cada segmento tem comprimento mínimo dois e respeita a orientação do participante.
- [ ] A seleção mostra o segmento completo, permite correção antes de confirmar e rejeita sobreposições sem alterar o turno.
- [ ] O segundo participante pode trocar de papel na primeira oportunidade. A troca consome esse turno e atualiza as orientações.
- [ ] O participante sem jogadas no seu turno ganha. O resultado explica que perde quem faz a última jogada.
- [ ] O teste nativo cobre segmento inválido, comprimentos diferentes, troca e final misère de referência CRJM.
- [ ] A atividade funciona sem rede e não exige contas, serviços CRJM, GPU ou runtime de browser.
- [ ] O aluno consulta ajuda PT-PT sem perder a posição, reinicia com o estado inicial correto e regressa ao menu.
- [ ] Rato, toque e teclado permitem executar as ações desta entrega. Participantes e turno são reconhecíveis por sinais além da cor.
- [ ] Textos usam o sistema de traduções GCompris. Recursos reutilizados conservam atribuição, origem e licença registadas.
- [ ] O teste de aceitação executa a aplicação Qt real, começa no menu e verifica ações e resultado observáveis. Usa posições CRJM para casos especiais, sem substituir a validação ou forçar o vencedor.
- [ ] Guardar os comandos e resultados da validação desta entrega. O build e os testes TypeScript originais não substituem o percurso nativo.

## Comments

Divisão e dependências aprovadas pelo utilizador. Aplicam-se as decisões da especificação principal.
