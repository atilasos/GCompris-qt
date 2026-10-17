# Possibilidade de integrar jogos CRJM no GCompris

Data: 2026-10-17. Âmbito confirmado: integração no nosso fork do GCompris, sem proposta upstream. Análise de viabilidade; não implementa atividades nem altera licenças.

## Conclusão

É tecnicamente viável criar atividades nativas GCompris a partir dos jogos
CRJM, aproveitando regras, posições de teste e desenho pedagógico. A interface
React e os serviços da aplicação não são diretamente reutilizáveis em QML.
Recomendo Dominório como primeiro piloto, seguido de Gatos & Cães e Faísca.
Quelhas e Atari Go são boas extensões; Produto requer uma introdução guiada;
Y e sobretudo Nex devem ficar para uma fase posterior.

No nosso fork podemos integrar os oito jogos e definir um público mais amplo
do que o da distribuição oficial. A prioridade abaixo serve para fasear o
trabalho, não para excluir jogos. A política de aceitação de código gerado por
IA e a aprovação dos mantenedores upstream não condicionam esta integração.
Se o fork for distribuído, os componentes reutilizados precisam de termos
compatíveis com as licenças do conjunto; o licenciamento atual não foi alterado.

## Bases verificadas

- CRJM local: `/home/proteu/crjm`, remoto `git@github.com:atilasos/crjm.git`.
- HEAD local e `main` remoto coincidem em
  `b206a7b4948673be935a5cb6a5a84df92d3ba6c2`, confirmado por `git ls-remote`.
- GCompris local: `fb7722af3e8046f9ed4a13511b8e18af630d342d`.
- Foram lidos README, licença, regras/tipos dos oito jogos, exemplos de IA,
  puzzles, documentação de domínio e ADR-001/003 do CRJM; ActivityInfo,
  QML/JavaScript e registo CMake de atividades de estratégia do GCompris.
- A aplicação publicada foi inspecionada no browser colaborativo T3:
  página inicial e interfaces de Dominório, Atari Go e Faísca. Não foram
  concluídas partidas, criados torneios ou alterados serviços.
- Os oito ficheiros `src/games/*/logic.test.ts` passaram: **187 testes,
  zero falhas, 5512 verificações, 8,44 s**. Não se executaram a suite completa,
  arenas de força, build Rust/WASM nem testes em Qt; estes resultados validam
  a base de regras testada, não uma portabilidade ainda inexistente.
- O leitor web do GitHub devolveu um README antigo com seis jogos. Para o
  inventário atual prevaleceram o commit confirmado e o código local, que
  incluem também Faísca e Y. A aplicação publicada confirma os oito.

## Inventário e prioridade proposta

As prioridades e adequação abaixo são apreciações desta análise. Os ciclos
da competição não são equivalentes a uma idade mínima pedagógica universal.
O público declarado do GCompris oficial é 2–10 anos; o nosso fork pode
alargar essa faixa. Os jogos mais avançados podem ficar numa secção própria
de jogos matemáticos, com níveis introdutórios e partidas de campeonato.

| Jogo | Situação CRJM | Base observada | Adequação e adaptação | Esforço relativo / prioridade |
|---|---|---|---|---|
| Dominório | Atual, 1.º ciclo | 8×8; dominós verticais contra horizontais; perde quem não puder jogar | Forte relação com orientação, espaço e antecipação; começar com posições curtas e indicação visual das duas casas | Menor para regras/UI; médio com IA e acabamento. **1** |
| Gatos & Cães | Arquivo jogável, anteriormente 1.º ciclo | 8×8; colocação sem vizinhança ortogonal entre espécies; abertura especial | Metáfora acessível e uma escolha por turno; desenhos próprios e casas permitidas visíveis ajudam a introdução | Menor–médio. **2** |
| Faísca | Atual, 1.º/2.º ciclos | 5×6; setas com distância 1/2/3, reservas, destino obrigatório; duas dificuldades locais | Excelente ligação a direção, contagem e previsão; mostrar destino antes de confirmar e ensinar reservas por etapas | Médio. **3** |
| Quelhas | Atual, 1.º–3.º ciclos | 10×10; segmentos de comprimento ≥2, orientações distintas e troca inicial; regra misère | Boa extensão de Dominório; destacar que perde o último a jogar e introduzir a troca separadamente | Médio–alto: seleção de segmentos, finais e IA. **4** |
| Atari Go | Atual, 3.º ciclo/secundário | 9×9 nas interseções; grupos, liberdades e vitória na primeira captura | Pode servir crianças mais novas com problemas de uma captura e liberdades destacadas; a indicação CRJM atual é mais velha | Médio–alto. **5** |
| Produto | Atual, 2.º/3.º ciclos/secundário | 61 casas hexagonais; duas colocações por turno salvo abertura; ambas as cores; produto dos dois maiores grupos | Interesse matemático direto para multiplicação; começar por contar grupos e prever a pontuação, antes da partida completa | Alto. **6** |
| Y | Atual, secundário | Grafo de 93 nós/252 ligações; unir os três lados num único grupo; troca inicial | Objetivo simples de enunciar, mas tabuleiro grande e irregular; introdução com percursos curtos e cores/formas distinguíveis | Médio–alto; prioridade pedagógica menor. **7** |
| Nex | Arquivo jogável, anteriormente secundário | 11×11 hexagonal; peças próprias/neutras, colocação/substituição, troca e conexão | Maior carga de regras e jogadas compostas; pouca vantagem como primeiro contributo para 2–10 anos | Alto. **8** |

