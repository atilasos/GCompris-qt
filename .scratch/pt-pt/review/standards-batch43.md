Revisão Standards delimitada de `9594905c7...5ef7db807`, lotes38/43/44; lista de commits consultada. Tarefa41 e documentos repetidos de37 excluídos.

- **P2, confiança alta, retoma ignora entradas congeladas** — `tests/functional_word_letters/run.py:42–57,108–112`: freeze_sources identifica PO, CMake e adaptador IME, mas a retoma compara apenas fonte da atividade, caso, snapshot e relatório. Não compara `frozen_source_sha256` com o novo `frozen_sha`. Reprodução com as fixtures CLI existentes: após oito casos verdes, alterei apenas o catálogo PO e executei --resume; devolveu0 e continuou com oito launchers, reutilizando toda a prova anterior. Comparar o digest congelado completo e acrescentar regressões para PO/IME alterados. Isto também cumpre a promessa documentada de retoma apenas com entradas coincidentes.

- **P2, confiança alta, filtro vazio dá sucesso** — `tests/functional_word_letters/run.py:83–86,133–140`: `--lesson 999` elimina todas as tarefas; `all([])` permite saída0 sem launcher nem summary.json. Reproduzido com a mesma fixture em /tmp. Validar lições aplicáveis e rejeitar tarefa vazia antes de criar a saída; exigir resultados não vazios para sucesso.

Os174 recibos finais de Letra na palavra têm hashes de relatório correspondentes e Qt/launcher0. Os achados referem-se à fiabilidade futura do executor; não invalidam automaticamente esses recibos.

**Violações documentadas:** nenhuma outra identificada nas normas locais. **Smells:** nenhum adicional relevante. Não encontrei regressão concreta no contador Hangman, publicação dos seis níveis dos peixes ou clamp das setas do pato. O pacote44 conserva propostas pending, bytes antigos e aprovação separada dos32 áudios; não instala substituições.

Sem campanhas longas ou alterações no repositório. As duas reproduções usaram subprocessos de fixture e ficheiros temporários.
