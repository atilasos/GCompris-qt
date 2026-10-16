# Preservar provas anteriores ao recusar saída de balanças

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 34

## Âmbito

Corrigir P2 da revisão Standards34: o wrapper copia case.qml para uma saída
antiga mesmo depois de o launcher a recusar. Regressão CLI vermelho/verde com
todos os bytes anteriores preservados; recusar saída existente antes de
preparar casos e preservar caso apenas em diretório pertencente à invocação.
Usar ficheiro temporário privado, sem abstração maior ou nova campanha Qt.
Preservar hashes das nove provas existentes e Hangman35783. Sem mapa/CSV,
build principal ou push.


## Answer

P2 corrigido por reclamação exclusiva da saída antes da preparação e caso
privado temporário por invocação. Regressões CLI vermelho/verde conservadas em
`.scratch/pt-pt/scales-output47/README.md`. Nove provas antigas mantêm hashes
de resultados e casos. Sem repetir Qt ou interromper Hangman; cinco testes do
auditor também passam. Não altera critérios de aprovação docente.
