# 14: Y para duas pessoas

Status: ready-for-agent
Type: task
Progress: resolved
Blocked by: 03
Parent: 01, Integrar os oito jogos CRJM no nosso fork do GCompris

**What to build:** O aluno abre Y pelo menu e joga uma partida completa com outra pessoa no mesmo dispositivo, com grafo correto, troca inicial e identificação do grupo vencedor ligado aos três lados.

O ticket 03 conclui o piloto nativo e estabelece o precedente de integração e validação reutilizado nesta entrega. Não depende da implementação dos outros jogos.

## Acceptance criteria

- [x] O tabuleiro preserva os 93 nós e as 252 ligações explícitas da referência CRJM. Proximidade visual não cria adjacência.
- [x] A vitória exige um único grupo ligado aos três lados. Grupos separados que atingem lados diferentes não bastam.
- [x] A troca inicial conserva a primeira peça, altera a atribuição das cores e mantém correta a identidade e a vez dos participantes.
- [x] O teste nativo cobre uma adjacência que não se deduz da distância visual, vitória por grupo único e troca inicial.
- [x] A atividade funciona sem rede e não exige contas, serviços CRJM, GPU ou runtime de browser.
- [x] O aluno consulta ajuda PT-PT sem perder a posição, reinicia com o estado inicial correto e regressa ao menu.
- [x] Rato, toque e teclado permitem executar as ações desta entrega. Participantes e turno são reconhecíveis por sinais além da cor.
- [x] Textos usam o sistema de traduções GCompris. Recursos reutilizados conservam atribuição, origem e licença registadas.
- [x] O teste de aceitação executa a aplicação Qt real, começa no menu e verifica ações e resultado observáveis. Usa posições CRJM para casos especiais, sem substituir a validação ou forçar o vencedor.
- [x] Guardar os comandos e resultados da validação desta entrega. O build e os testes TypeScript originais não substituem o percurso nativo.

## Comments

Divisão e dependências aprovadas pelo utilizador. Aplicam-se as decisões da especificação principal.

## Answer

Atividade nativa Y disponível no menu, com regras independentes, grafo factual
93/252 explícito, três lados e troca inicial. O grupo da última peça e o grupo
vencedor são realçados. Intersecções de 44 px, viewport deslizável, ampliação,
símbolos além da cor, teclado completo e ajuda PT-PT localizável.

Aceitação Qt offline em `evidence/14-y`: duas passagens, zero falhas, zero erros
QML. Quatro partidas completas cobrem vitória de ambas as cores e identidades
com e sem troca. O percurso adicional verifica E2/E3 sem ligação, D3 como ponte,
grupos separados sem vitória, toque, rato, teclado, Tab/Space em troca e ajuda,
reinício, preservação da posição, margem inferior em retrato e regresso ao menu.
Proveniência separa implementação GPL original de factos do desenho e conserva
os direitos do CRJM; a distribuição continua fora do âmbito.
