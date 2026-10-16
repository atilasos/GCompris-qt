# Revisão Spec independente — tarefa 79

Intervalo fixo `fb9a431a9533c859cb3c9c6758a8b5668ce53c36...81261cf9fa128266a99278c3dded3eaaac137ff3`; commits e diff inspecionados. Sem Qt, build, alterações de main/provas ou índices.

**Sem achados acionáveis; confiança moderada/alta.**

A spec 30–35 exige «iniciar, jogar e concluir os níveis e modos» e evidência além da abertura. O auditor puro, normal e `-O`, confirmou 186 perguntas principais/31 níveis: 100/6 de guess24, 56/17 incorporadas e 30/8 administrativas; 31 erros reparados e dois casos de controlos. Os 18 testes passaram, incluindo cópia física isolada e adulteração. Os números não confundem as 1506 entradas estáticas com execuções Qt; as quatro perguntas do editor permanecem adicionais.

O ticket 11–14 exige «números, alvos e operadores desenhados» e proíbe soluções/modelos ocultos. Os casos extraem texto das cartas/peças e alvo visível. A pesquisa independente constrói árvores binárias ou cadeias, calcula frações exatas, admite somente intermediários inteiros não negativos e verifica cada resultado desenhado. Operadores lineares reutilizáveis correspondem à origem que recria peças; números não se repetem. As dicas de 24 são abertas/fechadas, sem usar a solução apresentada.

Ticket 16–21: há 50 perguntas com teclado, 50 com rato e 86 por arrasto, rejeição aritmética quando aplicável, recuperação, desfazer, Score/Bonus e avanço natural. Controlos públicos cobrem seleção persistida, navegação parcial, ajuda/Escape/foco/menu. O editor recusa seleção vazia, grava/reabre/joga uma configuração e restaura-a; o README declara corretamente que não esgota `15^8` configurações.

As correções são delimitadas pela spec 27–29 e 39–40: título/instrução PT, grupos publicados distintos, contagem administrativa disponível e alvo antes insolúvel. Quatro pares conservam casos byte-idênticos. Não identifiquei scope creep ou comportamento incorreto introduzido.

Ticket 23–28: cinco cápsulas históricas preservam fontes/PO/ferramentas, QM e RCC reais extraídos; snapshot sela 269 recursos. Retornos Qt, supervisor e ferramenta são separados, pós-espera e ligados a recibos/casos. Os 22 recibos distinguem 18 verdes de quatro vermelhos. Limites Linux, sorteios, descodificação sem audição e revisão docente/Windows/global estão explícitos; não há aprovação global implícita.
