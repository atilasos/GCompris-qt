# 83 — próximo passo a partir das provas existentes

Análise de leitura, 2026-10-16. Não executei Qt/gdb, campanhas, stress ou VM;
não alterei driver, produto, provas ou build. `cause_known=false`,
`issue_resolved=false`; ticket aberto. Árvore examinada: pt-penalty-shutdown,
HEAD 9fdf638fda0b5475b4c4edf0de434f20a8865221.

## Factos comparáveis

Raiz: `.scratch/pt-pt/penalty-shutdown/`. O caso original, replay normal e dois
replays gdb têm exatamente o mesmo SHA de case.qml:
`31f23a59548cce259aea056aed3c9e5d793da9af095781561f9e18492d90faaa`.
Todos percorreram nove níveis, nove erros reparados, zero asserções falhadas.
O primeiro terminou139; os três replays0. Binário e imagem Docker declarados
são iguais nas quatro execuções (binário3a226ee7…, imagem28bd5fe8…).
O diff dos QML instrumentados original/replay contém só caminhos de screenshots;
não revela mudança de lifecycle ou da função de cleanup.

Os payloads gerados em jogo NÃO têm os mesmos bytes. Extração do marcador
`NATIVE_RESULT` físico de cada native.log (UTF-8, sem prefixo/newline):

| Execução | bytes | amostras trajetória (= barras) | SHA256 do marcador |
|---|---:|---:|---|
| original139 |371030|1589|eafc30fb43eb8d7479dc3d00c56667051d0bebfc36ed3a63e32437b9b29a2cae|
| replay0 |369019|1579|2c83047e39087e2ae1898d995457ec12aa50083f07640e54583e525c29bb2edb|
| gdb0 |368778|1579|260579edfec8815f2216fbbfba95942ae8056f610aa3ef76a72967c9344c4a0d|
| gdb2 0 |367732|1573|3a0884b2471049688ecbff29535c2e75c997eb8e4cbe1d284bcf765a2226d194|

Date.now e amostragem natural a cada wait(20) explicam diferenças esperáveis,
sem demonstrar um limiar causal. Nos probes baseline-logged/final-logged, o JSON
`DIAGNOSTIC_HISTORICAL_PAYLOAD` tem370981bytes e SHA
`f67b08f9965736aa27f98becd705d4ee9b5e187e7988f21761282ca3cb219a3c`:
ambos são exatamente iguais, após parse, a case_result.levels do original.
Isso cobre retenção/serialização daqueles dados, mas não a história de alocações
incrementais durante o jogo. Não cobre os campos exteriores failures/passes/
evidence do marcador original; essa diferença pequena não justifica, só por si,
outro ensaio de payload.

## Lifecycle e temporização que os registos permitem afirmar

O caso completo guarda apenas valores copiados (números/strings/objetos/arrays)
em levels; point() não guarda o QObject recebido. bonusResult() acumula arrays
incrementalmente durante animações. Após o último acerto, espera currentLevel0,
bonus.isPlaying=false e wait(700), depois cleanupTestCase faz JSON.stringify e
console.log. Esses passos são idênticos nos quatro casos. A duração entre os
primeiros/últimos segundos cliques foi78.431s no original,74.854s/74.831s/74.757s
nos replays; isso não é o intervalo cleanup→process exit.

O log original contém o marcador completo seguido de três linhas
`DownloadManager: shutting down, 0 active jobs`. Os três replays mostram a mesma
sequência; os gdb acrescentam `exited normally`. Não há timestamps desses
marcadores/cleanup, portanto não podemos quantificar o intervalo final nem
atribuir o sinal a JSON.stringify (que terminou e emitiu o marcador).

O launcher histórico espera o processo e só então faz parse do log/escreve o
recibo. Esse parse Python não corre no heap QV4 do inferior. No QML congelado,
onStop da página pára timerFail/ballAnim e chama Activity.stop(), que é vazio.
Bonus termina e emite win→nextLevel→initLevel; o caso espera já esse retorno.
Não existe prova de que o stop da página tenha sido emitido antes de sair.

No TestCase.qml instalado ATUAL (`/usr/lib/x86_64-linux-gnu/qt6/qml/QtTest/`),
cleanupTestCase antecede finishTestData/finishTestFunction, stopLogging e Qt.quit.
Isso identifica uma fronteira investigável, não prova os bytes do QtTest usado
no original. O main.cpp congelado liga engine.quit a DownloadManager::shutdown.
As linhas shutdown localizam progresso de saída; não provam destruição completa
do engine nem execução de Core.quit/onClosing.

## Lacuna real de identidade do ambiente

O snapshot269 sela binário/RCC/QM e libqmlbox2d, mas NÃO sela bibliotecas Qt,
plugins de sistema, libc nem QtTest/TestCase.qml. O Docker monta `/` do host
read-only e faz chroot no host: o SHA da imagem Alpine não identifica essas
bibliotecas. commands.json preserva SHA8e84dc9a… de libQt6Qml.so.6.10.2 observada
na análise posterior, sem maps/build-id ligado ao PID original. Os novos
inferior-status ligam PID/cmdline/binário/namespace, mas não listam mappings ou
identidades das bibliotecas carregadas. A namespace dos dois gdb antigos era
incompatível com /proc e o runtime antigo já não existe. Não é possível
recuperar retroativamente essa identidade. Nenhuma destas lacunas prova que
houve atualização/reescrita de biblioteca.

O PID do journal permanece associado temporalmente; o símbolo
collectFromJSStack localiza o endereço, não uma causa GC. O OOM matou qemu,
não este processo; não proponho recriar pressão. A reescrita de RCC demonstrada
na23 continua hipótese histórica distinta, não diagnóstico83.

## Hipótese concreta e, no máximo, um ensaio proposto

Hipótese de trabalho, não conclusão: se a falha depende do heap formado pela
campanha e da transição QtTest→quit/destruição, um eventual sinal ocorre DEPOIS
do marcador emitido e pode ser separado de atividade em curso por eventos
nativos de saída. Os seis probes ociosos não cobrem essa história; os dois
replays completos gdb já cobrem o fluxo sem localizar essa fronteira porque
usavam run+thread apply all bt, sem marcos de lifecycle ou mappings.

Só se root considerar a nova observação suficiente para justificar execução:
**um único replay completo do caso histórico idêntico**, fonte final congelada,
deployment/snapshot privados imutáveis, gdb com PID namespace alinhada. Antes,
confirmar por leitura dos símbolos a viabilidade dos pontos de observação.
Capturar uma vez mappings/build-id/SHA dos ficheiros efetivamente carregados,
incluindo QtQml/Quick/Test/QtTest QML e libc; observar sem alterar estado/relógios
os marcos QCoreApplication::aboutToQuit, DownloadManager::shutdown e destruição
de QQmlEngine (contadores/marcos pequenos, sem tracing de toda a campanha).
No primeiro SIGSEGV, stack de todas threads, registos e mappings antes de parar.
Guardar sempre retornos separados inferior/supervisor/tool. Não substituir
cleanup nem limpar arrays/forçar GC/emitir stop para fazer desaparecer o sinal.

Esse ensaio produziria uma cronologia nativa de saída e identidade de libs que
os replays existentes não têm; não é uma recomendação de aumentar repetições.
Se terminar0, arquivar como inconclusivo e não ampliar automaticamente. Se os
símbolos/ambiente não permitirem os marcos, não lançar por rotina: aguardar uma
ocorrência natural com instrumentação de identidade já preparada. Não há
justificação atual para uma correção de produto.
