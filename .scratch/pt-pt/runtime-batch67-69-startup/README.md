# Arranque do build depois dos lotes 67 a 69

Foram reconstruídos rcc_adjacent_numbers e BuildTranslationsgcompris_qt,
com as correções do contrato público dos vizinhos e as cinco entradas PO dos
lotes 67/68. Nenhum processo usava o binário principal durante a escrita; as
cópias privadas dos testes eram independentes.

As quatro atividades abriram durante seis segundos cada, em PT-PT, com perfis
isolados e Docker sem rede. Zero erros QML; o supervisor observado terminou
com 0. Esta prova confirma arranque do build reconstruído; as conclusões dos
níveis estão nas provas funcionais próprias.

O QM tem 3897 traduções após remover traduções iguais à fonte. A sequência de
26 letras portuguesa passou a coincidir com a sequência fonte, pelo que essa
entrada igual deixa de ser necessária no QM. O catálogo mantém a correção.
As vozes 1610 e o binário não foram alterados.

Windows 10, dispositivos físicos, audição e aceitação docente/global continuam
pendentes.
