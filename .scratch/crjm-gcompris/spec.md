# Integrar os oito jogos CRJM no nosso fork do GCompris

Status: ready-for-agent
Type: task
Progress: resolved

## Problem Statement

Os jogos matemáticos desenvolvidos no CRJM estão disponíveis numa aplicação
web separada. Os alunos que usam o nosso fork do GCompris não conseguem
praticá-los dentro da suite, com os mesmos controlos, navegação e funcionamento
local das restantes atividades.

Pretendemos aproveitar o trabalho existente nos oito jogos, incluindo regras,
ajuda e exercícios, sem obrigar os alunos a mudar de aplicação ou a depender
dos serviços de campeonatos e de IA remota.

## Solution

Integrar Dominório, Gatos & Cães, Faísca, Quelhas, Atari Go, Produto, Y e Nex
como atividades nativas no nosso fork do GCompris. Cada jogo permite jogar
com outra pessoa no mesmo dispositivo ou contra Tux, consultar regras e pedir
ajuda visual. As atividades funcionam sem ligação à Internet.

A implementação começa por Dominório e prossegue por Gatos & Cães e Faísca.
Quelhas e Atari Go constituem a fase seguinte. Produto, Y e Nex completam
a integração. O primeiro piloto só conclui a primeira entrega, não a especificação
inteira. Os jogos mais avançados destinam-se também a alunos mais velhos,
conforme o público do nosso fork.

## User Stories

