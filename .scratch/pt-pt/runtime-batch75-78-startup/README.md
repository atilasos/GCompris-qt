# Arranques Linux após integração dos lotes 75 a 78

A fonte de integração `395456d94dbfef3a0716f8c43f6885961c2f1f24` foi
configurada explicitamente com CMake para incluir o novo SVG no QRC. A
configuração terminou com código 0 na sessão 91228, saída `452368`.
Os recursos `rcc_babymatch`, `rcc_fifteen`, `rcc_left_right_click`,
`rcc_lightsoff` e o QM português foram reconstruídos com código 0, saída
`7ff4e1`. O QM contém 3897 traduções terminadas e zero inacabadas.

O inspetor QtCore extraiu do RCC principal `Fifteen.qml`, a ilustração original
e a variante portuguesa. Os três ficheiros reais correspondem byte a byte às
fontes, saída `44a378`. As extrações e o índice Qt estão nesta pasta.

Os oito arranques de seis segundos, em PT-PT e Docker sem rede, passaram sem
erros QML ou saída antecipada. A ferramenta terminou com código 0 na sessão
21576, saída `c93c3c`. `run.json`, `results.json` e os logs conservam os resultados
originais. Estes arranques não acrescentam níveis às provas funcionais e não
certificam Windows ou revisão docente. Os hashes identificam os artefactos
principais efetivamente presentes. O RCC das 1610 vozes manteve o SHA-256.
