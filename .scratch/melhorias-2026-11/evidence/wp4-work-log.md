<!-- SPDX-FileCopyrightText: NONE -->
<!-- SPDX-License-Identifier: CC0-1.0 -->
# WP4: O meu trabalho

Verificação em 2026-11-10, no checkout `feat/game-improvement-plan`.
Fonte testada: `e7b89dc986aed99d6a7b7db1a88efcf9ca5940d8`.
Base: `a919b1425b460f4398051308c2132494f0563c5d`.
O commit seguinte acrescenta apenas esta evidência. Não houve push, PR,
publicação, alterações a atividades individuais, `poqm/`, instalador ou site.
O changelog e a entrega do site pertencem ao WP6 do plano.

## Comportamento e desenho

`WorkLog` é um singleton QML C++, registado explicitamente no plugin para
`WITH_RCC`, também anotado para a compilação sem RCC. Guarda apenas uma lista
em memória de identificadores de atividade e contagens. A propriedade de leitura
`entries` devolve cópias, com `activityId`, `hasRounds` e `rounds`. Não depende de
`ApplicationSettings`, `QSettings`, ficheiros, relógios ou identidade do aluno.
Uma nova instância começa vazia. Não há gancho de saída nem gravação ao terminar.

`activityStarted()` mantém a ordem da primeira abertura e seleciona a entrada
existente ao reabrir. Repetir a chamada não duplica nem reinicia a contagem.
`roundCompleted()` sem atividade é ignorado e `clear()` limpa também a atividade
corrente. O menu não entra no registo.

O gancho comum está em `Menu.loadActivity()`, antes do fluxo existente, que
serve os cartões, a sequência e o lançamento direto. A única linha acrescentada
a `Bonus.good()` é `if (!isPlaying) WorkLog.roundCompleted();`: conta o sucesso
antes do `win()` atrasado e ignora repetições durante o bónus. O fluxo de jogo
não muda. Os jogos CRJM continuam sem contagem de rondas.

A entrada visível fica à direita, imediatamente acima da barra inferior do
menu, com `Ctrl+T`. O ciclo Tab passa das atividades para este botão e volta às
secções, ou às atividades quando as secções estão ocultas. Shift+Tab no botão
volta às atividades. O atalho funciona também quando o campo de pesquisa tem
foco e só está ativo no menu. A entrada fica desativada durante o carregamento.

`DialogWorkLog.qml` usa a pilha de diálogos do menu e os componentes core
`BoardGameText`/`BoardGameButton`, que dimensionam pelo espaço da janela,
e `GCStyle`. Consulta título e objetivo em `ActivityInfoTree.menuTreeFull`,
sem mudar a atividade corrente ou guardar textos. A lista faz scroll por gesto,
barra, setas e Page Up/Page Down; o cabeçalho e os botões ficam disponíveis.
O foco inicial vai para «Fechar». A confirmação de limpeza foca «Voltar»;
Esc cancela a confirmação e, fora dela, fecha a vista.

O bloco partilhado `activityParticlesArea`/`activityParticles`/`burstParticles`
foi comparado byte a byte com `a919b1425` e está igual, SHA256
`3d8a3124927c956cd2c597272de03c8c13aa6794967f86c8cde067e44f541596`.

## Textos novos exatos

Todos estão em `qsTr()`, em pt-PT, AO90:

- `O meu trabalho`
- `Copia para o teu plano o que fizeste e escreve como correu.`
- `Rondas concluídas: %1`
- `—`
- `Ainda não há atividades nesta sessão. Escolhe uma no menu!`
- `Começar de novo`
- `Já copiaste para o teu plano? Queres apagar esta lista?`
- `Voltar`
- `Apagar a lista`
- `Fechar`

Os títulos e objetivos existentes continuam a vir dos respetivos `ActivityInfo`.
Na captura de aceitação aparecem «Contagem dos itens», «Pratica a contagem de
pequenas quantidades.», «Dominório» e «Antecipar jogadas e desenvolver o
raciocínio espacial.». A contagem apresentada é `1` ou `—`, sem avaliação do aluno.

## Binário, recursos e isolamento

Qt 6.10.2, Linux, Ninja, `BUILD_TESTING=ON`, `WITH_RCC=ON`.
Binário `build/pt-pt/bin/gcompris-qt`, SHA256:

```text
67eb9c1a6e1279a74691a90cf82f2d7cdb64a330b747b9a20088b62d94b8fa87
```

