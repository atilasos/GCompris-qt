# CRJM → GCompris: requisitos e adequação

Data: 2026-10-17. Âmbito atualizado: integração no nosso fork, sem contribuição upstream. Pesquisa apenas documental; nesta subpesquisa não foram executados os jogos nem alterado código. A pesquisa principal realizou verificações adicionais descritas em `analise.md`.
Base local GCompris: `fb7722af3e8046f9ed4a13511b8e18af630d342d`.

## Conclusão

É tecnicamente possível criar atividades GCompris com estes jogos, mas a passagem seria uma adaptação nativa para Qt Quick/QML e JavaScript. O melhor piloto é Dominório; Gatos & Cães, Faísca e Quelhas merecem avaliação pedagógica seguinte. Produto, Atari Go, Y e Nex têm menor adequação imediata à faixa etária declarada pelo GCompris. Esta ordenação é uma apreciação de adequação, não uma decisão dos mantenedores. [1][2][3]

Para o nosso fork, a aprovação upstream e a política de aceitação de código gerado por IA não são requisitos. Os oito jogos podem ser integrados e a faixa etária pode ser alargada. Se houver distribuição, é necessário assegurar licenciamento compatível dos componentes. Apenas no cenário separado de contribuição oficial: a licença CRJM contém restrições comerciais incompatíveis com a liberdade de redistribuição pretendida pelo GCompris, pelo que a reutilização exige autorização/licenciamento adequado pelos titulares; e o README oficial recusa contribuições com código gerado por IA. A análise atual não é uma autorização de inclusão nem uma promessa de aceitação upstream. [1][4][5]

## Público e jogos existentes

O GCompris declara público dos 2 aos 10 anos. Ter jogos abstratos complexos não é excluído por princípio: o catálogo local inclui xadrez (difficulty 6), damas (4), moinho (3), oware (3), quatro em linha, jogo do galo e bargame (2). O padrão comum é oferecer versões contra Tux e com um amigo no mesmo dispositivo. As dificuldades são metadados da suite, não idades ou números de níveis. [1][2][6]

Não encontrei atividades equivalentes exatas aos oito jogos CRJM na listagem local `src/activities/activities.txt` e nos `ActivityInfo.qml`. Bargame é um jogo de colocação de bolas numa fila em que se evita a última casa: partilha raciocínio misère com Quelhas, mas não as regras nem o tabuleiro. `hexagon` é encontrar um morango através de campos mais quentes/frios; não é o jogo de ligação Hex e não equivale a Y, Nex ou Produto. [6][7]

| CRJM | Público declarado no README CRJM | Adequação inferida à suite | Aspeto a adaptar |
|---|---|---|---|
| Dominório | 1.º ciclo | Alta, primeiro piloto | Orientações vertical/horizontal muito visíveis, pequenos tabuleiros, tutorial de bloqueio |
| Gatos & Cães | Anteriormente 1.º ciclo | Alta | Apresentação visual das restrições e jogadas legais; continua válido apesar de estar no Arquivo |
| Faísca | 1.º e 2.º ciclos | Boa, com introdução guiada | Distinguir colocação obrigatória de escolha de destino |
| Quelhas | 1.º, 2.º e 3.º ciclos | Boa, com progressão cuidadosa | Reforçar que perde quem faz a última jogada; evitar confusão com vitória convencional |
| Produto | 2.º ciclo a secundário | Média/baixa para proposta inicial | Pontuação por produto de grupos e ligação de grupos adversários requer introdução forte |
| Atari Go | 3.º ciclo e secundário | Média/baixa inicialmente | Liberdades e captura em pequenos problemas antes de partida livre |
| Y | Secundário | Exploratória | Ligações dos três lados e regra de troca de cores; conservar grafo correto |
| Nex | Anteriormente secundário | Exploratória | Regras de ligação/conversão e maior carga conceptual |

A associação entre ciclos e jogos vem do CRJM; a avaliação de adequação é nossa e deve ser validada com crianças/professores. Não se deve confundir a simplicidade aparente das regras com a faixa etária da competição. [3]

## Forma técnica de integração

A árvore atual usa Qt 6 (mínimo geral 6.5) e C++17; o template de atividades usa QML para a interface, `.js` para lógica e APIs comuns `ActivityBase`, `GCText`, `Bar`, `DialogHelp` e `Bonus`. A atividade tem início/paragem explícitos, níveis e retorno ao menu. O seu `ActivityInfo.qml` declara nome, ícone, autor, dificuldade, título, objetivo, pré-requisitos, manual, créditos e secção; os textos localizáveis usam `qsTr`. Os recursos são declarados por `CMakeLists.txt` e a atividade integra `activities.txt`. [8][9][10]

A UI React/TypeScript/Tailwind do CRJM não entra diretamente neste modelo. Regras e algoritmos puros podem orientar uma adaptação para JavaScript suportado pelo Qt; não basta copiar TSX ou depender do bundler Bun. Os motores Rust/WASM e workers de browser também não têm carregamento direto demonstrado neste checkout. Para uma primeira atividade, regras + IA local pequena são uma escolha mais simples; uma integração C++ de motores deve ser avaliada separadamente quando justificada. São conclusões técnicas da comparação de stacks, não requisitos formais publicados pelos mantenedores. [3][8][9]

