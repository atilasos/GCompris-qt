# Seleções vazias no runner de memória — tarefa 42

O comando `--activity memory --case audio_probe` filtrava todos os casos e
terminava com saída 0, `passed: true` e `cases: []`. `red.log` conserva a
regressão pela CLI real antes da correção. A mesma falha aplicava-se a
`--activity memory-tux --case configuration`.

A lista de tarefas é agora construída imediatamente depois do parse dos
argumentos. Uma seleção sem casos termina com erro argparse (código 2), antes
de preparar dados/recursos ou criar o diretório de saída. O sucesso do relatório
também exige explicitamente uma lista de resultados não vazia.

`test_runner_cli.py` executa o processo real para as duas combinações, verifica
a mensagem e o código, e usa um sentinela externo Node para detetar preparação
indevida. Não simula o parser ou a função de seleção. `green-first.log` regista
a primeira passagem e `green.log` ambas as regressões.

```sh
python3 -m unittest discover -s tests/functional_memory_rest -p test_runner_cli.py
```

Um caso compatível memory-sound/audio_probe passou novamente no Qt original,
com snapshot privado, perfil novo e rede desligada (`valid-*`). Esta execução
curta verifica a rota válida após a mudança; não substitui os percursos longos.
`preserved-proof.json` regista que os 343 hashes e os 25 casos positivos da
tarefa 37 permanecem inalterados. Não foram repetidas as campanhas longas,
nem alterados os seus resultados, a produção, o mapa ou o CSV.
