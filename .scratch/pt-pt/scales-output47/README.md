# Preservação de provas de balanças, tarefa47

O vermelho CLI reproduz a sobrescrita de `case.qml` numa saída arquivada,
apesar da recusa do launcher. A fixture conserva caso, JSON e ficheiro binário
aninhado. A recusa tem de preservar todos os bytes e não preparar nem lançar
nada. A mesma tabela cobre diretório vazio já existente e ficheiro existente.

O wrapper reclama agora uma saída nova com mkdir sem exist_ok. Se já existir,
recusa antes de gerar casos. O caso temporário tem diretório privado por
invocação, fora da saída que o launcher exige vazia. Só depois da chamada é
copiado para a saída que esta invocação reclamou. A limpeza do temporário usa
um contexto, também quando o launcher devolve erro.

`red.log` conserva seis falhas. `green.log` verifica dois testes com as três
formas de saída existente e duas invocações novas, retorno0/2. Confere a cópia
do caso na saída própria, nomes temporários distintos e limpeza. As fixtures
são subprocessos CLI normais, não uma campanha Qt de balanças. Os cinco testes
do auditor continuam verdes em `auditor.log`.

`historical-receipts.json` confirma os nove hashes de resultados e de casos
originais, sem alterações ou repetição dos666 puzzles. A campanha Hangman35783
não foi interrompida. Não há mudança de produção ou build principal.

```bash
python3 -m unittest discover -s tests/functional_scales -p 'test_runner_cli.py' -v
python3 -m unittest discover -s tests -p 'test_scales_math_audit.py' -v
```
