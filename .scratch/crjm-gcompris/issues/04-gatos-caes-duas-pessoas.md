# 04: Gatos & Cães para duas pessoas

Status: ready-for-agent
Type: task
Progress: resolved
Blocked by: 03
Parent: 01, Integrar os oito jogos CRJM no nosso fork do GCompris

**What to build:** O aluno abre Gatos & Cães pelo menu e joga uma partida completa com outra pessoa no mesmo dispositivo, com partida completa com abertura especial, restrições de vizinhança e indicação de casas permitidas.

O ticket 03 conclui o piloto nativo e estabelece o precedente de integração e validação reutilizado nesta entrega. Não depende da implementação dos outros jogos.

## Acceptance criteria

- [x] O tabuleiro tem 8×8 casas. O primeiro Gato joga numa das quatro casas centrais e o primeiro Cão fora dessa zona.
- [x] Nunca ficam Gatos e Cães ortogonalmente adjacentes. As casas permitidas podem ser destacadas como ajuda.
- [x] Vence quem deixa o adversário sem colocação válida. A explicação do resultado corresponde à posição real.
- [x] O teste nativo cobre as duas aberturas especiais, rejeição por vizinhança e um final de referência CRJM.
- [x] A atividade funciona sem rede e não exige contas, serviços CRJM, GPU ou runtime de browser.
- [x] O aluno consulta ajuda PT-PT sem perder a posição, reinicia com o estado inicial correto e regressa ao menu.
- [x] Rato, toque e teclado permitem executar as ações desta entrega. Participantes e turno são reconhecíveis por sinais além da cor.
- [x] Textos usam o sistema de traduções GCompris. Recursos reutilizados conservam atribuição, origem e licença registadas.
- [x] O teste de aceitação executa a aplicação Qt real, começa no menu e verifica ações e resultado observáveis. Usa posições CRJM para casos especiais, sem substituir a validação ou forçar o vencedor.
- [x] Guardar os comandos e resultados da validação desta entrega. O build e os testes TypeScript originais não substituem o percurso nativo.

## Comments

Divisão e dependências aprovadas pelo utilizador. Aplicam-se as decisões da especificação principal.

## Answer

Atividade nativa Gatos & Cães disponível no menu, com regras CRJM de abertura e vizinhança, duas pessoas, ajuda PT-PT, casas permitidas opcionais, rato/toque/teclado, reinício e resultado normal por bloqueio. Implementação independente, sem importar código ou arte CRJM.

Aceitação Qt real offline passou: zero falhas, duas passagens, zero erros QML. Inclui partida legal completa de 33 jogadas e inspeção de capturas desktop/retrato. Evidência e comando em `../evidence/04-gatos-caes/README.md`. Ticket 05 permanece separado.
