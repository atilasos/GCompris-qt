# Recheck Spec43 — correção45

Inspecionados o conteúdo03e961d28, integração24b03c952f3aeed6a22e2ffdd02dedefb11f3142, contrato de retoma e evidência em `.scratch/pt-pt/campaign-contract45/`.

**Ambos os achados estão corrigidos; confiança alta.**

- A retoma exige agora `frozen_source_sha256 == frozen_sha` e `launcher_sha256 == launcher_sha`, juntamente com os hashes anteriores. PO, CMake e adaptador fazem parte do digest congelado. Recibos antigos sem a identidade nova permanecem históricos e não são aceites como prova atual. A regressão CLI confirma novas execuções após alterar PO, adaptador ou launcher, e ausência de novas execuções numa retoma sem mudanças.
- Lições inexistentes, zero, negativas e combinações válidas/inválidas são rejeitadas antes de criar output, congelar fontes ou preparar snapshots. Uma lista de resultados vazia também deixou de devolver sucesso. A tabela declarativa do executor de memória conserva a rejeição das cinco combinações sem casos aplicáveis.

Isto satisfaz a exigência da spec33–35: “Cada conclusão é sustentada por evidência”, sem atribuir sucesso a uma campanha vazia nem reutilizar automaticamente provas anteriores a entradas relevantes alteradas.

Verificação repetida: três testes CLI de palavras/letras e um teste CLI de memória passaram. São subprocessos temporários; não executei novas campanhas Qt.

Conferi independentemente174 recibos/1740 perguntas, todos os hashes dos relatórios e o SHA do resumo `991180e0d172574900494288d07fb122cfd6cdadbbb4a5bb9fbd0689f82d8cea`. O diff dos recibos históricos entre5ef7db807 e a integração24b03c952 está vazio. Não foram inventadas identidades em falta nem alteradas provas antigas. A documentação mantém Hangman em curso e não declara a tarefa38 concluída.

Sem novos achados neste recheck. Nenhuma alteração ao código/build efetuada pelo revisor.
