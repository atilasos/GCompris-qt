# Diagnosticar os encerramentos código139 nos ensaios Qt

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 02

## Âmbito

Reproduzir os encerramentos iniciais da leitura com stress curto, perfis e RCC
privados; comparar fonte inicial/atual e ambiente sem alterar a instalação.
O mesmo sinal surgiu no lote de memória paralelo; coordenar a recolha de stacks.
Conservar ferramenta reproduzível, hipóteses isoladas, limites e falhas reais.
Não declarar correção nem resolver esta tarefa se a causa não for demonstrada.

## Answer

Identificada uma causa da infraestrutura: reescrever um RCC registado enquanto
a aplicação o mantém mapeado. O ensaio controlado da tarefa23 reproduziu SIGSEGV
na resolução QResource/qsTr. Os horários dos encerramentos iniciais coincidem
com escritas de RCC pelo build principal, incluindo recursos de jogos inativos.

A tarefa25 passou a copiar todos os recursos e a validar o manifesto; a tarefa21
repetiu 12 casos, 34 percursos, 180 pares corretos e 42 errados sem debugger nem
encerramentos, usando o mesmo snapshot selado de 269 ficheiros. A leitura também
tem provas isoladas. Não foi acrescentado um guard no jogo para ocultar o sinal.

A conclusão refere-se a esta causa demonstrada e ao isolamento dos testes.
Os primeiros processos não tinham stack, e este replay não prova ausência de
qualquer outro defeito intermitente. [Diagnóstico](../reading-crash/README.md),
[isolamento](25-snapshots-recursos-nativos.md),
[replay final](../functional-memory/README.md).
