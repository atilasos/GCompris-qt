# Preparar as fontes das campanhas sem corridas

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 68

## Achado Standards 68

P2 em campaigns.py:23 e phase.py:14 da prova das retas graduadas. Seis runners
podem chamar freeze() para a mesma pasta. O ficheiro torna-se visível antes de
a escrita terminar, permitindo que outro runner leia bytes vazios ou parciais.

Relatório: /tmp/gcompris-review-standards68.md
Reprodução sem Qt: /tmp/repro-standards68-freeze-race.py

## Aceitação

Um único implementador corrige os achados de revisão deste lote. Preparar a
fonte uma vez antes do trabalho paralelo e/ou eliminar estruturalmente a pasta
partilhada incompleta. Guardar teste concorrente que reproduz o defeito e passa
com a correção. O tratamento de falhas e repetições deve preservar a identidade
completa, sem aceitar ficheiros parcialmente publicados.

Não repetir Qt nem alterar os 22 recibos, catálogos históricos, casos ou
recursos já fixados. Conferir a igualdade dos blobs antes/depois e repetir o
auditor puro e os testes relevantes. Sincronizar integração antes de entregar;
merger e recheck independentes. Nenhuma aprovação global ou Windows muda.

## Answer

Publicação atómica de árvores privadas completas, validação do vencedor e
preparação antes do pool com commit resolvido. Quatro regressões novas e os
12 testes existentes passam; auditor puro mantém os 22 recibos. Os 307
ficheiros históricos conferidos são iguais aos blobs Git de partida.

Provas e comandos: [source-preparation/README.md](../source-preparation/README.md).
Sem execução Qt ou alteração do arquivo histórico. Pronto para merger e
recheck independentes; nenhuma aceitação global muda.

## Integração

Correção integrada para recheck independente. `ready-for-review` não fecha
a tarefa 68; provas históricas preservadas, sem repetição Qt.

## Fecho de revisão

P2 fechado por recheck independente; [relatórios](../review/integration68-72/).
Resolução limitada ao âmbito Linux publicado, sem aceitação global.
