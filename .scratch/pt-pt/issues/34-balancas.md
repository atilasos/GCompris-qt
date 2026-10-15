# Validar as três atividades de balanças

Status: ready-for-agent
Progress: claimed
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
