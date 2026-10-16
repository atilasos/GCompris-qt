# Auditor de padrões, mosaicos e polígonos

`python3 tests/patterns_audit/audit.py --evidence .scratch/pt-pt/functional-patterns/portable-capsule`

O auditor lê apenas os ficheiros físicos arquivados e módulos Python/Pillow.
As duas âncoras literais em anchor.py identificam o índice e o ZIP original;
não se calculam novas âncoras para aceitar uma prova alterada. Duas partes
concatenáveis conservam exatamente o ZIP. Não exige Git, Qt, rede ou os
caminhos históricos. A cápsula não constitui uma distribuição Qt executável.

Verifica fontes/casos congelados, RCC/QM efetivos e extrações, instrumentação
exata, 269 identidades por runtime e os quatro retornos distintos. O recibo
nativo, os dois observadores de subprocessos e a declaração de retorno do
responsável permanecem separados. Esta última não é uma assinatura da plataforma.

Recalcula os planos por geometria observada com um algoritmo Python diferente
do JavaScript do caso. Reproduz a cadeia de estados pintados, erro, reparação,
Bonus e avanço. Confere as imagens dos mosaicos por píxeis da cena completa e
renders físicos RGBA, incluindo margem de unicidade; confere células opacas e
translúcidas com fundo independente. Projeta os vértices realmente desenhados,
classifica a geometria racional e verifica os segmentos nas capturas.

Os controlos têm contratos separados e não acrescentam conclusões de conjuntos.
A classificação Mosaico usa interiores opacos, erro médio máximo por canal 8 e
margem mínima 1; as transparências e arestas não são um teste de igualdade SVG.
O renderer histórico librsvg/cairo está identificado. O auditor portátil
recalcula os PNG e seus píxeis; não volta a executar o renderer SVG.

Os casos expandidos e o armazenamento local deste auditor conservam versões
independentes das provas antigas, evitando uma dependência de ferramentas
históricas alteráveis. Os algoritmos partilhados de grelha, geometria e cena têm
fontes físicas vinculadas na cápsula e são conferidos antes de usar os resultados.

`adversarial.py` ataca cópias físicas, incluindo plano e PNG coerentemente
recalculados. Nesses dois negativos, apenas a fixture aceita temporariamente
as identidades falsas para provar que a geometria e os píxeis ainda recusam a
alteração. O programa normal conserva as âncoras originais. Também recusa prova
vazia, bytes alterados e saídas já existentes. Não usa assert para as guardas.

A cópia Docker Python3.12/Pillow12.1.1 foi executada sem rede/Git/Qt/checkout,
em modo normal e -O. Não é replay dos processos Qt nem aceitação Windows,
audição humana, dispositivo, revisão docente ou estabilidade da tarefa83.
