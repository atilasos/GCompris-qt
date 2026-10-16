# Arranque do build depois dos lotes 60 a 63

Foram recompilados rcc_calendar, rcc_money, rcc_money_cents,
rcc_vertical_subtraction e BuildTranslationsgcompris_qt, sem processos a usar
o binário principal. Os snapshots dos testes ativos já estavam selados.

As onze atividades afetadas abriram durante seis segundos em PT-PT, com
perfis isolados e Docker sem rede. Zero erros QML; supervisor terminou com 0.
Os parâmetros, resultados, logs e hashes estão neste diretório.

Este ensaio confirma arranque do build reconstruído. As provas de conclusão
estão nos lotes funcionais próprios. Windows, dispositivos físicos, audição
e revisão docente continuam pendentes.
