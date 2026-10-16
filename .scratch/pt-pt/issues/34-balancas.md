# Validar as três atividades de balanças

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 02, 25, 28, 33

## Âmbito

scalesboard, scalesboard_weight e scalesboard_weight_avoirdupois. Todos os
datasets, níveis e modos expostos, por arrastos reais de pesos, leitura dos
rótulos visíveis e observação da inclinação da balança. Usar um oráculo
matemático independente, sem ler giftWeight, question.answer ou o peso oculto
do presente para resolver. Pesos conhecidos vêm dos rótulos visíveis e das
relações de unidades. Nos puzzles sem rótulo, procurar pelo equilíbrio.

Cobrir pesos nos dois pratos quando exposto, rejeição de resposta errada,
entrada de massa após equilibrar, pontuação/Bonus/transições, ajuda PT,
navegação, reinício e menu. Sem atribuir modelos, mover os pratos ou emitir
validações. Recursos privados selados, perfil novo e rede desligada.
Distinguir dispositivos físicos, Windows, audição e professor pendentes.

## Comments

A concordância do título SI foi reproduzida na ajuda Qt real e corrigida de
"Balança que usam" para "Balança que usa". Prova red/green independente do
percurso completo em `../functional-scales/si-help/README.md`. Esta correção
parcial não resolve a tarefa 34 nem aprova os 666 puzzles previstos.

O percurso encontrou também um puzzle impossível no nível 30 de scalesboard:
o presente de 5 não era atingível com as massas dadas. A quarta massa conhecida
passa de 1 para 2. Prova red/green por arrastos reais e auditoria independente
dos 666 alvos em `../functional-scales/balance-five/README.md`. Os percursos
completos continuam; Progress mantém-se claimed.

## Answer

Os três jogos passaram todos os 20 datasets, 142 níveis e 666 puzzles por
arrastos/cliques/teclas Qt reais: 4018 arrastos e 142 respostas erradas
rejeitadas. Pesos ocultos foram resolvidos por somas atingíveis e inclinação,
sem ler o peso oculto ou a resposta. O auditor independente confirmou unidades,
pesagens, tentativas e entrada numérica. Pontuação, Bonus e transições naturais.

Três casos de controlos passaram ajuda PT, navegação, reinício e menu. Os
tracers com teclado visual desligado cobrem só três níveis por jogo: 24 puzzles
adicionais, sem afirmar outra campanha completa de 666. Os nove casos finais
passaram sem timeout/erros QML, com UID/GID e limpeza verificados. Sete testes
Python e os exemplos Node passaram.

Corrigidos apenas o título SI e um puzzle impossível de 5, ambos com provas
red/green próprias. Auditoria separada confirmou os 666 alvos atingíveis.
[Provas, comandos, identidade e limites](../functional-scales/README.md).
Windows, hardware, audição física e aceitação docente global permanecem
pendentes. Mapa e CSV global não foram alterados.