O CMake foi reconfigurado para incluir o ficheiro QML novo no glob do core.
A compilação completa foi feita com prioridade reduzida e quatro tarefas.
Os alvos RCC são `ALL`; ficaram atualizados o binário, core, menu, Enumerate
e Dominório. Foi criado depois um snapshot independente novo:
`/tmp/wp4-snapshot-final`, 265 ficheiros, sem reutilizar snapshots anteriores.
O manifesto está em [resource-manifest.json](wp4-native/resource-manifest.json),
SHA256 `843b56ff26c6cdfb32394358324c193bbae7e1d1181a0452f1baf7840979f7b0`.

| Recurso do build e snapshot | SHA256 |
| --- | --- |
| `core.rcc` | `e3f7d8248ea1eb141f60bfcab91a07a4bd5a32cbac783df8d6d23a21e65ae54e` |
| `menu.rcc`, antes da instrumentação | `8cbfb036a5a629a2a79f0dfc3e05bd0ed79f23b1d47b3f295126cbb1567ba8cf` |
| `enumerate.rcc` | `aff1a39463f11e35eeeba9cdc8a309d626ea39a91f246e981ae59ef8179365f4` |
| `dominorio.rcc` | `d01dbc4369bd2370587286bb5f2e01d77f9652634f386b5f091c60ac2b4e3821` |

Em cada execução o runner recompilou somente o menu instrumentado e o catálogo
PT privado, a partir da fonte desta revisão. Não se usou `--extra-activity`:
core e ambas as atividades vieram dos RCC reais do CMake. Os hashes efetivos
nos quatro `result.json` foram comparados com o manifesto e o build; coincidem.
O SHA256 da fonte `Menu.qml` também coincide em todos os relatórios.
[summary.json](wp4-native/summary.json) regista estas verificações, a revisão e
os hashes das fontes e PNG conservados.

O runner foi lido antes de correr a aplicação: cria `profile/config`,
`profile/data` e `profile/cache` privados e define `XDG_CONFIG_HOME`,
`XDG_DATA_HOME` e `XDG_CACHE_HOME`. Escreve só nesse perfil a configuração inicial,
com descargas automáticas desligadas. Todas as execuções usaram `--offline`,
Docker com rede `none`, renderização software e áudio silenciado. A aplicação
não correu contra a configuração real do utilizador. Não se confundem as
escritas normais do runner/aplicação com o registo: o teste C++ do `WorkLog`
isola também `HOME` e verifica uma pasta de perfil vazia antes e depois de
abrir, contar, ler, limpar e destruir o registo.

## Comandos reproduzíveis

Executados a partir da raiz deste checkout; usar pastas novas ao repetir:

```sh
cmake -S . -B build/pt-pt
nice cmake --build build/pt-pt --parallel 4
LC_ALL=en_US.UTF-8 QT_QPA_PLATFORM=offscreen ctest --test-dir build/pt-pt --output-on-failure
python3 tools/native_qml_resources.py --binary build/pt-pt/bin/gcompris-qt --output /tmp/wp4-snapshot-final
python3 tools/run-native-qml-case.py --resource-snapshot /tmp/wp4-snapshot-final \
  --activity menu --from-menu --qml-file src/activities/menu/Menu.qml \
  --case tests/work_log/session.qml --output /tmp/wp4-session-final --offline --timeout 120
python3 tools/run-native-qml-case.py --resource-snapshot /tmp/wp4-snapshot-final \
  --activity menu --from-menu --qml-file src/activities/menu/Menu.qml \
  --case tests/work_log/session.qml --output /tmp/wp4-scale-final --offline --timeout 120 \
  --screen-size 2048x1152
python3 tools/run-native-qml-case.py --resource-snapshot /tmp/wp4-snapshot-final \
  --activity menu --from-menu --qml-file src/activities/menu/Menu.qml \
  --case tests/menu/particles.qml --output /tmp/wp4-particles-final --offline --timeout 120
python3 tools/run-native-qml-case.py --resource-snapshot /tmp/wp4-snapshot-final \
  --activity menu --from-menu --qml-file src/activities/menu/Menu.qml \
  --case tests/crjm/dominorio.qml --output /tmp/wp4-dominorio-final --offline --timeout 120
```

## Resultados

