# Spec — tarefa 49

Base `ca1d63b5c`; implementação `7ee53fa007ff81275cd20ee9e25cd6743ef5c46c`,
merge `6a79e309302153722e4cd27fcb48393c6d11d9b2`. Revisão independente do
ticket 49, casos, auditor e quatro recibos finais. Sem novas campanhas ou
alterações de fontes; a tarefa 46 da minha autoria está excluída.

## Achado

**P2 — a restrição de mover apenas o disco do topo não tem controlo negativo.**
O ticket pede «Verificar movimentos proibidos, topo das torres».
`tests/hanoi_real.qml` e `tests/hanoi_simplified.qml` escolhem sempre discos
do topo segundo pilhas próprias e verificam que esses discos estão enabled.
Os negativos tentam maior sobre menor, capacidade excedida e referência
imutável; nenhum tenta arrastar um disco que tenha outro por cima nem exige
que os discos inferiores estejam bloqueados. Uma regressão que permitisse
retirar discos do meio deixaria passar todos estes casos. Acrescentar um
arrasto real de um disco inferior identificado pela posição vertical visível,
verificando a pilha inalterada, em cada motor.

## Requisitos conferidos

Os recibos positivos conservam três níveis clássicos com 3/4/5 discos e
soluções de 7/15/31 movimentos; os seis simplificados têm alturas
5/5/6/7/8/9. O clássico usa larguras desenhadas e solução matemática; o
simplificado lê símbolos, cores e ordem da referência visível. Não encontrei
consulta a solução/vitória escondida para escolher os movimentos ou chamadas
a move/won do motor. As atribuições de pilhas são memória privada do teste,
com arrastos reais e confirmação da ordem efetivamente desenhada.

Há 15 negativos dos outros tipos, Bonus e transições naturais, e dois controlos
com navegação, reinício parcial, ajuda PT/Escape, novo arrasto e menu. Conferi
os quatro resultados positivos e todos os hashes de artefactos do índice.
Os diagnósticos anteriores permanecem fora do índice. Não há produção alterada.

O relatório distingue uma disposição aleatória por nível de todas as
permutações e mantém Windows, touch/mobile, hardware, som físico e revisão
docente pendentes. O achado não invalida os nove puzzles completos observados;
limita a prova da regra de bloqueio dos discos inferiores.