O exemplo quatro em linha demonstra reutilização: `align4/Align4.qml` instancia a atividade comum `Align42players` com `twoPlayer: false`. Esta estrutura pode inspirar variantes de uma mesma atividade contra computador e entre dois participantes. [11]

Recomenda-se que o primeiro piloto contenha apenas jogo local, ajuda visual, tutorial e níveis graduais. Torneios WebSocket, contas, XP e serviços GPU são capacidades do produto CRJM separadas; não são dependências necessárias para ensinar estes jogos no GCompris. Uma versão local para crianças deve continuar funcional sem esses serviços. Esta é uma proposta de âmbito, baseada no formato das atividades existentes. [3][6][9]

## Licença de distribuição e contexto upstream

O README oficial declara AGPLv3 para o conjunto e GPLv3+ para o código interno, com a biblioteca da eletricidade analógica como motivo da AGPL do conjunto. O template especifica `GPL-3.0-or-later`; os recursos e componentes têm licenças próprias. O LICENSE CRJM autoriza uso educativo e proíbe venda e utilização comercial. Antes de copiar código, imagens, textos de regras ou motores é necessário esclarecer direitos de cada origem e disponibilizá-los sob termos compatíveis com a distribuição do fork. Não basta acrescentar um cabeçalho GPL a código com termos anteriores incompatíveis. [1][4][5][9]

O README upstream contém uma política explícita contra código gerado por IA. Assim, uma eventual implementação produzida por este agente não deve ser apresentada como contribuição aceitável ao GCompris oficial. Uma proposta conceptual, avaliação pedagógica e conversa humana com os mantenedores são passos distintos de gerar código para MR. Não foram contactados mantenedores nem aberta MR. [1]

O README encaminha novos contribuidores para a wiki KDE de processo de desenvolvimento. A página respondeu 403 na consulta efetuada, por isso não confirmámos requisitos editoriais adicionais, sequência de revisão ou aprovação de novas atividades. Devem ser verificados antes de planear trabalho upstream. [12]

## Referências

1. [README oficial GCompris, incluindo licença e política IA](https://github.com/gcompris/GCompris-qt/blob/master/README.md), confirmado online em 2026-10-17; equivalente local `README.md`.
2. [Apresentação oficial GCompris](https://www.gcompris.net/index-en.html), público 2–10 anos e categorias.
3. [README CRJM](https://github.com/atilasos/crjm/blob/main/README.md), conteúdo efetivamente lido em `/home/proteu/crjm/README.md`; a pesquisa principal confirmou HEAD local/remoto `b206a7b4948673be935a5cb6a5a84df92d3ba6c2` (não confiar no README antigo de seis jogos devolvido pela cache web).
4. `/home/proteu/crjm/LICENSE`, licença educativa local, secções Uso permitido e Uso proibido.
5. `LICENSES/GPL-3.0-or-later.txt`, licença GPL incluída no checkout (secções 4 e 10: cobrança permitida, sem restrições adicionais); [definição GNU de software livre](https://www.gnu.org/philosophy/free-sw.en.html), que declara que restrições de uso/distribuição comercial tornam o software não livre; `README.md` secção Licence.
6. `src/activities/*/ActivityInfo.qml`, inventário completo das atividades da secção strategy; exemplos [xadrez](https://github.com/gcompris/GCompris-qt/blob/master/src/activities/chess/ActivityInfo.qml), [damas](https://github.com/gcompris/GCompris-qt/blob/master/src/activities/checkers/ActivityInfo.qml), [oware](https://github.com/gcompris/GCompris-qt/blob/master/src/activities/oware/ActivityInfo.qml).
7. [Bargame](https://github.com/gcompris/GCompris-qt/blob/master/src/activities/bargame/ActivityInfo.qml), [Hexagon](https://github.com/gcompris/GCompris-qt/blob/master/src/activities/hexagon/ActivityInfo.qml); verificados nos ficheiros locais homónimos.
8. `CMakeLists.txt`, linhas 15–16, 56 e 101–105.
9. [Template nativo](https://github.com/gcompris/GCompris-qt/tree/master/src/activities/template), ficheiros locais `ActivityInfo.qml`, `Template.qml`, `template.js`.
10. `src/activities/CMakeLists.txt` e `src/activities/activities.txt`; [recursos de quatro em linha](https://github.com/gcompris/GCompris-qt/blob/master/src/activities/align4_2players/CMakeLists.txt).
11. [Align4.qml](https://github.com/gcompris/GCompris-qt/blob/master/src/activities/align4/Align4.qml) e `src/activities/align4_2players/Align42players.qml` locais.
12. [Processo oficial de novas atividades](https://invent.kde.org/education/gcompris/-/wikis/Developers-corner/Development-process), referência do README, consulta bloqueada por 403.
