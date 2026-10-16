# Chapéu mágico de adição e subtração em PT-PT

Status: ready-for-agent
Progress: ready-for-review
Type: task
Blocked by: 02, 25

## Aceitação

Inventariar e concluir os níveis e datasets de magic-hat-plus e magic-hat-minus,
que partilham o motor do chapéu. Contar apenas estrelas efetivamente desenhadas
e ler os multiplicadores visíveis. Calcular soma/diferença e uma representação
válida da resposta de forma independente, incluindo conjuntos de estrelas
diferentes e coeficientes conforme os dados. Não ler soluções, operandos ocultos
ou contagens internas. Observar as fases visíveis antes de as estrelas entrarem
no chapéu e deixar as animações terminar naturalmente.

Usar cliques/gestos reais; testar resposta errada e reparação, Bonus e passagem
de nível natural. Cobrir reinício, seleção persistida, ajuda PT/Escape, foco,
navegação circular e menu conforme a interface. Conferir recursos QRC.

Snapshot offline privado e estados externos observados após a execução,
ligados aos recibos/casos. Fontes, catálogo, supervisor e artefactos fixados em
âncoras imutáveis. Auditor reproduzível e ataques com hashes recalculados.
Qualquer correção requer caso vermelho/verde igual.

A aprovação global, audição, equipamento físico e Windows 10 mantêm-se pendentes.

## Answer

Concluídos nove datasets e 41 níveis de cada jogo, 82 puzzles naturais no total,
com resposta errada, Bonus negativo, reparação por cliques e Bonus positivo em
cada um. Incluem 30 puzzles com coeficientes e 12 com conjuntos diferentes.
O solver conta SVG preenchidos efetivamente visíveis e os coeficientes
desenhados. Na adição observa ambos os operandos antes do chapéu; na subtração
observa o segundo depois da animação natural até à segunda linha. Calcula
soma/diferença e representação limitada de forma independente, sem soluções
ou contagens internas. Uma configuração aleatória normal por nível, sem
esgotar todas as combinações possíveis.

Dois casos de controlos verificam nove entradas de dataset, persistência e
reposição 41→39→41, resposta parcial descartada por Gravar, navegação circular,
ajuda PT/Escape, entrada após a ajuda e menu. O tracer extra de subtração não
conta para os 82 puzzles. O diagnóstico de vocabulário conserva a asserção
incorreta do harness sobre "chapéu" num manual que usa o termo válido "cartola";
não conta como prova verde nem como defeito de produção.

Seis processos Qt terminaram com 0 e sem timeout. Cinco provas verdes têm
lançador, supervisor e retorno observado pela ferramenta 0; o diagnóstico
conserva 1 nessas camadas externas. Estados pós-espera e observações externas
ligam hashes dos recibos e dos casos sem inferir retorno externo do estado
nativo. O snapshot privado sela 269 ficheiros. Os 250 ficheiros de fonte,
catálogo e ferramentas pertencem ao Git 8ea79102f; recursos dos três RCC e três
WAV conferidos, estes descodificados em software. Não houve alteração de
produção nem escrita no build principal.

Provas e índice imutáveis em 4cc4ef43774c9517c45a9c77ab78ffc6201c5744.
`python3 tests/functional_magic_hat/audit.py` confirma seis casos, 82 níveis,
82 reparações, dois controlos e 18 datasets. Os 19 testes unitários passam,
incluindo cópia independente, adulteração com selos recalculados e recusa de
Python `-O`. [Procedimento, provas e limites](../functional-magic-hat/README.md).

Windows 10/11, audição, equipamento físico, acessibilidade e revisão docente
continuam pendentes; os critérios globais não são aprovados por este lote.

## Integração

Provas integradas para Standards e Spec independentes. `ready-for-review`
não representa resolução final ou aceitação global.
