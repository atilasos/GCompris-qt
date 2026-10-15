P2 da revisão37 fechado na integração `d176e898ae914e584083ce7fd5d236a1d5503475`, alteração `49717c463`.

A lista de tarefas é validada antes de preparar recursos/criar a saída. Ambas as seleções incompatíveis devolvem erro argparse2; o sucesso exige resultados não vazios.

Executei os dois testes CLI reais de `test_runner_cli.py`: ambos passaram. Verificam também que Node não inicia e que a saída não é criada. Conferi o caso válido arquivado memory-sound/audio_probe: launcher0, Qt0, zero falhas, relatório verde e SHA256 correspondente ao summary. A prova de preservação regista343 hashes e25 casos anteriores inalterados.

Não repeti as campanhas longas nem alterei código, builds ou provas.
