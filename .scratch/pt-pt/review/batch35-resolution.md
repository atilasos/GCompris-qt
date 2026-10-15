# Revisão dos lotes 30, 31 e 35

Intervalo fixo `877eed623b0e44d093ec37e95a51ba38063d7768...5dfd78a0d5db70b2f552f8ef4bdff26aa0750a40`.

## Standards

Um P2 confirmado: runner decimal podia aprovar JSON verde após retorno nãozero
do launcher. Corrigido por um único implementador em `a1bbc2c80cb5fe5cc4d3f4eca67efc6a7128de37`,
integrado em `44503ab92`.
A prova reproduz a CLI e cobre três retornos/resultados; quatro testes do
auditor também passaram. Os vinte casos finais originais têm retorno zero
e não foram invalidados. [Correção e prova](../decimal-runner-boundary/README.md).
[Relatório independente](standards-batch35.md).

## Spec

Zero novos achados. Foram revalidados os auditores de decimais/complemento,
os recursos aprovados e os hashes, sem confundir os critérios Windows/docente.
[Relatório independente](spec-batch35.md).

Totais: Standards1 P2 corrigido; Spec0.
