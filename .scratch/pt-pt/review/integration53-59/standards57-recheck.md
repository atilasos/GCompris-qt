P2 de Standards FINAL57 fechado em `9e7c0a0db6f14178698f0dc922b05c9375dfad28`, correção `cce14f6b2`/tip `d4e7acc51`.

verify_historical_inputs exige uma entrada para cada um dos44 recibos históricos e liga source_sha256/portuguese_catalogue_sha256 aos bytes arquivados da respetiva fase. O manifesto congelado é conferido antes da aceitação. Catálogos anteriores dos vermelhos não são substituídos pelo atual ou pelo verde.

Executei os nove testes: todos passaram, incluindo12 alterações isoladas de identidade, portabilidade Docker sem caminhos originais, adulteração de fonte/PO/manifesto e recusa do catálogo histórico de outra fase. A auditoria pura passou104 níveis e1874 capturas; confirmou44 recibos ligados aos inputs.

Comparei pelo Git os44 result.json anteriores com a integração: todos permanecem byte a byte inalterados. Nenhum índice ou recibo foi reescrito. A linha vazia final do teste é ruído de formatação já identificado pelo integrador e não altera esta conclusão.

Sem achado remanescente neste P2, sem Qt, alterações de código/build ou mutação de provas.
