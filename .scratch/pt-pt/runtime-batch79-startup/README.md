# Arranques Linux após integração do lote 79

A fonte de integração `81261cf9fa128266a99278c3dded3eaaac137ff3` foi usada
para reconstruir `rcc_guesscount` e `BuildTranslationsgcompris_qt`. A ferramenta
terminou com código 0, saída `1fe305`; o catálogo tem 3897 traduções terminadas
e zero inacabadas. Nenhum processo mapeava o executável principal antes da
reconstrução.

Os dois arranques de seis segundos, `guess24` e `guesscount`, passaram em PT-PT,
em Docker sem rede, sem erros QML ou saída antecipada. O executor terminou com
código 0 na sessão 50644, saída `3f0608`. Os recibos e logs originais ficam nesta
pasta; `artifact-hashes.json` identifica os ficheiros efetivamente construídos.
O RCC das 1610 vozes mantém o SHA-256 aprovado e usado anteriormente.

Estes arranques não acrescentam níveis às campanhas funcionais do lote 79 e
não certificam Windows, audição, dispositivos físicos ou aceitação global.
