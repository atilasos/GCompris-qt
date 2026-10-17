# 03: Dominório contra Tux e aprendizagem guiada

Status: ready-for-agent
Type: task
Progress: resolved
Blocked by: 02
Parent: 01, Integrar os oito jogos CRJM no nosso fork do GCompris

**What to build:** O aluno joga Dominório contra Tux sem rede, escolhe dificuldades progressivas e aprende com introdução às orientações e ao bloqueio espacial, pistas graduais e revisão de uma decisão.

## Acceptance criteria

- [x] O modo contra Tux partilha tabuleiro e regras com o modo de duas pessoas, sem duplicar as regras.
- [x] As dificuldades locais têm diferenças compreensíveis para o aluno. Tux só realiza ações legais e completas.
- [x] Uma introdução curta e pelo menos um exercício ensinam o objetivo do jogo antes da partida completa. Exercícios e variantes didáticas distinguem-se das regras CRJM.
- [x] O aluno pode pedir pistas graduais e realizar pelo menos um exercício de revisão de uma decisão após a partida.
- [x] A aplicação continua a responder enquanto Tux calcula. Sair, reiniciar ou terminar invalida o cálculo pendente, sem jogadas tardias.
- [x] Um teste na atividade real abre o modo contra Tux, recebe uma resposta legal, consulta uma pista e exercita o percurso até ao resultado e à revisão. O teste não substitui a IA nem atribui a vitória.
- [ ] Medir a resposta durante o cálculo num dispositivo modesto disponível, registar o equipamento e estabelecer limites de aceitação verificáveis para as entregas seguintes.
- [x] A atividade funciona sem rede e não exige contas, serviços CRJM, GPU ou runtime de browser.
- [x] O aluno consulta ajuda PT-PT sem perder a posição, reinicia com o estado inicial correto e regressa ao menu.
- [x] Rato, toque e teclado permitem executar as ações desta entrega. Participantes e turno são reconhecíveis por sinais além da cor.
- [x] Textos usam o sistema de traduções GCompris. Recursos reutilizados conservam atribuição, origem e licença registadas.
- [x] O teste de aceitação executa a aplicação Qt real, começa no menu e verifica ações e resultado observáveis. Usa posições CRJM para casos especiais, sem substituir a validação ou forçar o vencedor.
- [x] Guardar os comandos e resultados da validação desta entrega. O build e os testes TypeScript originais não substituem o percurso nativo.

## Comments

Divisão e dependências aprovadas pelo utilizador. Aplicam-se as decisões da especificação principal.

## Answer

Atividade nativa completa com Tux local em WorkerScript, três dificuldades reais,
introdução/final didático, três pistas graduais e revisão da primeira decisão
comparando opções horizontais após uma alternativa legal. Módulo ES de regras
partilhado com duas pessoas; conteúdo original sem copiar código CRJM.

Evidência reproduzível: `../evidence/03-dominorio/README.md`, red válido no menu,
Tux e regressão duas pessoas com 2 passes/0 falhas cada. Hard p95/máximo108ms
(n=10 sem diálogo), ajuda3ms, gap heartbeat23ms. Limites piloto verificáveis:
resposta2s, heartbeat250ms, ajuda1.5s e ausência de jogadas tardias.

Limitação material: host i5-12600K/46GiB, não dispositivo modesto; não existe
equipamento físico modesto disponível. Esse critério fica explicitamente por
validar antes de distribuição (ticket18), sem fingir uma medição nesse hardware.
Progresso resolvido cobre entrega de software e validação nativa disponível.
