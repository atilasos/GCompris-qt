# Memória matemática em PT-PT: lote nativo concluído

Os **70 casos nativos delimitados passaram**, nas 14 variantes, com 207
combinações nível/modo concluídas. Os [quatro testes de dados](data.log) passam. A aceitação
global Linux, Windows e docente continua **pending**.

| Atividade | Níveis | Modos | Percursos | Erros |
| --- | --- | --- | --- | --- |
| memory-math-add | 10 | 1 e 2 jogadores | 20 | 25 |
| memory-math-add-tux | 10 | Tux | 10 | 15 |
| memory-math-minus | 10 | 1 e 2 jogadores | 20 | 25 |
| memory-math-minus-tux | 10 | Tux | 10 | 45 |
| memory-math-mult | 10 | 1 e 2 jogadores | 20 | 25 |
| memory-math-mult-tux | 10 | Tux | 10 | 35 |
| memory-math-div | 10 | 1 e 2 jogadores | 20 | 25 |
| memory-math-div-tux | 10 | Tux | 10 | 43 |
| memory-math-add-minus | 10 | 1 e 2 jogadores | 20 | 25 |
| memory-math-add-minus-tux | 10 | Tux | 10 | 28 |
| memory-math-mult-div | 9 | 1 e 2 jogadores | 18 | 22 |
| memory-math-mult-div-tux | 9 | Tux | 9 | 26 |
| memory-math-add-minus-mult-div | 10 | 1 e 2 jogadores | 20 | 25 |
| memory-math-add-minus-mult-div-tux | 10 | Tux | 10 | 31 |

## Comportamento e resultados

Os eventos reais produziram 1033 pares corretos do jogador e
47 do Tux, 395 pares errados e 395
terceiros cliques bloqueados. A pontuação foi confrontada com as cartas
realmente encontradas. Houve 223 turnos do Tux, com entrada de rato e
Espaço bloqueada durante esses turnos.

Os 207 Bonus positivos avançaram naturalmente pelos níveis e
regressaram ao primeiro. Os 9 negativos incluem sete derrotas
deliberadas contra o Tux e duas naturais. Cada derrota repetiu o nível; as duas
naturais foram seguidas da vitória necessária para avançar. São 216 tabuleiros
terminados, correspondentes às 207 combinações e nove derrotas adicionais.
Não se alteraram RNG, matchCode, pontuação, respostas ou durações do jogo.

Todos os níveis têm respostas corretas/erradas, atraso de exposição de cartas,
bloqueio do terceiro clique e rejeição de cartas já encontradas. Nos modos de
dois jogadores, ambos pontuam/vencem. As quatro setas, Espaço, Enter/Return,
reinício, anterior/próximo, ajuda PT, fecho, Home e Escape foram exercitados
nos casos correspondentes. O reinício inclui carta aberta e timer pendente
durante turno do Tux, aguardando mais que os 1500 ms originais.

## Dados, tradução e configurações

Os testes verificam os 138 datasets, em duas ordens de mistura, 3748 pares
gerados, todas as contas, tabela/operandos, resultados distintos e uniões
completas nas variantes mistas. O oráculo usa contagem de unidades e relações
inversas, sem reutilizar a fórmula do gerador. Testes negativos rejeitam uma
resposta errada e resultados duplicados. O código original indicado por cada
Data.qml é executado; não se exige o nome específico da função geradora.

O Qt confirmou os 138 objetivos portugueses das tabelas. Os títulos e a ajuda
PT das 14 variantes também foram confirmados. Uma tabela, duas tabelas e todas
as tabelas foram carregadas pelo mecanismo normal levelFolder; os contratos
públicos e internos de número de níveis coincidem. Os modos de um/dois jogadores
usam playerCount pelo ciclo stop/start. Estas seleções são fixtures explícitas,
não gestos exaustivos do diálogo de opções.

## Evidência e reprodução

[Índice verificável](index.json), [resumo do gameplay](sealed-gameplay/summary.json)
e [procedimento](../../../tests/functional_memory_math/README.md). O índice recusa
aprovação se faltar um caso, houver erro Qt, hash de caso diferente, rede ativa
ou contagem incompleta. Cada resultado identifica o caso, QM, binário e recursos.

Todos os casos usam o mesmo snapshot completo/selado de 269 ficheiros, perfil
novo PT-PT e Docker sem rede. [Manifesto original](resource-manifest.json),
[identidade de 16 RCC recompilados/442 fontes](build-identity.json) e
[ambiente Linux x86-64/Qt 6.10.2](environment.json). O build principal não foi
alterado. A aplicação real executou cartas, timers, Score e Bonus.

Os checkpoints dos commits 51e974135, 73d166e00 e 81b7675fa preservaram quatro,
sete e onze variantes aprovadas, com os restantes casos expressamente pendentes.
O índice final substitui esses totais parciais. As calibrações do diálogo inicial
e do observador de Bonus ficaram no build privado, fora da aceitação. Não foi
identificado defeito de produção neste lote; só testes/documentação foram criados.

## Limites

A aleatoriedade original do Tux foi preservada; estes resultados não cobrem todas
as sequências aleatórias possíveis. As animações e os turnos não foram encurtados.
Os casos correm em Qt offscreen, sem som físico. Não certificam teclado/rato
físicos, pronúncia, Windows 10 x64, escola ou revisão pedagógica. Os gestos do
seletor de tabelas/opções e a aceitação global Linux continuam pendentes.
