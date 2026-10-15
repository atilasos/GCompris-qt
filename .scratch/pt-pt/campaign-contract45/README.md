# Contrato das campanhas, tarefa45

Os subprocessos CLI temporários reproduziram os dois P2 da revisão43 antes da
correção. `red.log` conserva11 falhas. Alterar só o PO, o módulo IME ou o
launcher mantinha oito chamadas em vez de iniciar mais oito. Nos dois jogos,
lições999/0/-1 e1+999 não eram rejeitadas na fronteira, antes da preparação.

A retoma exige agora igualdade de `frozen_source_sha256` e `launcher_sha256`,
além dos hashes anteriores e retorno0. PO/CMake/adaptador já fazem parte da
identidade congelada. O novo campo do launcher é gravado nos novos recibos.
Um recibo antigo sem uma dessas identidades permanece arquivado e não pode
ser automaticamente certificado como prova com a identidade atual.

Os filtros são validados contra as lições existentes nos datasets antes de
criar output, congelar fontes ou ler snapshots. Mesmo que um dataset futuro
seja vazio, ausência de resultados não concede sucesso. A tabela CLI de memória
conserva os cinco pares atividade/caso sem casos aplicáveis. Não mudou produção
nem o executor de memória.

`green-words.log` verifica quatro testes, incluindo oito combinações inválidas
e três alterações independentes de identidade. As retomas sem alterações
continuam sem novas chamadas. `green-memory.log` verifica os cinco pares
inválidos e o sentinela que impede preparar dados. São fixtures normais de
subprocesso, sem afirmar execução Qt dos jogos.

`historical-receipts.json` confirma os174 resultados antigos,1740 perguntas,
retorno0 e hashes correspondentes. Nenhum foi alterado ou relançado. Hangman
35783 continua com as fontes já congeladas e o executor carregado anteriormente;
esta correção não interrompe nem reclassifica a campanha que está em curso.

```bash
python3 -m unittest discover -s tests/functional_word_letters -p 'test_*.py' -v
python3 -m unittest discover -s tests/functional_memory_rest -p 'test_runner_cli.py' -v
```
