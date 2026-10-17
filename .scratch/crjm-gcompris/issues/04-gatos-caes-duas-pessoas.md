# 04: Gatos & Cães para duas pessoas

Status: ready-for-agent
Type: task
Progress: claimed
Blocked by: 03
Parent: 01, Integrar os oito jogos CRJM no nosso fork do GCompris

**What to build:** O aluno abre Gatos & Cães pelo menu e joga uma partida completa com outra pessoa no mesmo dispositivo, com partida completa com abertura especial, restrições de vizinhança e indicação de casas permitidas.

O ticket 03 conclui o piloto nativo e estabelece o precedente de integração e validação reutilizado nesta entrega. Não depende da implementação dos outros jogos.

## Acceptance criteria

- [ ] O tabuleiro tem 8×8 casas. O primeiro Gato joga numa das quatro casas centrais e o primeiro Cão fora dessa zona.
- [ ] Nunca ficam Gatos e Cães ortogonalmente adjacentes. As casas permitidas podem ser destacadas como ajuda.
- [ ] Vence quem deixa o adversário sem colocação válida. A explicação do resultado corresponde à posição real.
- [ ] O teste nativo cobre as duas aberturas especiais, rejeição por vizinhança e um final de referência CRJM.
- [ ] A atividade funciona sem rede e não exige contas, serviços CRJM, GPU ou runtime de browser.
- [ ] O aluno consulta ajuda PT-PT sem perder a posição, reinicia com o estado inicial correto e regressa ao menu.
- [ ] Rato, toque e teclado permitem executar as ações desta entrega. Participantes e turno são reconhecíveis por sinais além da cor.
- [ ] Textos usam o sistema de traduções GCompris. Recursos reutilizados conservam atribuição, origem e licença registadas.
- [ ] O teste de aceitação executa a aplicação Qt real, começa no menu e verifica ações e resultado observáveis. Usa posições CRJM para casos especiais, sem substituir a validação ou forçar o vencedor.
- [ ] Guardar os comandos e resultados da validação desta entrega. O build e os testes TypeScript originais não substituem o percurso nativo.

## Comments

Divisão e dependências aprovadas pelo utilizador. Aplicam-se as decisões da especificação principal.
