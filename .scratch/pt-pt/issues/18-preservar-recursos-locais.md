# Preservar recursos locais mais recentes após consultar atualizações

Status: ready-for-agent
Progress: claimed
Type: task
Blocked by: 02

## Defeito reproduzido

Com rede, a aplicação lê primeiro o índice local com as 1610 vozes, depois o
índice upstream anterior substitui a seleção e volta a registar o RCC de 1578.
O modo offline não apresenta essa regressão. Não se resolve desligando a rede.

## Aceitação

- Conservar um RCC local mais recente apenas quando existe e o checksum é válido.
- Manter o checksum selecionado no trabalho de atualização, sem pedir ao servidor
  um nome local que ele não possui.
- Aceitar atualizações upstream genuinamente mais recentes e reparar recursos
  locais ausentes/corrompidos.
- Conservar a seleção em reinícios offline e a separação entre pt e pt_BR.
- Verificar o DownloadManager real, com RCC Qt e um servidor HTTP local.

## Implementação e verificação do agente

A seleção interna conserva nome e checksum juntos. Um índice remoto mais antigo
só substitui a seleção se o recurso local mais recente estiver ausente ou
corrompido. A fila reutiliza o checksum local, sem pedir ao servidor esse nome.
No arranque, todos os índices locais são reconciliados; o registo offline
confirma o checksum para distinguir ficheiros com o mesmo nome.

Testes reais com HTTP local e RCC produzido pelo Qt: versão upstream mais
antiga, atualização mais recente, reparação de ficheiro ausente/corrompido,
reinício offline, precedência entre pacote e cache e colisão de nomes com
checksums diferentes. As regressões de downgrade, reinício e colisão falharam
antes das respetivas correções. O teste mantém pt e pt_BR separados.

Build privado: `build/resource-updates`; `DownloadManagerTest`: 28 passaram,
zero falhas. Registos locais: `/tmp/pt-resource-updates-before.log`,
`/tmp/pt-resource-updates-restart-before.log`,
`/tmp/pt-resource-updates-collision-before.log` e
`/tmp/pt-resource-updates-full.log`. Estes RCC de teste contêm sentinelas de
bytes para provar seleção e registo; a descodificação das vozes reais pertence
à tarefa 05. Não equivale a aprovação pedagógica nem validação integral dos
203 jogos. Windows nativo com esta alteração será verificado no próximo
candidato CI; a audição em hardware Windows permanece para o professor.

## Integração

Implementação integrada para revisão e revalidação. `Progress: claimed` conserva
um dos três estados do tracker; a entrega Windows e a audição final são tarefas
separadas. A dependência é a compilação 02, pois os testes usam RCC sintéticos
e não dependem da aprovação humana das gravações da tarefa 05.