1. Como aluno, quero encontrar os jogos matemáticos no menu do GCompris, para começar a praticar sem abrir outra aplicação.
2. Como aluno, quero identificar cada jogo pelo nome e ícone, para escolher a modalidade pretendida.
3. Como aluno, quero encontrar os oito jogos, para praticar também os que deixaram a edição atual do CRJM.
4. Como aluno, quero jogar sem Internet, para usar os jogos na escola ou em casa sem serviços externos.
5. Como aluno, quero jogar com um colega no mesmo dispositivo, para praticarmos em conjunto.
6. Como aluno, quero jogar contra Tux, para praticar sozinho.
7. Como aluno, quero distinguir os participantes e saber de quem é o turno, para evitar jogar pelo adversário.
8. Como aluno, quero reconhecer a minha orientação ou cor, para compreender as minhas jogadas permitidas.
9. Como aluno, quero ver quais as jogadas permitidas quando preciso de ajuda, para aprender as regras no tabuleiro.
10. Como aluno, quero prever o efeito de uma seleção antes de a concluir, para evitar erros de toque em jogadas compostas.
11. Como aluno, quero que uma tentativa inválida preserve o turno e as peças, para poder corrigir a minha escolha.
12. Como aluno, quero receber uma indicação visual quando a jogada é inválida, para perceber o que preciso de corrigir.
13. Como aluno, quero usar rato, toque ou teclado, para jogar com o dispositivo disponível.
14. Como aluno, quero distinguir peças por sinais visuais além da cor, para compreender o tabuleiro mesmo quando as cores se confundem.
15. Como aluno, quero consultar instruções curtas em português de Portugal, para aprender a jogar sem explicações técnicas.
16. Como aluno, quero abrir e fechar a ajuda sem perder a posição, para continuar a partida depois de consultar uma regra.
17. Como aluno, quero começar com exercícios curtos, para aprender uma regra de cada vez antes da partida completa.
18. Como aluno, quero pedir pistas graduais, para receber orientação sem obter imediatamente a resposta.
19. Como aluno, quero rever uma decisão depois da partida, para perceber uma alternativa que possa experimentar.
20. Como aluno, quero escolher dificuldades progressivas contra Tux, para encontrar um desafio adequado.
21. Como aluno, quero que o tabuleiro continue a responder enquanto Tux pensa, para não confundir o cálculo com uma aplicação bloqueada.
22. Como aluno, quero ver quem ganhou e porquê, para compreender a condição de fim da partida.
23. Como aluno, quero iniciar uma nova partida, para repetir o jogo com o estado inicial correto.
24. Como aluno, quero regressar ao menu sem ações posteriores da partida anterior, para escolher outra atividade.
25. Como aluno de Dominório, quero colocar dominós na orientação do meu participante, para disputar espaço com quem joga na outra orientação.
26. Como aluno de Dominório, quero que o jogo termine quando o participante seguinte não puder jogar, para reconhecer quem venceu por bloqueio.
27. Como aluno de Gatos & Cães, quero reconhecer as restrições da abertura e da vizinhança, para colocar peças legais desde o primeiro turno.
28. Como aluno de Gatos & Cães, quero ver o bloqueio das casas pelas espécies adversárias, para antecipar onde ainda poderei jogar.
29. Como aluno de Faísca, quero ver a casa obrigatória e o destino da seta, para distinguir onde coloco a peça de onde o adversário jogará.
30. Como aluno de Faísca, quero consultar as reservas das distâncias 1, 2 e 3, para escolher uma peça que ainda tenho disponível.
31. Como aluno de Faísca, quero saltar casas intermédias ocupadas quando o destino é válido, para aplicar a regra correta de movimento.
32. Como aluno de Quelhas, quero selecionar segmentos com comprimento permitido na minha orientação, para construir uma jogada completa sem ambiguidades.
33. Como aluno de Quelhas, quero reconhecer a opção de troca no momento permitido, para decidir se mantenho o meu papel inicial.
34. Como aluno de Quelhas, quero ver que perde quem faz a última jogada, para não aplicar por engano o objetivo de Dominório.
35. Como aluno de Atari Go, quero identificar grupos e liberdades, para aprender a preparar ou impedir uma captura.
36. Como aluno de Atari Go, quero que a primeira captura conclua a partida, para praticar esta modalidade sem precisar de aprender a pontuação do Go completo.
37. Como aluno de Produto, quero colocar as duas peças do turno com as cores permitidas, para explorar a construção e a união de grupos.
38. Como aluno de Produto, quero ver a dimensão dos dois maiores grupos e o seu produto, para compreender a pontuação.
39. Como aluno de Produto, quero reconhecer a exceção da primeira colocação e o desempate, para compreender o resultado da partida.
40. Como aluno de Y, quero seguir as ligações desenhadas no tabuleiro, para distinguir adjacência de proximidade visual.
41. Como aluno de Y, quero ver o grupo que liga os três lados, para compreender a vitória.
42. Como aluno de Y, quero reconhecer a troca de cores sem confundir a identidade dos participantes, para saber de quem é a vez depois da troca.
43. Como aluno de Nex, quero distinguir peças próprias, adversárias e neutras, para escolher as ações disponíveis.
44. Como aluno de Nex, quero construir e confirmar uma colocação ou substituição completa, para evitar ações parciais involuntárias.
45. Como aluno de Nex, quero reconhecer as margens que devo ligar e a troca inicial, para acompanhar o meu objetivo durante a partida.
46. Como professor, quero distinguir exercícios introdutórios de partidas com regras CRJM, para escolher a atividade adequada à turma.
47. Como professor, quero manter os jogos de arquivo disponíveis, para continuar a usar materiais de edições anteriores.
48. Como professor, quero dispor de jogos avançados para alunos mais velhos, para ampliar o uso do nosso fork.
49. Como mantenedor do fork, quero aproveitar regras e posições já verificadas, para reduzir divergências entre as versões CRJM e GCompris.
50. Como mantenedor do fork, quero integrar textos no sistema de traduções do GCompris, para permitir outros idiomas sem manter um segundo mecanismo.
51. Como mantenedor do fork, quero validar a atividade nativa completa, para demonstrar que o aluno consegue jogar na aplicação real.
52. Como mantenedor do fork, quero conservar atribuições e registar a origem dos componentes, para distribuir o trabalho com as permissões adequadas.

## Implementation Decisions

