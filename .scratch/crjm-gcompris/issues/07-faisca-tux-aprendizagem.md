# 07: Faísca contra Tux e aprendizagem guiada

Status: ready-for-agent
Type: task
Progress: resolved
Blocked by: 06
Parent: 01, Integrar os oito jogos CRJM no nosso fork do GCompris

**What to build:** O aluno joga Faísca contra Tux sem rede, escolhe dificuldades progressivas e aprende com exercícios de direção, distância, destino e opções do adversário, pistas graduais e revisão de uma decisão.

## Acceptance criteria

- [x] O modo contra Tux partilha tabuleiro e regras com o modo de duas pessoas, sem duplicar as regras.
- [x] As dificuldades locais têm diferenças compreensíveis para o aluno. Tux só realiza ações legais e completas.
- [x] Uma introdução curta e pelo menos um exercício ensinam o objetivo do jogo antes da partida completa. Exercícios e variantes didáticas distinguem-se das regras CRJM.
- [x] O aluno pode pedir pistas graduais e realizar pelo menos um exercício de revisão de uma decisão após a partida.
- [x] A aplicação continua a responder enquanto Tux calcula. Sair, reiniciar ou terminar invalida o cálculo pendente, sem jogadas tardias.
- [x] Um teste na atividade real abre o modo contra Tux, recebe uma resposta legal, consulta uma pista e exercita o percurso até ao resultado e à revisão. O teste não substitui a IA nem atribui a vitória.
- [x] Medir a resposta durante o cálculo e verificar os limites de aceitação estabelecidos no piloto de Dominório.
- [x] A atividade funciona sem rede e não exige contas, serviços CRJM, GPU ou runtime de browser.
- [x] O aluno consulta ajuda PT-PT sem perder a posição, reinicia com o estado inicial correto e regressa ao menu.
- [x] Rato, toque e teclado permitem executar as ações desta entrega. Participantes e turno são reconhecíveis por sinais além da cor.
- [x] Textos usam o sistema de traduções GCompris. Recursos reutilizados conservam atribuição, origem e licença registadas.
- [x] O teste de aceitação executa a aplicação Qt real, começa no menu e verifica ações e resultado observáveis. Usa posições CRJM para casos especiais, sem substituir a validação ou forçar o vencedor.
- [x] Guardar os comandos e resultados da validação desta entrega. O build e os testes TypeScript originais não substituem o percurso nativo.

## Comments

Divisão e dependências aprovadas pelo utilizador. Aplicam-se as decisões da especificação principal.

## Answer

Implementado o modo contra Tux com três políticas locais, execução limitada em
WorkerScript e regras partilhadas. A introdução, exercício de destino, três
pistas graduais e revisão da primeira decisão funcionam com os controlos reais.
A revisão compara opções legais sem atribuir uma vitória ao exercício.

A aceitação Qt parte do menu, joga até ao bloqueio real, consulta ajuda, revê
uma alternativa, reinicia, sai e reabre sem respostas tardias. Teclado Tab e
Espaço, rato e toque sintético foram exercitados. O modo de duas pessoas mantém
o percurso CRJM verificado. Ambos os testes passaram com zero falhas e erros
QML, em software e sem rede. Evidência e limitações do host em
[evidence/07-faisca](../evidence/07-faisca/README.md).

Código inicial no commit daf2235b2; inclui a integração eba039279 antes da
validação final. O trabalho não publica o fork nem altera licenças CRJM.
