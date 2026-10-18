# 17: Nex contra Tux e aprendizagem guiada

Status: ready-for-agent
Type: task
Progress: resolved
Blocked by: 16
Parent: 01, Integrar os oito jogos CRJM no nosso fork do GCompris

**What to build:** O aluno joga Nex contra Tux sem rede, escolhe dificuldades progressivas e aprende com introdução às ações compostas e exercícios de conexão e conversão, pistas graduais e revisão de uma decisão.

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

Modo contra Tux, três políticas locais limitadas em WorkerScript, cores dinâmicas após troca, introdução com três exercícios de ações compostas/conexão, pistas graduais e revisão da última decisão real implementados. Reiniciar/sair invalidam cálculos; as ações humanas ficam bloqueadas durante o turno de Tux. Regras, resolver de convenções raras e três exercícios anteriores preservados.

Aceitação nativa offline pelo menu: 0 falhas/2 passes e nenhum erro QML; regressão completa de duas pessoas igualmente 0 falhas/2 passes. Medições: resposta máxima 195 ms, heartbeat máximo 34 ms, ajuda 4 ms. Evidência, comandos, capturas inspecionadas e limitações em `.scratch/crjm-gcompris/evidence/17-nex/README.md`. Host i5-12600K; não substitui teste num tablet físico modesto.
