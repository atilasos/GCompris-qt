Revisão Standards delimitada de `5ef7db807...599ed851b018a3ea5c2b81c94c3941b2d38d45b7`, fontes/testes/provas novas da tarefa34; commits consultados.

- **P2, confiança alta, executor pode corromper prova existente** — `tests/functional_scales/run.py:79–86`: depois de o launcher recusar um diretório --output já preenchido com saída2, o wrapper ainda copia o caso recém-gerado para `output/case.qml`. Uma repetição com opções diferentes sobrescreve assim o caso exato de uma prova antiga, embora a execução tenha sido recusada. Reprodução isolada com ROOT temporário e launcher simulado a devolver2: o case.qml original foi substituído. Validar/reclamar uma saída nova antes de gerar ficheiros e copiar apenas para a saída pertencente à execução atual. Acrescentar regressão CLI que recuse a repetição e preserve todos os bytes antigos.

**Provas atuais:** conferi os nove recibos finais contra o tip fixo. SHA256 dos JSON e casos corresponde ao índice; casos e fonte Scalesboard correspondem aos hashes internos; todos têm Qt0, zero falhas e nenhum erro QML. Reexecutei apenas a auditoria Decimal sobre os666 puzzles arquivados e os tracers físicos: passou. Os cinco testes Python do auditor e exemplos Node passaram. Não repeti campanhas Qt.

Não identifiquei caminho concreto adicional de seleção vazia/falso sucesso. O executor devolve falhas do launcher e o modo completo exige contagens exatas; o achado acima afeta preservação de provas futuras, sem invalidar os nove casos existentes.

**Violações documentadas:** nenhuma outra identificada nas normas locais. **Smells:** nenhum adicional relevante. As relações de unidades/oráculo estão concentradas e os limites do tracer sem teclado visual, hardware, áudio e Windows estão explícitos.

Sem alterações de código/build/provas; reprodução só em /tmp.
