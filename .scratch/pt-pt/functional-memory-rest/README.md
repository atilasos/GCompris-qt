# Cinco variantes restantes de memória — tarefa 37

Concluída a verificação funcional nativa delimitada em Linux, PT-PT, offline,
com perfil novo e recursos privados imutáveis. A aceitação global permanece
pendente de Windows 10/escola, dispositivos físicos e revisão docente.

| Atividade | Níveis | Modos | Percursos |
|---|---:|---|---:|
| memory | 6 | 1 e 2 jogadores | 12 |
| memory-tux | 6 | contra Tux | 6 |
| memory-sound | 7 | 1 e 2 jogadores | 14 |
| memory-sound-tux | 7 | contra Tux | 7 |
| memory-case-association-tux | 4 | contra Tux | 4 |

Os 43 percursos completaram os 294 pares previstos nos níveis e mais nove
pares em três derrotas deliberadas contra Tux. Foram observados 292 pares
resolvidos pelo jogador, 11 por Tux, 82 pares errados/terceiros cliques
bloqueados, 50 turnos Tux, 43 Bonus bons e três maus. Não houve perda natural
intermédia neste sorteio. As derrotas forçadas verificam repetição do mesmo
nível e reposição das pontuações, sem manipular o adversário ou o RNG.

Os casos verificam exposições de 500 ms, resolução só após o temporizador
original de 1500 ms, bloqueio durante Tux, cartas já encontradas, quatro setas,
Space/Enter/Return, pontuação de ambos os jogadores, total público de níveis,
transições e retorno ao primeiro nível. Reinício com seleção/temporizador/turno
pendentes, ajuda, botões de nível e Home/Escape têm casos separados. O seletor
de 1/2 jogadores foi operado pela interface nos dois jogos que o expõem,
incluindo gravação e leitura da configuração persistida. Não há seletor de
datasets nestas cinco atividades; o inventário verifica todos os dados.

## Imagens, sons e limites da observação

O auditor de dados verifica seis/sete/quatro grelhas, 21 pares de imagens
originalmente distintos, 30 pares de sons distintos e as 26 correspondências
maiúscula/minúscula. Os nomes das vozes executam a função core original:
`Core.getSoundFilenamForChar` normaliza para minúscula. O stub antigo da prova
21 não é usado como referência para os nomes físicos de áudio nesta tarefa.

O caso nativo lê o Image original de cada carta, exige status Ready e copia os
bytes do QRC realmente registado. O GCAudio e o MediaPlayer originais são
observados sem substituição: rota solicitada, PlayingState, posição positiva,
duração e hasAudio. Não foram observados erros de descodificação. O primeiro
som selecionado pelo jogador tem de atingir esse estado antes do segundo
clique; as interrupções normais de fontes rápidas continuam permitidas.

`gameplay-audit.json` confere 115 recursos efetivamente observados: 58 imagens
(21 desenhos, 36 glifos sorteados e um ícone), 30 sons, 18 vozes de letras e
nove vozes PT de feedback. Todos os 30 sons distintos atingiram reprodução e
posição positiva; 18 das 26 letras foram sorteadas e reproduzidas. Os outros
oito nomes físicos existem no RCC e são verificados pelo inventário de dados,
mas não têm prova de reprodução nesta execução. Não se declara audição física
ou aprovação de pronúncia das 26 gravações existentes. A aprovação docente das
32 vozes novas pertence à tarefa 35 e não se estende a estas gravações.

## Provas e identidade

Os casos/resultados/logs guardam hashes do executável, snapshot, fonte QML,
RCC privado, caso combinado e catálogo PT/QM recompilado privadamente.
`resource-snapshot.json` identifica as 269 entradas da cópia independente;
`source-identity.json` e `gameplay-audit.json` conferem os sete RCC contra os
296 ficheiros fonte que Qt realmente expõe. Nenhum teste escreve no build
principal. `index.json` relaciona os 25 casos finais e os hashes dos artefactos.
A reprodução está em `tests/functional_memory_rest/README.md`.

As duas correções PO têm red/green próprios em `help-review.md`: limite de duas
cartas na ajuda de imagens e concordância «os gémeos» na ajuda de sons. Não há
outra alteração de produção desta tarefa.

Um fixture inicial de Escape descarregava diretamente o Loader do aviso áudio,
saltando GCDialog.stop() e deixando as teclas do ActivityBase desativadas.
`home-diagnostic` conserva essa falha de teste; `home-warning-green` fecha o aviso
pela própria tecla Escape e passa nas cinco atividades, sem mudança no produto.
O helper atual faz esse fecho real. Os 43 percursos longos preservam os seus
casos combinados exatos anteriores: as setas/seleções do filho foram efetivamente
exercitadas; a prova de Escape pertence aos cinco casos corrigidos separados.
Os casos curtos controls/restart/audio foram repetidos com o helper corrigido.
As calibrações anteriores não contam como aprovações e permanecem fora do pacote.

Não foram testados gestos multitoque, orientação vertical, teclado/rato físicos,
audição por altifalante, Windows nem a navegação de uma sequência curricular
completa. Os seletores e gestos normais deste lote estão cobertos; os limites
não são convertidos em aprovação global no CSV.
