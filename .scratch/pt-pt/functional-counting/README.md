# Contagem, dados e dominós, tarefa 46

Os 14 casos finais do índice terminaram com código zero, sem erros QML,
timeout ou deployment retido. Há 848 puzzles completos na campanha principal
e 174 puzzles em tracers separados sem teclado visual. Não há processos nativos
pendentes. Não foi necessário alterar produção.

| Jogo | Datasets | Níveis de execução | Opções principais | Puzzles |
|---|---:|---:|---|---:|
| enumerate | 4 | 14 | automática e botão OK | 128 |
| smallnumbers | 8 | 9 | face superior dos dados | 144 |
| smallnumbers2 | 8 | 9 | pontos, algarismos, romanos, imagens | 576 |

O primeiro dataset dos jogos temporizados produz dois níveis; os outros sete
produzem um cada. Os oito identificadores estáticos não limitam a sequência a
oito níveis. Os três seletores foram operados pela UI, incluindo scroll até à
última entrada, desativação/gravação e reposição. Os totais mudaram 14→10→14
nos frutos e 9→8→9 nos dados/dominós. Não se alterou metadados.

## Oráculo e ações

Os frutos são contados pelas instâncias Image efetivamente desenhadas e pela
origem da imagem de cada resposta. Uma ilustração de cacho conta como uma
instância, conforme o jogo. Há um arrasto real de reorganização por puzzle,
uma resposta errada e a resposta certa por linha; no modo OK, a rejeição é
confirmada depois de carregar no botão. Controles separados verificam escolha
de linha por cima/baixo, ajuda PT, foco após ajuda, reinício de resposta parcial
e arrasto, anterior/próximo e menu, com ambas as preferências de teclado.

Nos dados, o oráculo XML conta subpaths claros da face superior do SVG, sem
usar o algarismo no nome do ficheiro e sem contar as faces decorativas. Nos
dominós, soma os pontos visíveis dos dois grids, rótulos arábicos/romanos ou
instâncias da borboleta visível. Não lê answerToFind, word.text, dominoValues
ou validadores do motor para escolher respostas. Os testes não preparam o
modelo, não escrevem progresso e não encurtam animações ou temporizadores.
Cada resposta temporizada inclui uma tecla errada rejeitada e movimento real
observado. A pontuação e a transição natural confirmam aceitação. Nos frutos,
Bonus é observado explicitamente; nos jogos temporizados, a progressão natural
que passa por Bonus é confirmada pela mudança de nível, sem contador separado
do sinal win.

A campanha principal usa velocidade normal 10 e alterna teclas Qt e cliques
no teclado visual. Os tracers com preferência visual desligada percorrem os
primeiros três níveis, em ambas as validações dos frutos e nas quatro
representações do dominó, totalizando 174 puzzles. Não são segundas campanhas
completas. Nos recibos antigos dos jogos temporizados, o campo virtualKeys
regista a paridade pretendida; o caso arquivado aplica também visualPreference
false antes de escolher a via real. Esses tracers usam exclusivamente keyClick.
O template atual regista a expressão completa para evitar essa ambiguidade.

Controls opera cada velocidade 1–10 pela UI, verifica valor persistido e
movimento durante um segundo. O objeto percorre cerca de 1,7 px na velocidade 1
e 17,2 px na 10. Uma perda sem resposta demora cerca de 45,6 s em cada motor;
o objeto sai naturalmente, sem pontuação. A seguir, oito respostas contadas
completam o nível e recuperam a progressão. Não se testou o produto cartesiano
de todas as velocidades com todos os puzzles. As observações destes dois
casos estão no marcador original do native.log e foram extraídas pelo coletor;
o result.json original conserva os totais Qt genéricos desses lançamentos.

## Vermelhos e limites

As seis regressões de oráculo passaram; incluem rejeição de contagem adulterada,
rótulo incompatível e soma incorreta. O teste CLI rejeita opções incompatíveis
antes de criar saída. O vermelho inicial de módulo ausente precedeu o oráculo.

`panel-race-red` e `panel-race-green` provam uma condição de prontidão do teste:
no vermelho, a pressão começa com opacity 0,9 e não ativa Drag; no verde,
espera opacity 0 e ativa o arrasto. O helper passou a aguardar o fim da animação.
Não é um defeito de produção. A primeira campanha automática parou após 49
puzzles sem stack útil; essa asserção não foi atribuída retroativamente à
corrida. O recibo automático final estabilizado completou os 64 puzzles.
`enumerate-level12-diagnostic` é um nome histórico incorreto: a configuração
reiniciou no primeiro nível, pelo que esse recibo não prova isolamento do 12.
As campanhas completas cobrem o12. O primeiro controls também assumiu um nível
inicial não observado; o caso final navega com botões reais até ao nível 5.
Estes diagnósticos e calibrações não integram os 14 recibos aprovados.

A cópia selada tem 269 entradas físicas; os 335 ficheiros expostos nos cinco RCC
privados foram comparados à fonte. Manifesto, inventário, identidades e hashes
ficam nesta pasta. Docker sem rede, host só leitura, perfil/saída privados RW,
UID/GID1000; todos os 14 recibos confirmam dono e limpeza. A imagem efetiva é
sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b.
O catálogo PT foi recompilado privadamente pelo launcher, sem escrever no build
principal. Os desenhos aleatórios observados não representam todas as posições
ou partições possíveis. Não há audição física, aprovação de pronúncia,
Windows, hardware, touch/mobile, variações DPI/orientação ou revisão pedagógica.
