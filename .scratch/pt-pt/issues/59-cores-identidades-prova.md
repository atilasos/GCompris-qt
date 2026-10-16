# Validar identidades das fontes nas provas das cores

Status: ready-for-agent
Progress: claimed
Type: task
Blocked by: 53

## Âmbito

Resolver o P2 Standards53: o auditor conta 330 entradas de fonte/RCC mas
não compara caminhos/SHA com a revisão ou inventário capturado, nem liga
source_sha256/runner/catalogue dos recibos a identidades verificadas.
O revisor conferiu as 330 fontes e os 19 casos atuais, portanto preservar
todos os recibos e as 254 conclusões; não repetir Qt.

Fixar a identidade histórica de fontes/gerador/catálogo e validar cada mapa
de ficheiros RCC, sem depender de worktree absoluta ou do fonte atual.
Testes reais devem rejeitar corrupção de hash/caminho/identidade mantendo a
prova original válida. Não normalizar bytes históricos nem alterar produção.
