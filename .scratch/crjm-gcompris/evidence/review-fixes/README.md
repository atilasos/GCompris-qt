<!-- SPDX-FileCopyrightText: NONE -->
<!-- SPDX-License-Identifier: CC0-1.0 -->
# Validação após a revisão

Os quatro percursos existentes passaram, com dois passes e zero falhas por
caso, zero erros QML e zero eventos OOM. Executaram desde o menu real, sem
`--extra-activity`, offline em Docker, com `cpu.max=100000 100000` e
`memory.max=536870912`. O pico máximo dos quatro contentores foi 229900288
bytes. `summary.json` guarda comandos, tempos e métricas; cada diretório de
caso contém o resultado completo, log e capturas Qt.

Quelhas Tux registou resposta máxima de 1241 ms, incluindo a primeira ajuda,
e heartbeat de 212 ms. Nex Tux registou resposta máxima de 148 ms, heartbeat
de 49 ms e abertura da ajuda de 9 ms. Todos os limites existentes passaram
sem alterações aos testes ou aos limites. Os percursos cobrem partidas,
vitórias, finais especiais de Nex, misère de Quelhas, dificuldades, pistas,
exercícios, revisão e controlos. Não chamam as novas funções privadas.

## Recursos e artefacto

A configuração CMake usou a worktree `crjm-review-fixes`, com downloads e
traduções desativados, Release, sem servidor nem testes C++.
`resource-build.log` regista os alvos `rcc_nex` e `rcc_quelhas`. As receitas
CMake continuam a incluir `*.qml`, `*.mjs` e os SVG.

O artefacto completo da tarefa 18 foi copiado para uma candidata separada.
Somente `nex.rcc` e `quelhas.rcc` foram substituídos pelos novos recursos
CMake. Depois dos quatro percursos, a candidata passou a ocupar o caminho
final `build/crjm-complete`; o artefacto anterior está preservado em
`build/crjm-complete-pre-review`. O launcher continua a ser
`build/crjm-complete/run-crjm.sh`.

`artifact-manifest.json` é o manifesto final verificado. `artifact-update.json`
regista hashes das fontes, dos dois RCC antes e depois e a referência ao
manifesto canónico da tarefa 18. O verificador confirmou que os restantes
278 ficheiros e a lista de diretórios são idênticos. Os 18 percursos da tarefa
18 validam o artefacto anterior; estes quatro percursos atualizam a aceitação
para os únicos dois recursos alterados. Os resultados não são apresentados
como uma segunda matriz completa de 18 percursos.

O Qt e as bibliotecas do sistema continuam dependências desta build Linux.
Não se testou hardware escolar, ecrã tátil físico, som físico nem crianças.
Não houve publicação nem distribuição externa.
