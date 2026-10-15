# Inventariar atividades e lacunas PT-PT

Status: ready-for-agent
Progress: resolved
Type: task

## Aceitação

- Uma linha por atividade de `src/activities/activities.txt`.
- Contagens reproduzíveis de mensagens não traduzidas, fuzzy e marcadores Qt.
- Identificação de JSON PT e candidatos a dados locais em falta.
- Resultados estáticos separados de resultados funcionais.
- Testes do leitor PO e comparação independente das contagens.

## Comments

Ferramenta: `tools/audit-pt-pt.py`. Relatórios: `../reports/`.

## Answer

Inventariadas 203 atividades. O relatório inicial está em `../baseline-audit.json`;
o relatório atualizado está em `../reports/`. As contagens PO iniciais coincidiram
com as de Babel, usado como leitor independente. Os quatro testes Python passaram.
Uma nova execução produziu relatórios idênticos, e `--check` terminou com código 1
enquanto existirem lacunas no catálogo das vozes. Nenhuma atividade foi marcada
como testada em execução.
