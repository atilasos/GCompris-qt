# Arranques Linux dos lotes 80 e 81

Os quatro RCC partilhados de galo, quatro em linha, apanha-bola e penáltis e o
QM português foram reconstruídos após integrar os lotes 80/81. A ferramenta
terminou com código 0, saída `b678b8`, a partir de `edc1b1fa1`. Nenhum processo
mapeava o executável principal antes da reconstrução.

Seis arranques de seis segundos passaram em Docker sem rede, sem erros QML
ou saída antecipada: os quatro consumidores dos jogos de alinhamento,
`ballcatch` e `penalty`. A fonte de arranque é `1729d456c`, que só acrescenta
documentação à fonte construída. O executor terminou com código 0 na sessão
85443, saída `9c4ca2`. Recibos e logs originais ficam nesta pasta; os hashes
identificam os artefactos reais e conservam o RCC das 1610 vozes.

São verificações de arranque, sem novos níveis concluídos, sem certificação
Windows, audição ou estabilidade. A ocorrência139 histórica dos penáltis
permanece em investigação na tarefa83.
