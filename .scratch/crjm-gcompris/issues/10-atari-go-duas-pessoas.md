# 10: Atari Go para duas pessoas

Status: ready-for-agent
Type: task
Progress: resolved
Blocked by: 03
Parent: 01, Integrar os oito jogos CRJM no nosso fork do GCompris

**What to build:** O aluno abre Atari Go pelo menu e joga uma partida completa com outra pessoa no mesmo dispositivo, com tabuleiro nas interseções, grupos, liberdades e vitória na primeira captura.

O ticket 03 conclui o piloto nativo e estabelece o precedente de integração e validação reutilizado nesta entrega. Não depende da implementação dos outros jogos.

## Acceptance criteria

- [x] Joga-se nas interseções de um tabuleiro 9×9. As Pretas começam e a ajuda identifica grupos e liberdades.
- [x] Uma colocação suicida é rejeitada, salvo quando captura pedras adversárias e se torna legal pela regra de captura.
- [x] A primeira captura termina a partida com o vencedor correto. Não é aplicada pontuação de território do Go completo.
- [x] O teste nativo cobre liberdades partilhadas de grupo, suicídio rejeitado, exceção por captura e fim na primeira captura.
- [x] A atividade funciona sem rede e não exige contas, serviços CRJM, GPU ou runtime de browser.
- [x] O aluno consulta ajuda PT-PT sem perder a posição, reinicia com o estado inicial correto e regressa ao menu.
- [x] Rato, toque e teclado permitem executar as ações desta entrega. Participantes e turno são reconhecíveis por sinais além da cor.
- [x] Textos usam o sistema de traduções GCompris. Recursos reutilizados conservam atribuição, origem e licença registadas.
- [x] O teste de aceitação executa a aplicação Qt real, começa no menu e verifica ações e resultado observáveis. Usa posições CRJM para casos especiais, sem substituir a validação ou forçar o vencedor.
- [x] Guardar os comandos e resultados da validação desta entrega. O build e os testes TypeScript originais não substituem o percurso nativo.

## Comments

Divisão e dependências aprovadas pelo utilizador. Aplicam-se as decisões da especificação principal.

## Answer

Atari Go nativo para duas pessoas implementado: tabuleiro 9×9 nas interseções,
grupos e liberdades distintas, inspeção visual, suicídio com exceção por captura,
fim na primeira captura, ajuda PT-PT, teclado/toque/rato e reinício/menu.
Aceitação Qt real pelo menu passou sem rede e sem erros QML. Evidência e
comando reproduzível em `../evidence/10-atari-go/validation.md`. Implementação,
recursos e textos independentes, com origem documentada. Tux pertence ao11.
