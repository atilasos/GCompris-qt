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

## Investigação finita entregue, causa desconhecida

Cronologia física de 139 e três replays anteriores preservada do commit 81
imutável. O vínculo do PID do journal continua temporal; snapshot/deployments
históricos removidos não foram tratados como inodes verificados. OOM global
40 segundos antes matou outro processo, sem causalidade demonstrada. Não se
presume equivalência à reescrita de RCC da 23.

Seis ensaios curtos autorizados (baseline/final × bare/retained/logged) terminaram
0, com PID/cmdline/hash/namespace observados e retornos separados do inferior,
wrapper, supervisor e executor. Nenhuma partida nova, relógio alterado, pressão
de memória induzida ou correção de produção. O snapshot atual tem 26 diferenças
para o histórico, explicitadas. A ferramenta finita e o auditor físico/cópia/
adulteração/-O estão em [provas e limites](../penalty-shutdown/README.md).

A tarefa permanece open, conforme o critério de aceitação. Os seis 0 não eliminam
a hipótese, não provam estabilidade, não aprovam Windows e não bloqueiam outras
validações funcionais. Uma futura reprodução precisa de stack/core e vínculo
de processo demonstrado antes de justificar correção.

## Correção da ferramenta após revisão P2

O runner futuro usa um único critério de continuação e veredito: retorno 0 do
supervisor e do inferior, ausência de sinais e identidade/cmdline/namespace
observados e compatíveis. Uma falha interrompe ambos os ciclos, mesmo quando o
wrapper devolve 0. A regressão CLI sem Qt reproduziu o SIGSEGV que antes iniciava
três ensaios adicionais; cobre também saídas não zero e identidade ausente ou
incompatível, além da matriz saudável de seis ensaios. As ferramentas arquivadas
e as seis provas históricas permanecem intactas. Esta correção não diagnostica
o 139 original; a tarefa continua open.

## Revisão do artefacto de investigação

Driver interrompe toda a matriz por falha real do inferior, mesmo com wrapper0.
P2 corrigido; Standards e Spec revalidados sem achados restantes no artefacto.
[Relatórios](../review/integration83/README.md). A causa original permanece
desconhecida, pelo que esta tarefa continua aberta.
