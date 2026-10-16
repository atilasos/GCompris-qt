# Spec final da tarefa 38

Base de checkpoint `ca1d63b5c`, tip `b698b1b004dc744eac914bea9887ae1ff9add77e`,
conteúdo principal `b3c28ffb0`. Revisão independente de conclusão, provas,
retoma, agregador e seleção CLI. Excluí alterações alheias trazidas pela
sincronização e a tarefa 53 da minha autoria. Sem novas campanhas Qt ou
alteração de índices. As correções de produção anteriores não foram reabertas.

Não encontrei achados acionáveis neste incremento.

Conferi os hashes de todas as entradas do índice final contra os blobs do tip.
As três origens Hangman conservam oito, 84 e 24 recibos completos, com nomes
disjuntos, totalizando 116 campanhas e 4824 palavras. Cada recibo tem resultado
positivo, código zero, sem timeout ou erros QML; o SHA coincide com o resumo.
O agregado conserva ausência de campanhas em falta e de erros. As 174 provas
de Letra na palavra também têm SHA e resultado positivos, totalizando 1740
perguntas. A matriz documentada corresponde às 23 lições completas e seis
incorporadas nas combinações publicadas.

O agregador valida a identidade da campanha contra dataset, lição e pistas,
recorre ao oráculo do corpus para palavras/ordinais e rejeita conjuntos
incompletos ou repetidos. Confere hashes de relatório/caso, identidade de
recursos, fontes congeladas e launcher. Os dois negativos conservados recusam
falta e duplicação. Os oito recibos anteriores foram aproveitados sem criar
campos de identidade novos ou contar logs interrompidos como conclusão.

O seletor --dataset restringe as lições antes da preparação e tem regressão
CLI específica. O corpus completo restante e as 24 combinações incorporadas
ficam separados. O texto explica a interrupção do executor e os heartbeats,
sem inventar sinal de terminação ou atribuir falha ao jogo. Não se apoia numa
sessão supostamente viva depois de FINAL.

As afirmações permanecem delimitadas: um tabuleiro aleatório por combinação
em Letra na palavra, alternância de canais por caráter sem produto cartesiano,
recursos disponíveis sem aprovação semântica de cada associação. Os pares
fawn/corso e tick/piolho continuam na tarefa 44. A conclusão não aprova
pronúncia/audição física, dispositivos, Windows, professor ou as 203 atividades.
