# Arranque do build Linux depois dos lotes 52 a 58

Foram recompilados rcc_color_mix, rcc_erase, rcc_gnumch-equality e
BuildTranslationsgcompris_qt. Nenhum processo usava o binário principal.
Os recursos partilhados incluem as correções de cor, revelar imagens e
monstros; o catálogo inclui os títulos e textos corrigidos.

Dezanove atividades abriram durante seis segundos, em PT-PT e Docker sem
rede, com perfis isolados e zero erros QML. O processo supervisor terminou
com 0. results.json e run.json registam os parâmetros e resultados; os
SHA dos recursos reconstruídos estão em rebuilt-resources.json.

Este ensaio confirma o arranque do build reconstruído. As conclusões de
níveis estão documentadas nos lotes funcionais próprios. Não demonstra
Windows, dispositivos físicos, audição ou aprovação docente.
