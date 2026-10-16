# Spec da tarefa 52

Base `5eac6b723`, merge `fb5e6bfb1face15a6c42ee08e5912dcb8af9035b`.
Revisão independente do ticket, diferenças PO, dados, casos, auditores,
README e índice. Sem novas campanhas Qt ou escrita de fontes/índices.
A tarefa 53 da minha autoria e alterações alheias de sincronização estão
excluídas.

Não encontrei achados acionáveis contra a aceitação delimitada.

Conferi os seis recibos finais e todos os hashes de artefactos do índice.
Passam com código zero, sem erros QML ou timeout. Os três percursos cobrem
os oito níveis numéricos, oito alfabéticos e vinte de frases, totalizando 36
rejeições e 636 arrastos. Os três controlos adicionais têm arrasto parcial,
configuração persistida, exclusão/restauro de conjunto, reinício, navegação,
ajuda PT e regresso ao menu.

O solver usa os rótulos realmente renderizados. Ordena números numericamente,
letras pelo alfabeto explícito e direção da instrução visível. Para as frases,
o vocabulário de referência contém orações PT completas e reconstrói cada saco
de cartões visíveis, incluindo grupos. Não usa originalArrangement, índice
de solução ou elementValue como resposta. Os modelos internos são observados
para confirmar o efeito, sem escrita de estado nem chamada de validadores.
Os negativos preservam os mesmos cartões, trocam dois e verificam Bonus e
bordos; o percurso correto progride naturalmente e regressa ao primeiro nível.

O auditor de dados separa as 16 pastas, intervalos/capacidades, oito alfabetos
e vinte frases. A alteração de produção limita-se ao PO: quatro frases foram
ajustadas às bandas explícitas 3–5 e 6–10 palavras e dois objetivos passaram a
ser inclusivos. O vermelho anterior e o inventário Qt dos cartões sustentam
a correção; o motor JS permanece intacto. A revisão docente da clareza das
frases corrigidas continua pendente.

O relatório delimita uma amostra por nível aleatório, sem afirmar todas as
combinações ou todas as permutações linguisticamente válidas. As letras
expostas são minúsculas a-z; acentos/cedilha/maiúsculas são exercitados nas
frases. O fundo original tem Image.Ready e bytes QRC conferidos. Ausência
de vozes nestes jogos, execução muda, Windows, touch, hardware e audição física
continuam separados. Não há declaração de aceitação global.