Tabuleiros menores seriam variantes didáticas a validar, não o regulamento
oficial CRJM. O primeiro piloto pode conservar as regras e o tabuleiro 8×8,
usando posições parcialmente preenchidas para obter desafios curtos.

Fontes por jogo: [catálogo CRJM](https://github.com/atilasos/crjm/tree/b206a7b4948673be935a5cb6a5a84df92d3ba6c2/src/games),
os respetivos `types.ts`, `logic.ts` e testes; [README do commit](https://github.com/atilasos/crjm/blob/b206a7b4948673be935a5cb6a5a84df92d3ba6c2/README.md).

## Encaixe no catálogo GCompris

O checkout contém xadrez, damas, quatro em linha, jogo do galo, moinho,
Oware e Bargame, incluindo variantes contra Tux e para duas pessoas.
Não foi encontrada uma atividade equivalente a qualquer dos oito jogos CRJM
nesse catálogo. Isto refere-se ao checkout analisado, não a todos os trabalhos
externos ou propostas pendentes. `hexagon` é um jogo de encontrar um morango,
não um jogo de conexão Hex.

Dominório e Gatos & Cães acrescentariam jogos de bloqueio espacial. Quelhas
aprofundaria a estratégia misère que já aparece no Bargame, com geometria
diferente. Produto acrescentaria cálculo de grupos associado à multiplicação.
Pistas H1/H2/H3 e revisão do CRJM são uma contribuição pedagógica relevante,
mas devem ser apresentadas progressivamente para evitar uma interface densa.

Referências locais: `src/activities/*/ActivityInfo.qml`, em especial
`bargame`, `oware`, `nine_men_morris`, `hexagon` e `align4`.

## O que se pode aproveitar e o que muda

| Parte CRJM | Tratamento proposto no GCompris |
|---|---|
| Regras TypeScript | Adaptar para JavaScript compatível com Qt; remover tipos e rever importações, APIs e representação do estado. Reutilização condicionada à licença e à proveniência |
| Testes e posições de referência | Conservar cenários de abertura, jogada ilegal, alternância, troca e final; comparar resultados da implementação Qt com a referência |
| Puzzles e pistas | Adaptar conteúdos e posições para níveis interativos, instruções curtas e ajuda visual; não transportar só questionários longos |
| Componentes React/Tailwind/SVG interativo | Recriar interface em QML com componentes e navegação GCompris; recursos gráficos só após verificar a licença |
| Web Workers, DOM, AbortSignal e performance.now | Rever execução e cancelamento; não são uma camada diretamente transportável para o runtime QML |
| Rust/WASM e IA avançada | Adiar no piloto; usar IA local limitada e medir em dispositivos modestos. Integração nativa adicional só se houver necessidade demonstrada |
| Perfil, XP, autenticação, SQLite e torneios | Manter na aplicação CRJM; a atividade GCompris deve usar as capacidades e a persistência do anfitrião |
| Catálogos PT-PT/EN/NE | Reaproveitar texto autorizado como base editorial e integrar no sistema de tradução Qt/KDE, com `qsTr` e comentários para tradutores |

A lógica já tem separação útil da UI, especialmente em Dominório, Gatos & Cães,
Faísca e Y. Porém, `quelhas/logic.ts` também importa o motor de IA e mistura
regras com avaliação estratégica: não basta copiar todos os `logic.ts`.
O grafo de Y deve preservar as arestas explícitas de `board.ts`; proximidade
visual não define adjacência. Nex usa índices `tabuleiro[x][y]`, outra
particularidade a preservar numa adaptação.

Não recomendo incorporar a aplicação React numa WebView: o build local usa
Qt Quick e não declara Qt WebEngine entre as dependências consultadas; essa
via acrescentaria runtime web e manteria uma experiência distinta da suite.

Exemplo concreto a seguir: `align4/Align4.qml` herda a atividade de duas
pessoas em `align4_2players/Align42players.qml`. Esta usa `ActivityBase`,
JavaScript próprio, teclado, ciclo start/stop e recursos registados por CMake.
Um Dominório pode adotar o mesmo princípio de partilhar o tabuleiro e as regras
entre as variantes contra Tux e para duas pessoas.

## Licença e âmbito do fork

1. A [licença CRJM](https://github.com/atilasos/crjm/blob/b206a7b4948673be935a5cb6a5a84df92d3ba6c2/LICENSE)
   proíbe venda e uso comercial, inclusive derivados. O
   [README GCompris](../../../README.md) declara código interno GPL-3.0-or-later
   e distribuição global AGPLv3. Os termos atuais não permitem simplesmente
   incluir o código CRJM como componente GPL do GCompris.
   Antes de copiar código/conteúdos, verificar titulares, contribuições e
   recursos de terceiros e conceder uma licença compatível aos componentes
   escolhidos. Se todos os direitos relevantes forem teus, pode ser considerada
   uma licença adicional apenas desses componentes; não é obrigatório mudar
   a licença de toda a plataforma. Não foi feita auditoria completa de direitos.
2. Apenas como contexto upstream, o [README upstream](https://github.com/gcompris/GCompris-qt/blob/master/README.md#about-ai-contributions)
   diz: “GCompris does not accept any contribution made using AI to generate
   code.” Logo, uma adaptação gerada por IA não deve ser submetida como MR.
   Esta é uma política de aceitação do projeto oficial, não uma limitação
   técnica nem uma condição aqui adotada para o nosso fork. Não há plano de MR
   upstream neste trabalho.
3. Não é necessária aprovação dos mantenedores oficiais para desenvolver
   estas atividades no nosso fork. Nenhum contacto externo foi efetuado.

As ADR-001 e ADR-003 do CRJM mantêm React e progresso centrado no aluno como
decisões da plataforma CRJM. A proposta é uma atividade separada no GCompris,
não uma migração/substituição dessa plataforma; por isso não revoga essas ADRs.

## Piloto recomendado

1. Preparar o enquadramento de Dominório: objetivos espaciais, público,
   regras, atribuições e origem dos componentes. Para distribuição, verificar
   direitos e licença dos componentes escolhidos; não há submissão upstream.
2. Criar atividade nativa para duas pessoas, com tabuleiro 8×8, indicação das
   duas casas do dominó, orientação do turno e finais corretos. Introduzir
   primeiro posições curtas; distinguir exercícios de partida completa.
3. Acrescentar Tux com poucas dificuldades compreensíveis, ajuda opcional
   e um problema de revisão. Não é necessário transportar os cinco níveis
   competitivos nem a plataforma de torneios.
4. Verificar equivalência das regras, rato/toque/teclado, tradução, pausa,
   saída/reinício e cancelamento da IA; medir responsividade em equipamento
   modesto. Um Timer que dispara uma busca longa não evita bloqueio da UI.
5. Observar crianças a usar o piloto e ajustar as instruções/dificuldade.
   Só depois replicar a estrutura para Gatos & Cães e Faísca. Continuar com
   Quelhas/Atari Go e depois Produto/Y/Nex, mantendo os jogos avançados
   disponíveis para alunos mais velhos no fork.

Esforço classificado apenas em termos relativos: faltam um protótipo Qt
e medições para estimar prazos com confiança.

## Evidência complementar

- [Requisitos e fontes GCompris](requisitos-gcompris.md).
- [Regras oficiais CRJM](https://projetosdre.madeira.gov.pt/crjmram/jogos/)
  são a referência a consultar durante a implementação; nesta análise as
  particularidades de regras foram verificadas contra o código e os testes
  locais, sem nova auditoria integral dos regulamentos.
- Screenshot da inspeção de Dominório:
  `/home/proteu/.t3/userdata/browser-artifacts/browser-screenshot-crjmai-infantinho-xyz-mvcmjap7-69ceb84d.png`.

Foram produzidas apenas notas de investigação no GCompris. O código dos dois
projetos e as respetivas licenças foram preservados.
