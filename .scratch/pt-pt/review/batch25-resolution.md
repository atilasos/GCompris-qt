# Revisão do lote 25

Intervalo revisto: `1ac947fbcf3ea2e2184849daf6c7f64ee6e6e23e...fb787df936325e5a5d929e572a2dbb4927a80e5c`.

## Standards

Um P2: o tmpfs ocultava deployments ou snapshots guardados em `/tmp`.
Corrigido por um único implementador em `db5bbb0605e6171240d0480dcc615b4373ce63b8`, integrado em `75f56f71f7e79d90ce3357d2b643a6cbc51e7774`.
Os dois casos Qt reais reproduziram a falha e passaram após montar explicitamente
deployment e snapshot em leitura. Os quatro testes unitários também passaram.
Prova e comando reproduzível: [tarefa 25](../issues/25-snapshots-recursos-nativos.md) e `tests/native_qml_resources/check_tmp_offline.py`.
Relatório independente: [Standards](standards-batch25.md).

## Spec

Sem novos achados acionáveis. A revisão não declara a especificação concluída.
Relatório independente: [Spec](spec-batch25.md).

As tarefas 27 e 28 não pertencem a este intervalo de revisão.
