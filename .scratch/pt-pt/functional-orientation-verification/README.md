# Verificação final da tarefa 76

15 testes passaram: relações visuais/português, três fronteiras CLI,
concorrência/interrupção/corrupção de fonte, captura de retornos reais de
subprocessos Python de fixture, cópia válida, amostras vazias e quatro tipos de
adulteração com hashes recalculados. As rejeições foram verificadas com Python
normal e -O. A cópia portátil corre num contentor sem Git, Qt ou acesso à árvore
original; a própria verificação dessa ausência não usa assert desativável.
As fixtures Python não são provas Qt nem simulam jogos concluídos.

Auditor puro normal e otimizado: 80 tarefas, 13 níveis, 13 erros reparados,
três controlos finais e 11 recibos selecionados. Os nove retornos externos 0 e
os dois vermelhos 1 estão separados do retorno 0 do Qt. Nenhum processo ficou
pendente. `preserved.json` confere os ficheiros do arquivo fixado em Git.

Limites: Linux/software/offline; não se esgotam permutações aleatórias nem
sequências personalizadas. Windows, equipamento, audição e revisão docente
continuam por validar.
