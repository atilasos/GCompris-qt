# 15: Y contra Tux e aprendizagem guiada

Status: ready-for-agent
Type: task
Progress: resolved
Blocked by: 14
Parent: 01, Integrar os oito jogos CRJM no nosso fork do GCompris

**What to build:** O aluno joga Y contra Tux sem rede, escolhe dificuldades progressivas e aprende com exercícios de adjacência, conexão e ligação dos três lados, pistas graduais e revisão de uma decisão.

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

Implementado Y contra Tux com três políticas locais limitadas em WorkerScript,
troca que conserva a identidade de Tux como participante 2, introdução e exercício
preparado de ligação dos três lados, três pistas e revisão da primeira decisão
real com alternativa e contagem comparativa de grupo/lados. O grafo e as regras
partilhadas de conexão foram preservados; todos os novos controlos aceitam Tab/Espaço.

Aceitação Qt real offline pelo menu: zero falhas, resultado real contra Hard após
42 decisões humanas, respostas legais nas três dificuldades e após troca, ajuda,
exercício por toque, revisão por teclado, cancelamento imediato em reinício e
saída/reabertura, zoom e scroll. Regressão do ticket 14: zero falhas.
Evidência e comandos em `../evidence/15-y/README.md`. Capturas inspecionadas em
1100×1050, 1100×700 (pistas e jogada) e 600×900. Orçamentos observados no host
i5-12600K: resposta máxima 114 ms, heartbeat máximo 219 ms, ajuda 61 ms.
Estas medições não caracterizam um dispositivo modesto nem substituem revisão
pedagógica com crianças ou teste num ecrã tátil físico.