- O destino é exclusivamente o nosso fork. A aceitação pelos mantenedores do GCompris oficial e a sua política de contribuições geradas por IA não são requisitos desta implementação.
- Os oito jogos fazem parte do âmbito. A sequência proposta é Dominório, Gatos & Cães, Faísca, Quelhas, Atari Go, Produto, Y e Nex. Cada entrega deve funcionar antes de começar a seguinte.
- Criar interfaces nativas Qt Quick com QML e adaptar a lógica necessária para JavaScript compatível com o Qt utilizado pelo fork. Não incorporar a aplicação React numa WebView.
- Usar as estruturas existentes de atividade, metadados, recursos, níveis, ajuda, tradução e navegação do GCompris. A categoria de estratégia é o ponto inicial de integração, sem criar um novo sistema de menu.
- Partilhar regras e tabuleiro entre as variantes de duas pessoas e contra Tux, seguindo o precedente do quatro em linha. Não criar um motor genérico para os oito jogos antes de haver necessidade demonstrada.
- Separar regras de apresentação e da escolha de jogada do computador. Reutilizar código, algoritmos, conteúdos e posições CRJM quando forem adequados e os direitos permitirem.
- Manter as regras CRJM nas partidas completas. Exercícios usam posições curtas ou parcialmente preenchidas. Qualquer alteração de dimensão ou regra deve ser identificada como variante didática.
- Dominório conserva o tabuleiro 8×8, duas casas por dominó, orientações distintas e vitória quando o adversário fica sem jogada.
- Gatos & Cães conserva o tabuleiro 8×8, a abertura especial de cada espécie e a proibição de adjacência ortogonal entre espécies diferentes.
- Faísca conserva o tabuleiro 5×6, as reservas individuais, as distâncias exatas, a casa obrigatória e a possibilidade de saltar peças intermédias. O destino tem de estar vazio e dentro do tabuleiro.
- Quelhas conserva o tabuleiro 10×10, segmentos de comprimento mínimo dois, orientações por participante, troca inicial e final misère. O participante sem jogadas no seu turno ganha.
- Atari Go conserva o tabuleiro 9×9 nas interseções, a contagem de liberdades por grupo, a proibição de suicídio com a exceção de captura e a vitória na primeira captura.
- Produto conserva o tabuleiro hexagonal de 61 casas, a abertura de uma peça, os turnos seguintes de duas peças de qualquer cor e a pontuação pelo produto dos dois maiores grupos. Conservar o desempate por menor número de peças.
- Y conserva o grafo explícito de 93 nós e 252 ligações. Uma vitória exige um único grupo ligado aos três lados. A troca inicial altera a atribuição de cores, não a identidade dos participantes.
- Nex conserva o tabuleiro hexagonal 11×11, as peças neutras, as ações completas de colocação e substituição, a troca inicial e as condições de conexão e final da referência CRJM.
- Uma tentativa inválida não altera o estado da partida. Uma ação composta permite corrigir a seleção antes da confirmação.
- A IA funciona localmente, com dificuldade limitada e execução que preserve a resposta da interface. Adaptar ou cancelar o cálculo ao terminar, reiniciar ou abandonar a atividade. Um temporizador antes de uma busca síncrona longa não resolve o bloqueio da interface.
- Não exigir Rust, WASM, GPU ou serviços remotos ao utilizador. A primeira entrega usa uma IA local adequada ao ensino. Motores mais fortes só justificam dependências adicionais após medição.
- Adaptar pistas graduais e revisão CRJM a uma apresentação curta e visual. Cada jogo tem uma introdução, ajuda opcional e pelo menos um exercício de revisão. Não transportar o painel completo de treino de campeonato.
- Preparar textos de origem em PT-PT e usar o sistema de tradução do GCompris. A estrutura aceita traduções adicionais sem importar a infraestrutura de idiomas da aplicação web.
- Usar a persistência e a configuração do anfitrião quando necessárias. Não introduzir contas, tabelas, autenticação ou contratos de rede específicos do CRJM.
- Preservar a aplicação CRJM e as suas decisões de arquitetura. A integração cria outra utilização dos jogos e não substitui React nem o progresso centrado no aluno da plataforma original.
- Registar autoria, origem e licença dos componentes reutilizados. Antes de distribuir o fork, compatibilizar as permissões desses componentes com as licenças do conjunto. Não alterar a licença de toda a plataforma CRJM por omissão.

## Testing Decisions

