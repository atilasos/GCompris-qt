# Spec — lote incremental 40

Base: `44503ab92`. Tip: `12011a2641d60fb690becb9146c70d8747d20bb6`.
Excluí integralmente a tarefa 34, da minha autoria. Esta revisão cobre apenas
37 PO, 38 corpus/contagem, 39 provas e 40 contrato. Não executei novos ensaios
Qt; confrontei os tickets, diffs, casos e resultados conservados.

Sem achados bloqueantes neste âmbito.

- **37:** as duas alterações PO corrigem a concordância dos sons e o limite
  de duas cartas das imagens. Há vermelho nativo nas duas famílias e verde
  nas cinco variantes. O ticket permanece claimed e os documentos dizem
  explicitamente que percursos, sons e restantes critérios continuam pendentes.
- **38:** confirmei que os nove valores JSON alterados diferem apenas pelo
  corte dos espaços exteriores. O auditor independente percorre os corpora
  completo/amostra, exige texto não vazio e NFC, fixa 23/6 lições e 1090/116
  ocorrências. O total público deriva do maxLevel já calculado; o caso nativo
  conserva vermelho/verde. O relatório limita essa prova à contagem publicada,
  sem afirmar conclusão de Hangman ou de sequências. O ticket continua claimed.
- **39:** os casos verificam 172 entradas físicas/IME com ambas as preferências
  e 36 botões visuais, glifo, locale e recurso solicitado. A prova adicional
  observa o MediaPlayer original para ç: posição positiva, duração e hasAudio,
  seguida de done. Ajuda/foco/menu cobrem as duas preferências. A documentação
  distingue a prova de reprodução dessa amostra, a descodificação anterior do
  inventário, audição docente das gravações novas e critérios Windows/hardware.
- **40:** os dois handlers publicam contagem e nível já calculados pelo motor.
  O caso usa anterior/próximo reais, percorre oito transições e verifica os
  quatro tabuleiros. O vermelho anuncia zero níveis; o verde anuncia quatro,
  sem falhas ou timeout. Ticket e relatório restringem a conclusão ao contrato
  público e mantêm os puzzles e aceitação global pendentes, conforme o âmbito.

Não encontrei alterações de regras ou políticas pedagógicas fora desses
checkpoints. A matriz conserva os critérios de aceitação como pending.
