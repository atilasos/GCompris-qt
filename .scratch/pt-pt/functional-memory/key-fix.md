# Teclas de memória: regressão nativa

Antes da correção, uma só seta Direita move currentIndex de 0 para 2.
A prova em probe-diagnostic/native.log regista `NATIVE_MEMORY_FAILURE 2 1`.
O caso e os hashes da execução anterior são conservados no mesmo diretório.

MemoryCommon não marcava teclas tratadas como aceites. ActivityBase voltava
a encaminhá-las ao componente, repetindo navegação/seleção. A correção aceita
apenas setas/Espaço/Enter/Return; teclas restantes continuam a propagar.

O caso key_regression.qml com a correção confirma uma posição por seta,
seleção por Espaço, três pares completos, pontos e transição para nível 2.
Escape continua a chegar a ActivityBase e abre o menu. Resultado e hashes:
[key-green/result.json](key-green/result.json).

Este é um resultado parcial da tarefa21. Os restantes níveis/modos continuam
em execução; não constitui aceitação global Linux/Windows ou revisão docente.