- O utilizador confirmou a atividade nativa completa como ponto principal de teste. O percurso de aceitação começa no menu, abre o jogo, recebe ações reais, consulta ajuda e verifica o fim da partida.
- Usar o precedente dos testes funcionais nativos existentes no fork, que executam a aplicação Qt real e entregam eventos aos controlos originais. Aproveitar o mecanismo de execução quando adequado, sem acoplar os novos jogos aos casos de letras.
- Os testes verificam comportamentos observáveis, não a estrutura dos objetos internos. Não substituir a validação das jogadas, a IA ou a atribuição de resultados por funções do teste.
- Os testes de regras CRJM fornecem posições e resultados de referência para aberturas, jogadas ilegais, troca, captura, pontuação e finais. Não duplicar toda a suite original sem necessidade.
- Preparar posições de teste através da inicialização normal do jogo ou dos exercícios. Uma preparação controlada pode encurtar o percurso até ao caso especial, mas não declarar a vitória nem saltar o tratamento normal da ação.
- Não criar uma API pública de teste transversal aos jogos por antecipação. Se o mecanismo nativo existente não permitir preparar uma posição, propor a menor configuração de cenário ao nível da atividade.
- Para cada jogo, verificar descoberta no menu, os dois modos locais, alternância, identificação dos participantes, rejeição de jogada inválida e um percurso até ao resultado. Cobrir rato, teclado e toque no conjunto de aceitação, incluindo as jogadas compostas.
- Verificar as regras específicas enumeradas nas decisões de implementação. Dar especial atenção à inversão do vencedor em Quelhas, às liberdades no Atari Go, à troca em Y e Nex, às reservas de Faísca e à pontuação de Produto.
- Abrir e fechar ajuda deve preservar a partida. Reiniciar deve recuperar o estado inicial. Sair deve impedir que respostas de IA pendentes alterem a atividade reaberta ou outra atividade.
- Executar sem rede e com perfil de teste separado. Confirmar que as oito atividades não exigem autenticação, backend ou GPU.
- Verificar o tabuleiro e os controlos em dimensões de computador e tablet, com retrato quando suportado. As casas e alvos de ações compostas devem continuar selecionáveis.
- Medir a resposta da aplicação durante o cálculo da IA num dispositivo modesto disponível e registar os tempos. Definir limites de aceitação a partir do piloto antes de replicar a IA para os restantes jogos.
- Confirmar instruções PT-PT, textos localizáveis, contraste e identificação além da cor. A revisão pedagógica com crianças complementa a aceitação funcional e não pode ser declarada realizada por testes automáticos.
- Não exigir provas estatísticas de força nem uma suite separada dos motores de IA nesta especificação. A aceitação cobre a legalidade das respostas e o comportamento do modo contra Tux.
- Guardar comandos, versões, resultados e capturas aplicáveis por entrega. Um build bem-sucedido ou os testes TypeScript originais não substituem uma partida funcional no Qt.

## Out of Scope

- Submeter alterações ao GCompris oficial ou pedir aprovação aos seus mantenedores.
- Migrar, substituir ou publicar a aplicação web CRJM.
- Transportar campeonatos online, dupla eliminação, WebSocket, painéis do professor ou modo espectador.
- Integrar contas, turmas, autenticação, XP, conquistas ou sincronização de progresso com o backend CRJM.
- Integrar treino de redes neuronais, serviços GPU, IA remota ou garantir força de campeonato.
- Criar um framework genérico para jogos de tabuleiro ou uma nova infraestrutura de testes independente da aplicação.
- Produzir gravações de voz e traduções completas de idiomas adicionais nesta entrega.
- Alterar silenciosamente os regulamentos para facilitar os testes ou a implementação.
- Distribuir o fork antes de verificar as permissões dos componentes reutilizados.

## Further Notes

A análise de origem está em [analise.md](analise.md), com o inventário e as
referências técnicas. A nota [requisitos-gcompris.md](requisitos-gcompris.md)
complementa a comparação com as atividades existentes.

A referência CRJM verificada é o commit
`b206a7b4948673be935a5cb6a5a84df92d3ba6c2`, igual no checkout local e no
main remoto durante a análise. Os oito ficheiros de testes das regras passaram
com 187 testes e zero falhas. À data da investigação, não existia uma implementação Qt destes
jogos verificada.

A faixa de 2 a 10 anos declarada pelo projeto oficial não limita o público do
nosso fork. A classificação por ciclo do CRJM informa a apresentação e a
introdução pedagógica, sem impedir jogos avançados para alunos mais velhos.

O utilizador confirmou os testes pela atividade nativa em 2026-10-17.
As escolhas técnicas desta especificação sintetizam a análise anterior.
Não houve protótipo, compromisso de prazo ou aprovação de uma distribuição.


## Resultado da implementação

Implementação concluída na branch `integration/crjm-games`. Os oito jogos são
atividades nativas com dois modos locais, ajuda, aprendizagem e revisão.
Os tickets 02 a 18 estão resolvidos. A [aceitação da build](evidence/18-build/README.md)
regista 18 percursos Qt sem rede, com cota virtual de 1 CPU e 512 MiB, sem
falhas, erros QML ou eventos OOM. A [revisão final](final-review.md) tratou três
observações de manutenção e não encontrou desvios funcionais da especificação.
Os quatro percursos de Nex e Quelhas voltaram a passar após essas alterações.

A build Linux local abre por `build/crjm-complete/run-crjm.sh` e usa o Qt
instalado nesta máquina. Os manifestos e a auditoria de origem estão na
evidência. Não houve publicação ou distribuição. Testes em dispositivos físicos,
som físico e observação com crianças permanecem pendentes; o ensaio virtual e
o toque QtTest não substituem essas validações.
