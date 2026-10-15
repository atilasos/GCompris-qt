Revisão de `877eed623b0e44d093ec37e95a51ba38063d7768...5dfd78a0d5db70b2f552f8ef4bdff26aa0750a40`, incluindo a lista de commits.

- **P2, confiança alta, falso sucesso no executor decimal** — `tests/functional_decimals/run.py:52–56,66` guarda `result.returncode`, mas calcula `passed` apenas com `report.passed` e o número de conclusões. O launcher grava result.json antes de limpar o deployment; pode devolver erro depois de Qt passar. Esse erro fica ignorado pelo lote. Reprodução isolada em /tmp, com subprocess simulado: quatro launchers devolveram1 e relatórios verdes; o executor terminou0. Exigir `result.returncode == 0` juntamente com os restantes critérios e acrescentar uma regressão para JSON verde/launcher falhado.

A prova final arquivada não sofre deste defeito: confirmei os20 resultados de `functional-decimals/index.json`, os16 launchers de `offline-campaigns/summary.json` e os4 de `final-controls/summary.json`; todos têm saída0 e resultado verde. O antigo offline-controls inclui uma subtração falhada, identificada como diagnóstico e excluída do índice final.

**Violações documentadas:** nenhuma nova identificada. AGENTS.md/README e as regras existentes de domínio/tracker foram consideradas; não surgiram CONTRIBUTING/CODING_STANDARDS.

**Smells:** nenhum suficientemente relevante neste intervalo. A função comum de estado de aprovação evita duplicar a regra nos dois produtores. A correspondência exata de texto+SHA conserva apenas aprovações válidas; NOTICE e manifestos respeitam a confirmação recebida. Não identifiquei regressão adicional nas alterações de produção35.

Sem alterações de código/build; a reprodução usou apenas ficheiros temporários e mocks, sem executar jogos nem modificar provas históricas.
