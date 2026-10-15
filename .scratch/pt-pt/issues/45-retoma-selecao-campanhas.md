# Preservar identidade das provas e rejeitar campanhas vazias

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 38, 43

## Âmbito

Corrigir os dois P2 da revisão incremental43: a retoma de palavras/letras
não compara toda a identidade congelada, e --lesson999 devolve sucesso sem
casos. Exigir também identidade do launcher usado na prova. Regressões CLI
vermelho/verde para PO, adaptador IME, launcher e seleções inválidas antes da
preparação; conservar tabela declarativa das combinações inválidas dos dois
executores de palavras/letras e memória. Sem nova abstração ou campanha Qt.

Preservar os174 recibos antigos. Não interromper Hangman35783 nem repetir
campanhas por alteração apenas do executor. Sem mapa/CSV/build principal/push.


## Answer

Corrigidos os dois P2. A retoma exige o digest congelado e a identidade do
launcher; filtros sem lições aplicáveis são rejeitados antes da preparação e
resultado vazio nunca concede sucesso. Regressões CLI declarativas dos dois
executores conservadas. Provas vermelho/verde e verificação dos174 recibos
históricos em `.scratch/pt-pt/campaign-contract45/README.md`. Sem repetir Qt ou
interromper a campanha Hangman. Não conclui a tarefa38 nem aprovação docente.
