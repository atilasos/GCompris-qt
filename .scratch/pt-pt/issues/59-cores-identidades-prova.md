# Validar identidades das fontes nas provas das cores

Status: ready-for-agent
Progress: resolved
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

## Answer

Auditor ligado à revisão histórica 53c2fe61e, com conjunto/caminho/SHA/tamanho
verificados para os 330 ficheiros dos cinco RCC. Os três manifestos de snapshot
são ligados aos mapas efetivos dos 19 recibos, incluindo RCC/QM privados.
source_sha256 e runner_sha256 são conferidos contra blobs Git; os dois
catálogos históricos são conferidos separadamente, preservando fauno no
recibo 160 e fulva nas quatro rotas corrigidas. Sem fonte atual ou abertura
de caminhos operacionais absolutos históricos.

Nove testes CLI passam, com prova válida movida, 19 negativos de identidades e
checkout com fonte/launcher/catálogo atuais diferentes. Cinco testes anteriores
também passaram. Os 201 artefactos e o índice originais conservam os bytes;
19 casos/254 puzzles preservados, sem novas campanhas Qt ou builds.

Provas em `../colors-identity59/README.md`, incluindo red/green, preservação e
nova saída de auditoria. Nenhuma alteração de produção/mapa/CSV/push; limites
Windows, hardware, áudio/perceção e professor da 53 mantêm-se.
