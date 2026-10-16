Recheck Standards do P2 da ferramenta 83, intervalo fixo `d593cfb5086caa714ebd2d440ee1a4cc4c4b449d...b1fc8910591b7287625da0ba90b93f7bdf9ea4a5`, commits conferidos.

O P2 fica fechado. Nenhum defeito adicional identificado neste âmbito.

`probe_passed()` centraliza agora o critério usado pelos dois ciclos e pelo veredito final: retorno 0 do supervisor e do inferior, lista de sinais explicitamente vazia, identidade observada, cmdline correspondente e namespaces presentes/iguais. Um wrapper 0 deixa de permitir continuar após SIGSEGV ou observação incompleta.

Reexecutei `/tmp/repro-standards83-stop.py` inalterado, sem Qt/gdb: após o SIGSEGV observado em baseline-bare, só esse probe é lançado e o driver devolve 1. A expectativa antiga de quatro lançamentos do próprio script já não se verifica. Os novos testes CLI com subprocessos Python confirmam interrupção imediata também perante retorno 139/1 do inferior, SIGABRT, identidade/cmdline ausentes ou errados, namespaces distintos/ausentes e falha do wrapper. A fixture saudável executa exatamente os seis probes planeados.

Passaram os 14 testes em Python normal e os mesmos 14 com -O, incluindo a cópia portátil e negativos anteriores. Os auditores normal e otimizado continuam a validar os seis recibos históricos como diagnóstico finito, com causa desconhecida e issue_resolved=false.

Conferi independentemente os 238 blobs selados contra Git `d593cfb5086caa714ebd2d440ee1a4cc4c4b449d` e os SHA do índice: todos permanecem intactos. Nenhum recibo, cápsula, RCC/QM ou retorno histórico foi reescrito, e não houve novas partidas ou probes nativos.

O ticket 83 continua `Progress: open`. Fechar este defeito do driver não corrige nem explica o encerramento 139 original; PID histórico temporal, runtime indisponível/inode null, diferenças do snapshot e limites de Windows/hardware/áudio/docente/global mantêm-se.

Sem Qt/gdb/build/push ou alterações de main/provas/mapa/CSV.
