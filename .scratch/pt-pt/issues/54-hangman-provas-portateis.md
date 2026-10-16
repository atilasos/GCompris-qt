# Auditar Hangman depois de limpar a worktree

Status: ready-for-agent
Progress: claimed
Type: task
Blocked by: 38

## Âmbito

Resolver o P2 Standards38 final: aggregate.py reabre casos/fontes/launcher por
caminhos absolutos históricos da worktree. Preservar integralmente os 116
recibos/4824 palavras e os 174 de Letra na palavra; não repetir Qt.
Arquivar os bytes necessários selados e resolver a auditoria por caminhos
relativos à evidência, sem depender da worktree antiga ou do launcher atual.
Não inventar campos ausentes em recibos anteriores.

Provar via CLI que o agregado funciona com evidência copiada e worktree
histórica inacessível, mantendo recusa de casos/fontes/manifestos adulterados.
Um implementador, branch/worktree isolada, revisão independente e merger
separado. Não limpar pt-words-letters antes de selar os bytes necessários.
