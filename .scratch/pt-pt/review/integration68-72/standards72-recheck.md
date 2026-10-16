Recheck Standards do P2 de68, correção `3ed653d70` integrada em `670ff2a7b`, autoria `work/pt-source-preparation`, tip `03d893137`.

O P2 fica fechado. Nenhum achado restante neste âmbito.

`phase.freeze()` escreve a fonte e o manifesto numa árvore temporária privada e só publica o diretório completo por rename. Concorrentes que perdem a publicação verificam a árvore vencedora contra os bytes Git, sem modificar fontes já publicadas. Falhas de escrita não tornam a árvore incompleta visível; uma tentativa seguinte pode preparar novamente. `campaigns.py` resolve a revisão e prepara a fonte antes de abrir o pool, passando o SHA resolvido aos dez workers.

Reexecutei `/tmp/repro-standards68-freeze-race.py`, conservando-o inalterado. Agora ambas as chamadas concorrentes terminam `ok`; só falha a expectativa antiga do próprio script, que exigia AssertionError no segundo chamador. Os novos testes com Git temporário real confirmam a escrita suspensa sem leitura parcial, idempotência concorrente, recuperação após interrupção, rejeição de fonte publicada corrompida sem voltar a selar e dez subprocessos com seis workers recebendo uma revisão fixa e previamente preparada.

Passaram os 16 testes, incluindo os 12 anteriores e a cópia portátil. O auditor puro mantém os 22 recibos, 574 perguntas, 58 níveis, 58 erros reparados e 96 pares nível/passo. Conferi independentemente os 307 ficheiros históricos de `preserved.json`: todos coincidem byte a byte com Git `de2ff968f68fb54cbff3a2e5161474befaad3a0f` e com os SHA declarados, incluindo catálogo, índices e recibos.

Sem Qt, alterações no mapa/CSV ou reescrita de provas. Não houve aumento de cobertura funcional nem alteração dos limites de plataforma/dispositivos/áudio/docente.
