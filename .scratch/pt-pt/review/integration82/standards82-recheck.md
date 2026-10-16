Recheck Standards dos dois P2 de82, intervalo isolado `fdb22cb7e592a053e413ee7b88683a09b3fe809d...4011f8a0ee28f8a05de05b9b01fa0cb802469c2b`.

Os dois P2 ficam fechados. Sem achados restantes neste âmbito.

A auditoria fixa agora o SHA literal do sealed.json histórico, fora do arquivo modificável, antes de aceitar os seus hashes internos. Reexecutei `/tmp/repro-standards82-reseal.py` inalterado: a substituição coerente de PO/cápsula/lista de fontes/recibos/estados/selo é rejeitada com «Historical archive index differs from external anchor». A rejeição também passou em cópia Docker sob Python normal e -O, sem Git, Qt, rede ou árvore original.

O runner recusa saída ou log preexistentes antes de verificar fontes, criar casos ou abrir logs. Usa criação exclusiva de log/status e não escreve observações quando o supervisor recusa com código 2. Reexecutei `/tmp/repro-standards82-existing-output.py` inalterado: agora termina em FileExistsError antes do subprocesso. A regressão adicional confirma todos os bytes anteriores preservados, incluindo o log, e que o launcher não foi chamado.

Passaram os sete testes em Python normal e os mesmos sete com -O, incluindo negativos coerentes e cópia isolada. Os auditores normal e otimizado mantêm 24 pares idênticos e dois modos sem seletor, sem acrescentar conclusões funcionais de jogos.

Conferi independentemente os 462 blobs do arquivo histórico contra o tip fixo originalmente revisto `69b08c9bcac026a87681c7137c220aa0123100ba`: todos permanecem byte a byte intactos. Não houve re-selagem de provas antigas, alteração de recibos ou nova campanha.

Sem Qt, build, push ou alterações de main/provas/mapa/CSV. Lote 80 não revisto neste recheck. Os limites de runtime compacto, Windows, dispositivos, áudio e aceitação docente/global mantêm-se.
