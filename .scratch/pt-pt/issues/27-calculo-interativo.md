# Validar as quatro operações com balão

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 02, 25

## Âmbito e interfaces autorizadas

O âmbito confirmado da tarefa06 inclui todas as atividades, níveis, modos e
respostas entregues por teclado/rato. Este lote cobre algebra_plus,
algebra_minus, algebra_by e algebra_div através dessa interface Qt real.
Observar o texto da resposta, as operações apresentadas, pontuação, rejeição,
transições, navegação e conclusão. Não chamar validadores nem atribuir pontuação.

Primeira fatia: uma pressão numa tecla numérica produz um algarismo e
Backspace elimina um algarismo. Os datasets e os restantes percursos seguem-se.
RCC, perfil e snapshot privados; o build principal permanece inalterado.

## Answer

Corrigida propagação dupla de algarismos/Backspace em Algebra.qml, com reprodução
Qt nativa antes/depois. Os quatro jogos passaram todos os48 níveis,480 respostas
corretas e48 erradas. Teclado visual/físico simulado, Enter/OK, Bonus, navegação,
ajuda PT, retorno ao menu, dez velocidades, reinício e recuperação após expiração
real passaram. [Provas e limites](../functional-algebra/README.md).
Windows, escola e revisão docente permanecem pendentes.
