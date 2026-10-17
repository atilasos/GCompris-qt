# 14: Y para duas pessoas

Status: ready-for-agent
Type: task
Progress: claimed
Blocked by: 03
Parent: 01, Integrar os oito jogos CRJM no nosso fork do GCompris

**What to build:** O aluno abre Y pelo menu e joga uma partida completa com outra pessoa no mesmo dispositivo, com grafo correto, troca inicial e identificação do grupo vencedor ligado aos três lados.

O ticket 03 conclui o piloto nativo e estabelece o precedente de integração e validação reutilizado nesta entrega. Não depende da implementação dos outros jogos.

## Acceptance criteria

- [ ] O tabuleiro preserva os 93 nós e as 252 ligações explícitas da referência CRJM. Proximidade visual não cria adjacência.
- [ ] A vitória exige um único grupo ligado aos três lados. Grupos separados que atingem lados diferentes não bastam.
- [ ] A troca inicial conserva a primeira peça, altera a atribuição das cores e mantém correta a identidade e a vez dos participantes.
- [ ] O teste nativo cobre uma adjacência que não se deduz da distância visual, vitória por grupo único e troca inicial.
- [ ] A atividade funciona sem rede e não exige contas, serviços CRJM, GPU ou runtime de browser.
- [ ] O aluno consulta ajuda PT-PT sem perder a posição, reinicia com o estado inicial correto e regressa ao menu.
- [ ] Rato, toque e teclado permitem executar as ações desta entrega. Participantes e turno são reconhecíveis por sinais além da cor.
- [ ] Textos usam o sistema de traduções GCompris. Recursos reutilizados conservam atribuição, origem e licença registadas.
- [ ] O teste de aceitação executa a aplicação Qt real, começa no menu e verifica ações e resultado observáveis. Usa posições CRJM para casos especiais, sem substituir a validação ou forçar o vencedor.
- [ ] Guardar os comandos e resultados da validação desta entrega. O build e os testes TypeScript originais não substituem o percurso nativo.

## Comments

Divisão e dependências aprovadas pelo utilizador. Aplicam-se as decisões da especificação principal.
