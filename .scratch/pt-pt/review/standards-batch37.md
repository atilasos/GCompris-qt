Revisão Standards de `cfab58993...e06c968fc0bc2e6a324177814db9c01cc48b6882`, incluindo os três commits do intervalo.

- **P2, confiança alta, sucesso sem executar casos** — `tests/functional_memory_rest/run.py:98–109`: o filtro remove combinações sem caso aplicável, mas `all([])` produz `passed: true` e saída0. Por exemplo, `--activity memory --case audio_probe` não executa Qt nem verifica o snapshot; `--activity memory-tux --case configuration` tem o mesmo problema. Reproduzi o primeiro em /tmp com Node simulado: o executor terminou0 e guardou `cases: []`. Construir e validar a lista de tarefas antes da preparação, rejeitar combinações sem casos e exigir resultados não vazios para declarar sucesso. Acrescentar uma regressão para ambas as combinações.

A prova atual permanece distinta deste defeito do executor: os25 resultados referenciados pelo índice fixo têm SHA256 correspondente, `passed: true` e `exit_code: 0` do Qt; cada um corresponde também a uma entrada única com saída0 do launcher no summary da respetiva execução. Não repeti as campanhas longas.

**Violações documentadas:** nenhuma nova identificada após leitura de AGENTS.md, README e regras de domínio/tracker/triagem. Não existe alteração nova em src neste intervalo.

**Smells:** nenhum adicional suficientemente relevante para reportar. O fragmento áudio comum concentra a observação repetida; os casos preservam os eventos e recursos reais. Os limites de reprodução física, pronúncia e Windows são explícitos e não foram convertidos em novos achados.

Sem alterações de código/build. A reprodução usou apenas mocks e ficheiros temporários, sem modificar os recibos arquivados.
