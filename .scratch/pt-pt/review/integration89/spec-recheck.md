Spec recheck — tarefa 89
Base integrada anterior: e480214061ae38bb8b99586ca7535cfeef20426e
Suplemento revisto: 99c1cebe479ca7824d002036286c292bf6c17a84
Head integrado: e9a7a84502661d261c121638ac580a2337486e3b
Revisão original: faa44382bf0d3f6d03ce8c0c24f51ed89b076400...e40f2147084129add29f7d16d2ffb0cf0e5e33f7

0 findings Spec pendentes dos dois P2 originais.

P2 PNG/reabertura resolvido: review_audit.py descodifica dez PNG físicos e compara o RGB completo com a cena correspondente. Nos dois níveis das rodas, verifica ainda o PNG contra os vetores SVG e compara tinta reaberta bidirecionalmente, com tolerância espacial declarada de um píxel, diferença de área inferior a 1% e diferença de cor dominante até dois valores de canal. Negativas recusam branco e reabertura vazia/errada. Isto satisfaz a aceitação 89, linhas 24–26, sem confundir fecho do diálogo com conteúdo reaberto.

P2 undo/redo/preservação resolvido: o suplemento prova retirada do último traço real, recuperação do desenho com diferença máxima declarada de dois valores de canal, e preservação RGB exata em três cancelamentos que contêm trabalho. Negativas recusam undo/redo ineficazes e perda de trabalho. Isto satisfaz as linhas 18–20 nos percursos efetivamente oferecidos e exercitados; não inventa cancelamento de nova imagem nas rodas.

Validação: 31 testes puros finais passaram em 119.238 s na árvore 99c1cebe4; retorno real externo 0 da sessão 52501, chunk dde929. Log: /tmp/gcompris-89-merger-tests.log. O conjunto inclui a auditoria isolada sem Git/Qt e recusa explícita de -O. Hashes do índice, fontes e relatório suplementar conferidos; diff --check sem erros. Integração --no-ff concluída, main limpa. Não houve Qt/build/push.

A cápsula histórica, fontes de produção e PO não mudaram neste suplemento. A âncora literal 9b8e6aab0aac15a3c9f8bcd73dcaac8b62a0eb7040181f6c874dd51e27ebeb61 e ZIP 2fe09088b42e0cf41917e430ebf4ac97e19a48f3c5ddf50e04648ef6d6ef9395 permanecem intactos. Os históricos e retornos não zero conservam os limites originais. Não foi emitido parecer Standards. Windows, dispositivos, audição, docente, estabilidade 83 e aceitação global continuam pendentes. Ticket, mapa e CSV não foram fechados/alterados por esta integração.
