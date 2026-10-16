# Diagnosticar o encerramento intermitente após penáltis

Status: ready-for-agent
Progress: open
Type: task
Blocked by: 02, 25

## Observação

A campanha `penalty-complete` da tarefa 81 concluiu nove níveis, com nove erros
reparados e zero asserções falhadas, mas o processo terminou com código 139.
O supervisor e a ferramenta externa terminaram com 1. A prova original deve
permanecer intacta e fora das campanhas verdes. Três repetições completas,
incluindo duas sob gdb, terminaram com 0. Ainda não existe causa demonstrada.

O implementador da 81 encontrou no journal um SIGSEGV em
`QV4::MemoryManager::collectFromJSStack(QV4::MarkStack*) const` da biblioteca
QtQml 6.10.2. O core não foi preservado. O endereço ajuda a localizar a falha;
não demonstra, sozinho, um defeito do Qt, de áudio ou do motor do jogo.

## Aceitação

Recolher os registos físicos da tarefa 81 e estabelecer uma cronologia dos
processos, fontes congeladas, snapshot e deployments privados. Comparar com a
causa de RCC reescrito da tarefa 23, sem assumir equivalência. Verificar hashes
e independência dos ficheiros antes de atribuir uma causa.

Usar reprodução finita e isolada, sem induzir crashes por escritas em recursos
mapeados. Se houver reprodução, recolher stack/core e testar uma hipótese de
cada vez. Qualquer correção necessita do mesmo caso antes/depois e de retornos
observados do processo, supervisor e ferramenta. Não mascarar o sinal, alterar
relógios dos jogos, reescrever recibos ou transformar tentativas verdes numa
prova de ausência da falha.

Se a causa continuar desconhecida, documentar a incerteza e manter a tarefa
aberta. As conclusões funcionais finitas da 81 devem ser distinguidas desta
pendência de estabilidade. Não aprovar Windows ou aceitação global.
