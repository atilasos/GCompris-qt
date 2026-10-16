# Tracker local em Markdown

As tarefas e especificações vivem em `.scratch/`.

## Convenções

- Uma pasta por funcionalidade: `.scratch/<slug>/`.
- Especificação: `.scratch/<slug>/spec.md`.
- Uma tarefa por ficheiro: `.scratch/<slug>/issues/<NN>-<slug>.md`.
  A numeração começa em `01`.
- Estado de triagem numa linha `Status:` perto do início.
  Usa os valores de `triage-labels.md`.
- Comentários acrescentados no final, sob `## Comments`.

Quando uma skill pedir para publicar uma tarefa, cria o ficheiro local.
Quando pedir para consultar uma tarefa, lê o ficheiro indicado.

## Wayfinding

- Mapa: `.scratch/<slug>/map.md`, com notas, decisões e dúvidas.
- Cada tarefa tem `Type: research`, `prototype`, `grilling` ou `task`.
- Regista o progresso em `Progress: open`, `claimed` ou `resolved`,
  separado do estado de triagem.
- Dependências: `Blocked by: NN, NN`.
- Uma tarefa fica desbloqueada quando todas as dependências estão
  resolvidas.
- Escolhe a primeira tarefa por número que esteja aberta, desbloqueada
  e por assumir.
- Antes de trabalhar, grava `Progress: claimed`.
- Ao resolver, acrescenta a resposta sob `## Answer`, grava
  `Progress: resolved` e referencia o resultado nas decisões do mapa.
