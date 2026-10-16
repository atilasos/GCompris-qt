Standards independente do suplemento 80, intervalo isolado `3b5875b49067b6b3eaaa2a5dda35118ccd2963f5...633e3beecaf354d5c35b46652809f8348792f48a`, commit conferido. Normas locais e baseline Fowler consideradas; sem novas regras locais.

Violações documentadas: nenhuma identificada. Smells acionáveis: nenhum. Nenhum defeito adicional identificado no auditor ou na reconstrução delimitada.

O auditor suplementar verifica primeiro a prova original pela raiz literal fe9a2983…, depois exige a nova raiz literal do suplemento. Os RCC/QM físicos têm SHA completo idêntico ao já observado em cada um dos 39 recibos, incluindo diagnósticos e campanhas. A reconstrução é explicitamente posterior; não se afirma sobrevivência dos deployments nem nova execução funcional. A busca limitada altera apenas o timestamp do QML instrumentado e só aceita correspondência integral do binário histórico.

Passaram os dez testes novos: cópia autónoma, RCC/QM/QML extraído alterados, objeto ausente, alteração coerente de objeto/mapa/selo, preservação do original, rejeição de Python -O e de saída existente. O auditor puro confirmou 39 overrides exatos, 15 RCC canónicos, 1244 ficheiros extraídos pelo Qt e 340 objetos físicos deduplicados. Mantém 42 partidas históricas, sem aumentar a cobertura.

Os mapas canónicos coincidem com os inventários históricos dos três snapshots. Cada extração é comparada com as fontes da fase ou com a reinjeção exata do caso; os QM conferem com os SHA dos recibos e preservam TS descodificados. O ZIP é lido em memória, sem extração arbitrária; objetos são identificados pelo SHA dos próprios bytes e todos têm utilização contabilizada. Caminhos externos são dados inertes; os artefactos de disco recusam caminhos não relativos e symlinks. Os formatos RCC/QM e o XML TS também são verificados.

Conferi os 349 blobs do arquivo original contra a base fixa: nenhum mudou, incluindo a captura fe9a2983… e os recibos. A captura suplementar do tip fixa dez artefactos e liga o retorno observado da reconstrução ao log e ao relatório. A auditoria copiada não precisa de Git/Qt/build ou caminhos históricos; a conveniência de reconstrução continua dependente dos snapshots privados e ferramentas originais, conforme documentado.

Sem Qt, build, push ou alterações de main/provas/mapa/CSV. Permanecem os limites de runtime parcialmente arquivado, Windows, hardware, audição e aceitação docente/global.
