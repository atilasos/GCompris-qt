# 11: Atari Go contra Tux e aprendizagem guiada

Status: ready-for-agent
Type: task
Progress: claimed
Blocked by: 10
Parent: 01, Integrar os oito jogos CRJM no nosso fork do GCompris

**What to build:** O aluno joga Atari Go contra Tux sem rede, escolhe dificuldades progressivas e aprende com problemas curtos de captura e leitura visual de liberdades, pistas graduais e revisão de uma decisão.

## Acceptance criteria

- [ ] O modo contra Tux partilha tabuleiro e regras com o modo de duas pessoas, sem duplicar as regras.
- [ ] As dificuldades locais têm diferenças compreensíveis para o aluno. Tux só realiza ações legais e completas.
- [ ] Uma introdução curta e pelo menos um exercício ensinam o objetivo do jogo antes da partida completa. Exercícios e variantes didáticas distinguem-se das regras CRJM.
- [ ] O aluno pode pedir pistas graduais e realizar pelo menos um exercício de revisão de uma decisão após a partida.
- [ ] A aplicação continua a responder enquanto Tux calcula. Sair, reiniciar ou terminar invalida o cálculo pendente, sem jogadas tardias.
- [ ] Um teste na atividade real abre o modo contra Tux, recebe uma resposta legal, consulta uma pista e exercita o percurso até ao resultado e à revisão. O teste não substitui a IA nem atribui a vitória.
- [ ] Medir a resposta durante o cálculo e verificar os limites de aceitação estabelecidos no piloto de Dominório.
- [ ] A atividade funciona sem rede e não exige contas, serviços CRJM, GPU ou runtime de browser.
- [ ] O aluno consulta ajuda PT-PT sem perder a posição, reinicia com o estado inicial correto e regressa ao menu.
- [ ] Rato, toque e teclado permitem executar as ações desta entrega. Participantes e turno são reconhecíveis por sinais além da cor.
- [ ] Textos usam o sistema de traduções GCompris. Recursos reutilizados conservam atribuição, origem e licença registadas.
- [ ] O teste de aceitação executa a aplicação Qt real, começa no menu e verifica ações e resultado observáveis. Usa posições CRJM para casos especiais, sem substituir a validação ou forçar o vencedor.
- [ ] Guardar os comandos e resultados da validação desta entrega. O build e os testes TypeScript originais não substituem o percurso nativo.

## Comments

Divisão e dependências aprovadas pelo utilizador. Aplicam-se as decisões da especificação principal.
