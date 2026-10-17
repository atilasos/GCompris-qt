# 06: Faísca para duas pessoas

Status: ready-for-agent
Type: task
Progress: open
Blocked by: 03
Parent: 01, Integrar os oito jogos CRJM no nosso fork do GCompris

**What to build:** O aluno abre Faísca pelo menu e joga uma partida completa com outra pessoa no mesmo dispositivo, com seleção de distância e direção, previsão do destino, reservas e casa obrigatória.

O ticket 03 conclui o piloto nativo e estabelece o precedente de integração e validação reutilizado nesta entrega. Não depende da implementação dos outros jogos.

## Acceptance criteria

- [ ] O tabuleiro tem 5×6 casas. Cada participante começa com cinco peças de cada distância 1, 2 e 3.
- [ ] A abertura permite escolher a casa. As jogadas seguintes colocam a peça na casa obrigatória indicada pela seta anterior.
- [ ] A direção é ortogonal, a distância é exata e o destino está vazio e dentro do tabuleiro. Casas intermédias ocupadas podem ser saltadas.
- [ ] A seleção permite corrigir distância e direção antes de confirmar. Só uma jogada válida consome a reserva e passa o turno.
- [ ] Vence quem deixa o adversário sem jogada válida. O teste nativo cobre reservas, salto permitido, destino inválido e final.
- [ ] A atividade funciona sem rede e não exige contas, serviços CRJM, GPU ou runtime de browser.
- [ ] O aluno consulta ajuda PT-PT sem perder a posição, reinicia com o estado inicial correto e regressa ao menu.
- [ ] Rato, toque e teclado permitem executar as ações desta entrega. Participantes e turno são reconhecíveis por sinais além da cor.
- [ ] Textos usam o sistema de traduções GCompris. Recursos reutilizados conservam atribuição, origem e licença registadas.
- [ ] O teste de aceitação executa a aplicação Qt real, começa no menu e verifica ações e resultado observáveis. Usa posições CRJM para casos especiais, sem substituir a validação ou forçar o vencedor.
- [ ] Guardar os comandos e resultados da validação desta entrega. O build e os testes TypeScript originais não substituem o percurso nativo.

## Comments

Divisão e dependências aprovadas pelo utilizador. Aplicam-se as decisões da especificação principal.
