# Diagnóstico do encerramento 139

O recibo original `penalty-complete` conserva Qt139, supervisor1 e ferramenta1,
embora as nove asserções de nível tenham passado. Não foi convertido em verde.
A repetição normal `penalty-replay` usa o mesmo caso e terminou Qt0/supervisor0/
ferramenta0. Duas repetições adicionais usam a cópia local do launcher aqui
preservada, que antepõe gdb ao executável, sem alterar o caso, tempos ou jogo.
Os dois logs mostram `exited normally`; não foi obtida stack de SIGSEGV.
Os seus metadados refletem o processo gdb, não são recibos de aceitação nativa.
Não existe core disponível (apport, /var/crash vazio). A causa do139 continua
por reproduzir; estes resultados não constituem uma correção desse evento.
A correção de barras que sobreviviam à navegação tem o seu próprio par curto
vermelho/verde, e não é atribuída ao139.

O journal do kernel no intervalo do encerramento contém um SIGSEGV de
gcompris-qt em libQt6Qml.so.6.10.2, offset0x2ab2ad. A resolução do símbolo local
é QV4::MemoryManager::collectFromJSStack+0x6d. Os ficheiros kernel/symbol/
disassembly guardam a observação e commands.json os retornos e hash da
biblioteca. A associação ao caso é temporal: o recibo nativo não guardou PID
para ligar diretamente o PID4137796. Isto não identifica a causa nem uma stack
completa. O log apport diz que recusou o core por mtime do executável.

O snapshot é físico e selado (269 ficheiros), e cada execução tem deployment,
perfil e RCC próprios. As fontes foram congeladas antes de executar os casos;
nenhuma destas repetições reescreveu RCC ou executável do snapshot. A hipótese
histórica de RCC reescrito enquanto mapeado não é presumida neste evento.
Por indicação do coordenador, a estabilidade desse encerramento terá tarefa
própria antes de aceitação global. Não se induziram outros crashes nem se
alterou framework para esconder a ocorrência.
