## Browser para agentes

Quando uma tarefa exigir interação com um browser real, utiliza a skill
`agent-browser-hub` e o servidor MCP `agent-browser-hub`. Usa o perfil
`research` por defeito, fecha sessões no final e pede confirmação antes
de ações externas irreversíveis.

## Agent skills

### Issue tracker

Para criar, consultar ou atualizar tarefas, usa o tracker Markdown local
em `.scratch/`. Consulta `docs/agents/issue-tracker.md`.

### Triage labels

Para fazer triagem, usa os cinco estados predefinidos.
Consulta `docs/agents/triage-labels.md`.

### Domain docs

Antes de explorar o código, consulta `docs/agents/domain.md`.
O projeto usa um único contexto, com `GLOSSARY.md` e `docs/adr/`.
