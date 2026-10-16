# Arranques Linux após integração dos contratos de níveis

A fonte de integração `69b08c9bcac026a87681c7137c220aa0123100ba` foi usada
para reconstruir os 21 RCC alterados pelo lote 82. A ferramenta terminou
com código 0 na sessão 2756, saída `f2883f`. Nenhum processo mapeava o
executável principal antes da reconstrução. O log identifica os alvos reais.

As 24 atividades e variantes do inventário público passaram nos arranques
de seis segundos, em PT-PT e Docker sem rede, sem erros QML ou saída antecipada.
O executor terminou com código 0 na sessão 22190, saída `1e1e61`. Os recibos e
logs originais ficam nesta pasta; `artifact-hashes.json` identifica os ficheiros
efetivamente presentes. O RCC das 1610 vozes mantém o SHA-256 anterior.

Os cinco testes puros do lote 82 também passaram no ramo integrado, sessão
30029, saída `2d685c`; o auditor confirmou 24 pares e dois modos sem seletor,
saída `e2ec15`, e a guarda estática passou, saída `42a4a6`.

Estes arranques complementam os casos de contrato público e não acrescentam
jogos ou níveis concluídos, Windows, audição, dispositivos físicos ou aceitação
global. A revisão independente ainda está pendente.
