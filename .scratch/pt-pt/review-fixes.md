# Correções após revisão da integração

Os relatórios de revisão identificaram riscos de compilação e lacunas concretas
na evidência do candidato. Esta ronda corrige o código e a rastreabilidade; não
encerra a especificação nem substitui a validação funcional da tarefa06.

- O hook de conclusão de vozes foi separado em `cmake/CompletePtVoices.cmake` e
  corre apenas em builds OGG nativos. Em cross-compiling, `getAssets` mantém o seu
  percurso anterior e não tenta executar um utilitário ARM no host. Um fixture
  CMake com `CMAKE_SYSTEM_NAME=Generic` reproduziu a presença indevida desse target
  e passou após a guarda. Outro fixture nativo compila o utilitário Qt e executa
  o hook de conclusão. Não foi feita uma compilação Android nesta ronda.
- O mapa aponta agora às respostas resolvidas das tarefas10 e14 e remove a falha
  de locale já corrigida da lista de resultados atuais.
- `Invoke-GComprisNativeCheck` concentra o ciclo de ambiente, firewall e execução
  para as duas árvores Windows. Limpa e restaura todas as variáveis Qt/QML/QSG e
  PATH, incluindo quando a execução falha. O teste executa PowerShell7 e simula
  apenas a fronteira Windows da firewall; verifica a limpeza efetiva após falha.
- O primeiro teste recusa dados GCompris preexistentes nas Known Folders reais.
  Não se afirma que APPDATA/LOCALAPPDATA mudam QStandardPaths no Windows: a API Qt
  consulta `SHGetKnownFolderPath`. O teste instalado usa a mesma conta CI
  inicialmente limpa, em novos processos, conforme documentado.
- O workflow inclui recursos e ferramentas de áudio nos filtros de push. Os
  recursos distribuídos também entram no fingerprint do runner Linux. O teste
  público de retoma mostrou que uma voz alterada antes era indevidamente aceite;
  agora exige uma nova execução.
- O candidato abre oito atividades em cada árvore, além de exigir a lista completa.
  Verifica sobrevivência do processo, marcador de atividade, ausência de erros QML
  e registo do novo RCC de1610 vozes. Inclui criação de frações para exercitar
  QtGraphs. Os testes rejeitam erro QML, saída precoce e falta do registo de vozes.
- O erro real do segundo ensaio Windows foi corrigido: retirado o argumento
  `--include-soft-plugins`, ausente no windeployqt distribuído6.10.2. A fonte
  [Qt v6.10.2](https://github.com/qt/qtbase/blob/v6.10.2/src/tools/windeployqt/main.cpp)
  confirma as opções restantes. O próximo ensaio guarda o help real no artefacto.
- Foi acrescentado cache dos dois prefixos instalados do SDK, separado das fontes
  e candidatos. Restore/save usam a revisão oficial de actions/cachev4.2.3
  `5a3ec84eff668545956fd18022155c47e93e2684`, confirmada pela API GitHub.
  A chave contém runner, toolchain, Qt, hash da lista efetivamente usada de módulos
  e revisão vcpkg. O save ocorre antes das verificações que possam falhar.

Verificação local: 11 testes dirigidos passaram (7 do candidato, 2 de CMake e2 do
runner). O teste do candidato incluiu o QTranslator real e PowerShell7.4.6.
Actionlint1.7.7, o parser PowerShell e a verificação do diff também passaram.

Os testes Windows reais decorrem no workflow; o computador Windows10 do professor,
a reprodução audível e a conclusão de todos os níveis e modos permanecem
verificações separadas, ainda pendentes.


A revisão adicional das ferramentas nativas encontrou a rejeição de identificadores
válidos com maiúsculas, como `programmingMaze`. A expressão de validação aceita
agora todos os 203 identificadores públicos e continua a rejeitar caminhos e
argumentos perigosos. Quatro testes exercitam as duas interfaces de linha de comandos.

A revisão da ronda seguinte encontrou uma afirmação de cobertura insuficiente
sobre a rejeição de letras sem acento em gletters. O teste nativo foi
alargado e passou 24 rejeições explícitas, nos dois modos. Os resultados
anteriores permanecem como evidência histórica; ver
`functional-letters/review-accent.md`. A pequena
função de entrada Unicode repetida nos dois casos fica local por depender dos
identificadores QML e das asserções QtTest de cada caso. Não afeta código de produto.

Verificação integrada posterior: 30 testes Python executados, um ignorado por
PowerShell ausente do PATH; 18 testes Node passaram. A compilação principal
inclui a correção de seleção de letras e passou os dois casos nativos de
navegação (`build/pt-pt/integrated-letter-navigation/summary.json`).

Os sete testes do candidato foram repetidos com PowerShell7.4.6 no PATH e
passaram, incluindo a captura de stderr Qt e a reposição do ambiente. Foram
removidos os 14 worktrees de tarefas já integradas; permanecem apenas os três
worktrees das tarefas em execução. As branches e a evidência versionada foram
conservadas.

Após a integração das tarefas19/20 e do primeiro fix de memória, passaram
21 testes Node (incluindo dados reais de leitura/palavras) e os dez testes do
candidato com PowerShell7.4.6. O build principal passou 25 arranques sem rede
nas atividades afetadas (`runtime/reading-memory-startup.json`). A prova pequena
do NSIS é nativa Windows e está a decorrer no CI38807970526; os testes Linux
da fronteira PowerShell não a substituem.