Vermelho → verde em `WorkLogTest::completedRound`: primeiro criou-se a entrada
sem implementar `roundCompleted()`, e o teste falhou em `hasRounds` após concluir
a ronda. Implementada a contagem, esse mesmo teste passou. A asserção permanece
na versão final, acompanhada de testes de ordem, acumulação, idempotência,
cópia de leitura, distinção sem rondas/contagem, ausência de atividade corrente,
limpeza, nova sessão vazia e ausência de escrita no perfil.

- [Vermelho C++](wp4-native/core-red.log): 1 falha esperada, `completedRound`.
- [ctest final](wp4-native/ctest.log): **9/9**, incluindo `CoreWorkLogTest`,
  sem testes ignorados. O novo teste tem 5 casos funcionais.
- [WP4 normal](wp4-native/session/result.json): **0 falhas, 2 passes**, zero
  erros QML. Entra pelo cartão real de Contagem dos itens, conta os frutos
  apresentados e responde pelo teclado nos quatro exercícios do primeiro nível.
  Não altera estado, temporizadores nem funções da atividade. Sai durante o
  Bonus, antes de `win()`, e lê título, objetivo e `Rondas concluídas: 1`.
  Abre Dominório, a ajuda, volta e lê `—`. Reabre Contagem dos itens, visita a
  configuração e volta: continuam duas entradas e uma ronda. Cancela uma
  limpeza por Esc, depois confirma pelo teclado: a lista fica vazia. Confirma
  fecho por botão/Esc, Ctrl+T e Tab com secções visíveis/ocultas.
- [WP4 escala](wp4-native/scale/result.json): **0 falhas, 2 passes**, zero erros
  QML. Repete o percurso com ecrã primário **2048×1152**, `fontRatio=2.4`,
  `baseFontSize=7`; verifica texto e controlos a caberem em 2048×1100,
  1280×800, 800×600, 600×900 e 600×480. A janela pequena força deslocação da
  lista e confirma Page Down/Page Up pelo teclado.
- [Partículas](wp4-native/particles/result.json): **0 falhas, 2 passes**, zero
  erros QML. Um loader e um sistema sob `activitiesGrid`, cartão com geometria
  correta, abertura de Dominório e regresso ao menu.
- [Dominório](wp4-native/dominorio/result.json): **0 falhas, 2 passes**, zero
  erros QML. Percurso real completo existente, incluindo pesquisa, jogadas,
  ajuda sem perda de posição, partida completa, reinício, teclado, toque
  sintético, retrato e regresso ao menu.

Os quatro processos terminaram com código 0 e sem OOM. Os logs nativos ficam
junto de cada relatório. Há avisos de áudio indisponível e outros avisos Qt
já observados no ambiente sem dispositivos; os relatórios não detetaram erros
QML. Durante a preparação corrigiram-se a inclusão do novo QML no RCC, o
tratamento de Page Up/Page Down com `Keys.onPressed` e o termo de pesquisa do
teste, que passou a usar o título português real. Essas execuções de diagnóstico
não foram contadas como aceitação.

## Capturas Qt reais

- [Vista vazia, 800×800](wp4-native/session/work-log-empty.png).
- [Vista com entradas, 800×800](wp4-native/session/work-log-entries.png).
- [Vista vazia, 2048×1100, texto máximo](wp4-native/scale/work-log-empty.png).
- [Vista com entradas, 2048×1100, texto máximo](wp4-native/scale/work-log-entries.png).
- [Lista com scroll, 600×480, texto máximo](wp4-native/scale/work-log-600x480.png).

Capturadas por `grabImage(pageView)` no runner, sem montagem. Os PNG e os seus
SHA256 estão em `wp4-native/summary.json`; os relatórios do runner registam
igualmente os hashes e as restantes capturas produzidas em `/tmp`.

## Limitações

Não validado com crianças, no Windows 10 escolar, nem num ecrã tátil físico.
Os testes correm em Qt Linux offscreen; o toque da regressão é sintético.
Não foi avaliada a compreensão dos textos ou a adequação pedagógica numa aula.
Não se validaram som, desempenho de um PC escolar, a compilação sem RCC ou toda
a coleção de atividades. Os percursos de sequência e lançamento direto usam
o mesmo gancho inspecionado em `loadActivity()`, mas não têm um caso nativo
separado nesta entrega. A contagem continua a depender da unidade de sucesso
que cada atividade envia ao `Bonus`; os CRJM mostram deliberadamente `—`.
