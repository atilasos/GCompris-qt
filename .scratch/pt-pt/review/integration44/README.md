# Revisões e fecho dos dois pares legados

Entrega inicial: base `34ebad9be17ffa1b9e73024b28b40b7b801fb348`,
head `daf3ae13f2c23597945a37c99407a3b914305e1a`.
[Spec inicial](spec-review.md) encontrou P1 de terminações Windows.
[Standards inicial](standards-review.md) não encontrou violações de padrões,
mas registou P2 de preparação da proveniência para correção.

O suplemento `723bde268` foi revisto no head `a9365de35641a6bf3a21385b35233d134c879b7d`
e integrado em `a8b47e642652ba75b4616ca9f6f663dcb3c8bc39`.
Os [rechecks Spec](spec-recheck.md) e [Standards](standards-recheck.md)
fecharam sem achados. Os quatro relatórios são cópias literais.
Spec executou um teste de checkout Git sob terminações CRLF e nove testes
Python. Standards não repetiu testes. A simulação no Linux não é execução Windows.

A decisão humana autoriza apenas os nomes cervato e carraça e os dois WAV
apresentados no pacote. Os OGG distribuídos derivam desses WAV, sem nova síntese.
As 32 gravações anteriores permanecem intactas. A preparação completa da
proveniência protege falhas de preparação. Os vários replace não constituem
uma transação atómica perante interrupção durante a publicação.

As [provas de aplicação](../../legacy-word-application/README.md),
[correções](../../legacy-word-application-review/README.md) e
[recursos principais e arranque](../../runtime44/README.md) conservam os limites.
O arranque terminou externamente 1 por incluir o ID inexistente polygons2.
Seis IDs reais passaram. Os logs e esse retorno não foram reescritos.
O instalador publicado 38862699753 antecede estes dois pares.

Fecha-se a aprovação e aplicação delimitada dos dois pares.
Instalação, execução e reprodução sonora no Windows, escola, dispositivos,
revisão docente global e estabilidade 83 continuam pendentes.
O CSV mantém 203 atividades, 152 ligações e todas as cinco colunas globais pending.
