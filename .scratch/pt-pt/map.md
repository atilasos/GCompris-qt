# Plano de trabalho PT-PT

## Notes

- Âmbito aprovado em `spec.md`.
- Tracker local em Markdown. O trabalho decorre no fork `atilasos/GCompris-qt`.
- Branch de integração: `integration/pt-pt`, com branches de tarefa isoladas.
  Os commits e o candidato Windows são enviados apenas para o fork.
- As tarefas estão em `issues/`. Dependências referem os números dos ficheiros.

## Decisions-so-far

- Cobrir todas as atividades, níveis e modos, incluindo correções de falhas gerais
  que impeçam jogar. Não desativar atividades para cumprir o objetivo.
- Linux para desenvolvimento. Instalador Windows 10 com recursos offline.
- Vozes PT-PT existentes e corretas primeiro; síntese apenas com amostras aprovadas.
- Revisão linguística e pedagógica pelo professor e validação nos PC da escola.

## Fog

- O inventário RCC foi inspecionado e os 32 recursos em falta foram acrescentados,
  preservando as 1578 gravações originais. A audição/revisão final é tarefa 08.
- As 203 atividades passaram o arranque Linux sem rede. Os dois jogos de
  gramática, escolha múltipla e cronologia têm conclusão nativa dos seus níveis
  documentada nas tarefas 16/17. Os quatro jogos de letras e teclado também
  concluíram 74 percursos de nível/modo na tarefa 15. Os restantes percursos
  continuam na tarefa 06.
  Ainda não existe evidência final da aplicação instalada em Windows10.
  A leitura e as palavras concluíram os lotes 19/20; permanecem dois encerramentos
  iniciais da leitura sem causa demonstrada, apesar das repetições sem sinal.
- Windows10 x64 está confirmado; o professor dispõe de um Windows para testes.
  O computador pessoal usa Windows11 25H2, compilação 26300.9711; a validação
  obrigatória em Windows10 terá de decorrer num PC da escola.
  O primeiro ensaio nativo compilou a aplicação e os recursos, mas a implantação
  ainda precisa de fechar os erros identificados pelo candidato na tarefa 13.
  O candidato 38805685864 passou oito arranques Windows e gerou o EXE; a validação
  instalada falhou no caminho de destino e continua em correção.

## Resultados iniciais

- Inventário gerado para as 203 atividades, com leitor PO testado.
  [Evidência da tarefa 01](issues/01-inventario.md#answer).
- Submódulo qml-box2d preparado na revisão fixada pelo projeto.
- Primeira ronda de 155 mensagens da interface corrigida. Catálogo com zero entradas
  vazias, fuzzy ou diferenças nos marcadores Qt. A segunda ronda corrigiu mais 637
  campos e a compilação/plurais PT-PT foi verificada com Qt real.
  A revisão do professor continua pendente na tarefa 03.
- Texto anterior e novo em `interface-review.json`. Todas as revisões humanas estão
  pendentes. A referência anterior às alterações está em `baseline-audit.json`.
- As 15 entradas vazias e 3 fuzzy do catálogo de vozes foram corrigidas. O RCC
  completo tem 1610 gravações descodificadas, incluindo 32 adições aprovadas para
  geração. A audição final permanece pendente na tarefa 05.
- Os dados de letras, leitura e vocabulário foram corrigidos, distinguindo os
  recursos numéricos neutros das lacunas linguísticas reais.
  [Evidência da tarefa 04](issues/04-dados.md#answer).
- Compilação Linux e recursos PT preparados. A aplicação lista todas as 203
  atividades. [Evidência da tarefa 02](issues/02-build-linux.md#answer).
- Corrigida incompatibilidade QML que impedia o arranque de atividades com o
  seletor de cores. [Evidência da tarefa 09](issues/09-seletor-cores.md#answer).
- A expectativa de locale foi corrigida sem alterar o produto. As oito suites C++
  passaram em `C`, `pt_PT.UTF-8` e `en_US.UTF-8`.
  [Evidência da tarefa 10](issues/10-teste-locale-default.md#answer).
- Os oito ícones com texto estrangeiro foram corrigidos e renderizados pelo Qt.
  A variante portuguesa do ícone de memória conserva a relação `2 dois`.
  [Evidência da tarefa 14](issues/14-icones-gramatica.md#answer).
- Acrescentados conteúdos PT de gramática após o professor confirmar o fallback
  inglês. São 15 níveis e 172 exercícios, com oito testes de carregamento e respostas.
  Ver a [evidência da tarefa 11](issues/11-gramatica-portugues.md#answer).
  A revisão linguística final continua pendente.

- Escolha múltipla e cronologia concluíram os seus três níveis, com respostas
  certas/erradas, reinício e navegação em Qt real sem rede.
  [Evidência da tarefa 16](issues/16-validacao-sequencias.md#answer).
- As duas atividades de gramática concluíram 172 exercícios/15 níveis na interface
  real. Foi corrigida a entrega dupla das teclas.
  [Evidência da tarefa 17](issues/17-gramatica-interativa.md#answer).
- Os quatro jogos de letras e teclado concluíram 74 percursos, com 1 037 respostas
  certas e 282 erradas. Foi corrigida a seleção inválida ao mudar de nível.
  [Evidência da tarefa 15](issues/15-letras-funcionais.md#answer).
- A seleção de recursos conserva o pacote local mais recente quando o seu checksum
  é válido. Os 28 testes do DownloadManager e as oito suites C++ passaram; o novo
  rastreio dos 203 arranques sem rede também passou.
  [Evidência da tarefa 18](issues/18-preservar-recursos-locais.md).

## Tarefas

- [01 — Inventário estático](issues/01-inventario.md)
- [02 — Preparar compilação Linux](issues/02-build-linux.md)
- [03 — Rever tradução da interface](issues/03-interface.md)
- [04 — Corrigir dados pedagógicos](issues/04-dados.md)
- [05 — Verificar e completar áudio](issues/05-audio.md)
- [06 — Validar atividades e corrigir bloqueios](issues/06-execucao.md)
- [07 — Produzir instalador Windows offline](issues/07-windows.md)
- [08 — Revisão e validação na escola](issues/08-escola.md)
- [09 — Compatibilidade do seletor de cores](issues/09-seletor-cores.md)
- [10 — Expectativa do teste de locale](issues/10-teste-locale-default.md)
- [11 — Conteúdos de gramática em português](issues/11-gramatica-portugues.md)

- [13 — Candidato Windows x64](issues/13-candidato-windows.md)
- [14 — Ícones e texto incorporado](issues/14-icones-gramatica.md)

- [16 — Conclusão nativa de escolha múltipla e cronologia](issues/16-validacao-sequencias.md)
- [17 — Conclusão nativa da gramática e teclado](issues/17-gramatica-interativa.md)
- [15 — Conclusão nativa dos quatro jogos de letras](issues/15-letras-funcionais.md)
- [18 — Preservar os recursos locais mais recentes](issues/18-preservar-recursos-locais.md)

- [19 — Leitura horizontal e vertical](issues/19-functional-reading.md)
- [20 — Palavras em queda](issues/20-palavras-funcionais.md)
- [21 — Memória: palavras, quantidades e letras](issues/21-memoria-funcional.md)

- [22 — Eventos de teclado duplicados](issues/22-eventos-teclado-duplicados.md)
- [24 — Categorias traduzidas na ajuda](issues/24-categorias-ajuda.md)
- [25 — Snapshots dos recursos QML nativos](issues/25-snapshots-recursos-nativos.md)

- [23 — Diagnóstico dos encerramentos durante testes](issues/23-reading-crash.md)

- [26 — Pacote de audição das 32 gravações](issues/26-pacote-audicao.md)

- [29 — Memória matemática](issues/29-memoria-matematica.md)

- [27 — Quatro operações com balão](issues/27-calculo-interativo.md)

- [28 — Entradas dos consumidores NumPad](issues/28-consumidores-numpad.md)

O primeiro candidato Windows foi instalado e os203 jogos arrancaram no CI
WindowsServer2022 sem rede. O EXE foi descarregado e o checksum recalculado.
[Provas e limites](windows/38807970526/README.md). O ensaio manual no Windows11
pessoal foi pedido; a execução obrigatória Windows10/escola permanece pendente.

Os três jogos de memória concluíram34percursos com snapshot selado,180pares
corretos e42errados. As quatro operações concluíram48níveis,480respostas corretas
e48erradas. Os quatro consumidores NumPad passaram10casos de entrada, sem
declarar puzzles completos. A matriz global mantém os critérios pendentes.

- [30 — Decimais e quantidades](issues/30-decimais-quantidades.md)

- [31 — Complemento da dezena](issues/31-complemento-dezena.md)

- [32 — Adivinhar um número](issues/32-adivinhar-numero.md)

- [33 — Bloqueio do teclado visual](issues/33-teclado-virtual-bloqueado.md)

- [34 — Balanças e unidades de massa](issues/34-balancas.md)

- [35 — Aprovação das 32 gravações](issues/35-aprovacao-gravacoes.md)

- [36 — Retorno do launcher decimal](issues/36-retorno-runner-decimais.md)

- [37 — Restantes jogos de memória](issues/37-restante-memoria.md)

- [38 — Palavras e letras](issues/38-palavras-letras.md)

- [39 — O meu primeiro teclado](issues/39-primeiro-teclado.md)

O professor ouviu e aprovou a pronúncia e os textos das 32 gravações completas.
A tarefa35 liga essa aprovação aos textos/SHA256; o ZIP ouvido foi preservado.
Não é necessária nova aprovação dos mesmos ficheiros. A reprodução no Windows
e os restantes critérios de aceitação mantêm os seus estados próprios.

A memória matemática concluiu 14 variantes e 207 combinações nível/modo;
decimais/quantidades concluíram 316 puzzles em 16 campanhas offline e quatro casos de controlos.
As 142 atividades com evidência funcional ligada na matriz não representam
a aceitação global dos 203 jogos.

- [40 — Contrato dos níveis do Solitário](issues/40-niveis-solitario.md)

- [41 — Primeiro processador de texto](issues/41-primeiro-processador-texto.md)

- [42 — Rejeitar seleções vazias no executor de memória](issues/42-retorno-vazio-memoria.md)

- [43 — Primeiro rato e peixes](issues/43-primeiro-rato-peixes.md)

- [44 — Dois pares de vocabulário legado](issues/44-pares-vocabulario-legado.md)

- [45 — Identidade e seleção das campanhas](issues/45-retoma-selecao-campanhas.md)

- [46 — Contagem de objetos, dados e dominós](issues/46-contagem-dados-dominos.md)

- [47 — Preservar saídas das balanças](issues/47-balancas-preservar-provas.md)
- [48 — Ligar pontos e desenhar](issues/48-ligar-pontos-desenhar.md)

- [49 — Torres de Hanói](issues/49-torres-hanoi.md)

- [50 — Labirintos](issues/50-labirintos.md)

- [51 — Bloqueio dos discos inferiores](issues/51-hanoi-discos-cobertos.md)

- [52 — Ordenação](issues/52-ordenacao.md)

- [53 — Cores](issues/53-cores.md)

- [54 — Provas portáteis de Hangman](issues/54-hangman-provas-portateis.md)

- [55 — Auditoria histórica de Hanói](issues/55-hanoi-auditoria-historica.md)

- [56 — Codificação e descodificação de percursos](issues/56-percursos.md)

- [57 — Papador de Números](issues/57-papador-numeros.md)

- [58 — Revelar imagens](issues/58-apagar-imagem.md)

- [59 — Identidades das provas de cores](issues/59-cores-identidades-prova.md)

As cores (53/59) e os três jogos de revelar imagens (58) têm provas Linux
revistas por Standards e Spec. O P2 de identidade foi corrigido e reverificado;
[relatórios arquivados](review/integration53-59/). Estes lotes mantêm os limites
de Windows, hardware, audição e revisão docente; a matriz conserva todos os
critérios globais pendentes.

O lote 57 tem revisão Spec final sem achados e o P2 Standards de identidade
foi corrigido e reverificado: os 44 recibos conservam os bytes e estão ligados
aos fontes e catálogos históricos. [Revisão e recheck](review/integration53-59/).
As cinco ligações Gnumch foram acrescentadas sem aprovar critérios globais.

O lote 56 tem doze casos positivos e revisões finais sem achados em
[Standards e Spec](review/integration56-final/). As quatro novas ligações de
percursos preservam os critérios globais pendentes.

- [60 — Dinheiro e troco](issues/60-dinheiro-troco.md)

- [61 — Frações](issues/61-fracoes.md)

- [62 — Calendários](issues/62-calendarios.md)

- [63 — Operações verticais](issues/63-operacoes-verticais.md)

- [64 — Completar sequências](issues/64-algoritmos.md)

- [66 — Aprender números e operações](issues/66-aprender-numeros-operacoes.md)

Os lotes 60–64 concluíram a prova Linux delimitada de dinheiro/troco, frações,
calendários, operações verticais e sequências. Standards e Spec foram revistos;
a tarefa 65 fechou os três P2 de retornos externos e âncoras históricas, sem
reescrever os 1795 blobs/97 recibos originais ou repetir jogos.
[Relatórios e limites](review/integration60-65/). As doze ligações adicionais
na matriz mantêm todos os critérios globais pendentes. Áudio global,
Windows/escola e revisão humana dos pares legados (44)
conservam os respetivos estados.

- [65 — Retornos externos e âncoras das provas](issues/65-provas-retornos-ancoras.md)

- [67 — Aviões e sequências](issues/67-avioes-sequencias.md)

- [68 — Retas graduadas](issues/68-retas-graduadas.md)

- [69 — Comparar números e descobrir vizinhos](issues/69-comparar-vizinhos.md)

A tarefa 66 tem provas integradas de 17 níveis originais, 35 percursos de
representação/nível e 220 respostas certas/erradas. Fica resolvida no âmbito Linux descrito, após Standards e Spec independentes
sem achados acionáveis; [revisões arquivadas](review/integration66/).
Três ligações de evidência foram acrescentadas sem alterar critérios globais,
Windows, dispositivos físicos, audição ou revisão docente.

- [70 — Acertar o relógio](issues/70-relogio.md)

A tarefa 67 tem 190 capturas e 12 níveis documentados dos três jogos com avião,
com controlos e tutorial. Fica resolvida no âmbito Linux, após Standards e Spec independentes sem
achados; [relatórios](review/integration67/). Três ligações foram acrescentadas sem alterar os
critérios globais; hardware, áudio, Windows e professor permanecem pendentes.

A tarefa 70 tem prova Linux integrada de dez níveis nos dois formatos,
100 respostas certas, 100 erradas e 20 Bonus, com quatro processos concluídos.
Fica resolvida no âmbito Linux após Standards e Spec sem achados;
[relatórios](review/integration70/). A ligação do relógio foi acrescentada sem alterar critérios globais ou aprovação Windows,
hardware, áudio e docente.

- [71 — Chapéu mágico de adição e subtração](issues/71-chapeu-magico.md)

A tarefa 68 tem prova Linux integrada de 574 perguntas, 58 níveis e 20
datasets das duas retas graduadas. Fica resolvida no âmbito Linux após
Standards e Spec, incluindo o P2 corrigido pela tarefa 72; duas ligações foram acrescentadas
sem alterar os critérios globais, Windows, hardware, áudio ou revisão docente.

A tarefa 69 tem prova Linux integrada de 650 comparações e 250 sequências,
380 respostas erradas e 76 Bonus. Fica resolvida no âmbito Linux após Standards
e Spec sem achados; [relatórios](review/integration69/). Duas ligações mantêm os
critérios globais, Windows, hardware, áudio ou revisão docente.

- [72 — Preparação concorrente das fontes de teste](issues/72-preparacao-concorrente-fontes.md)

- [73 — Numeração romana](issues/73-numeracao-romana.md)

A tarefa 72 fechou a corrida de preparação de fontes sem alterar os 307 blobs
históricos; 16 testes e revisões independentes confirmaram a correção.
[Relatórios 68/72](review/integration68-72/). Sem nova campanha Qt ou alteração
dos critérios globais, Windows, hardware, áudio e revisão docente.

- [74 — Partilhar doces](issues/74-partilhar-doces.md)

- [75 — Associar imagens, formas e nomes](issues/75-associar-imagens.md)

A tarefa 71 tem provas Linux integradas dos dois chapéus mágicos: 41 níveis
por jogo, 82 puzzles e 82 erros reparados. Fica resolvida no âmbito Linux após
Standards e Spec sem achados; [relatórios](review/integration71/). Duas ligações mantêm os
critérios globais, Windows, hardware, áudio ou revisão docente.

A tarefa 74 tem prova Linux integrada de 146 perguntas/30 níveis nos dois
modos, 30 erros reparados e 544 transferências. Fica resolvida no âmbito Linux
após revisões e correção do P3 documental; [relatórios](review/integration74/).
Os retornos externos publicados são do launcher, sem tool-status individual
dos 14 casos. A ligação mantém critérios globais, Windows, hardware, áudio e
revisão docente pendentes.

A tarefa 73 tem prova Linux integrada de 14 níveis e 102 perguntas romanas,
com erros reparados e entradas física/virtual. Fica resolvida no âmbito Linux
após revisões independentes; [relatórios](review/integration73/). A ligação mantém os
alterar critérios globais, Windows, hardware, áudio ou revisão docente.

- [76 — Orientação espacial e botões do rato](issues/76-orientacao-e-rato.md)

- [77 — Puzzles deslizantes](issues/77-puzzles-deslizantes.md)

- [78 — Apagar as luzes](issues/78-apagar-luzes.md)

A tarefa 75 tem prova Linux integrada de 21 níveis, 25 tabuleiros e 119
associações. Fica resolvida no âmbito Linux após Standards e Spec sem achados;
[relatórios](review/integration75/).
Três ligações foram acrescentadas sem alterar os critérios globais. Um círculo
ocluído no ensaio adicional em retrato e a ausência de prova de reprodução
SoundEffect mantêm os limites publicados; Windows, hardware e docente pendentes.

A tarefa 78 tem prova Linux integrada dos 99 níveis/nove datasets de apagar
luzes, com 99 Bonus. Fica resolvida no âmbito Linux após Standards e Spec
sem achados; [relatórios](review/integration78/). A ligação mantém critérios globais,
Windows, hardware, áudio ou revisão docente.

- [79 — Desafios aritméticos](issues/79-desafios-aritmeticos.md)

A tarefa 76 tem prova Linux integrada de 80 tarefas/13 níveis e 13 erros
reparados em orientação/rato. Fica resolvida no âmbito Linux após Standards
e Spec sem achados; [relatórios](review/integration76/). Três ligações mantêm critérios
globais, Windows, hardware, áudio ou revisão docente.

- [80 — Jogos de alinhamento](issues/80-jogos-alinhamento.md)

A tarefa 77 tem provas integradas de 28 níveis dos puzzles deslizantes, com
baseline funcional e provas dirigidas da ajuda/arte PT final, sem declarar
nova execução final dos 28 níveis. Fica resolvida no âmbito Linux após
Standards e Spec sem achados; [relatórios](review/integration77/).
Duas ligações mantêm os critérios globais,
Windows, hardware, áudio e revisão docente pendentes.

- [81 — Coordenação com a bola](issues/81-coordenacao-com-bola.md)

- [82 — Contagens públicas dos níveis](issues/82-contratos-publicos-niveis.md)

A tarefa 79 tem provas Linux integradas de 186 perguntas principais/31 níveis
e quatro perguntas de editor, sem confundir entradas estáticas com partidas.
Fica resolvida no âmbito Linux após Standards e Spec sem achados;
[relatórios](review/integration79/README.md). Duas ligações mantêm os critérios
globais, Windows, hardware, áudio e docente pendentes.

A tarefa 82 tem 24 contratos públicos e 50 execuções documentadas. Fica
resolvida neste âmbito após correção de dois P2, recheck Standards e Spec
sem achados restantes; [relatórios](review/integration82/README.md). Não representa
conclusão dos jogos, não acrescenta ligações funcionais à matriz nem altera
critérios globais, Windows, hardware, áudio ou revisão docente.

- [83 — Encerramento intermitente após penáltis](issues/83-encerramento-penalty.md)

A ocorrência original139 da tarefa81 fica preservada e em investigação separada.
Três repetições completas0 não demonstram a sua causa nem ausência futura.
A estabilidade e a aceitação global permanecem pendentes.

A tarefa 80 tem provas Linux dos quatro jogos de alinhamento integradas e
fica resolvida neste âmbito após suplemento físico e revisões sem achados
restantes; [relatórios](review/integration80/README.md). As quatro
ligações funcionais acrescentadas mantêm todos os critérios globais, Windows,
hardware, áudio e revisão docente pendentes.

A tarefa 81 tem provas Linux integradas de 27 rotas/18 níveis e dois
controlos, em `ready-for-review` para Standards e Spec independentes. Duas
ligações mantêm critérios globais pendentes. A ocorrência 139 continua na
investigação 83: replay e dois GDB com saída zero não provam correção.
Windows, hardware, áudio e revisão docente permanecem pendentes.

A tarefa81 fica resolvida no âmbito funcional Linux finito após Standards e
Spec sem achados; [relatórios](review/integration81/README.md). As duas ligações
não aprovam estabilidade, Windows, hardware, áudio ou aceitação global.
O encerramento139 continua na tarefa83 aberta.

- [84 — Exploração do mundo](issues/84-exploracao-mundo.md)

- [85 — Ciclos e eclusa](issues/85-ciclos-e-eclusa.md)

O diagnóstico 83 foi integrado para revisão independente do handoff
(`ready-for-review` documental), mantendo a investigação aberta. Os seis
probes com saída zero não demonstram causa nem resolução da ocorrência139;
`cause_known` e `issue_resolved` continuam falsos. A ligação ao PID original
é apenas temporal. Nenhum critério global ou ligação funcional foi alterado.

O artefacto da investigação83 passou Standards/Spec após corrigir a interrupção
do driver; [relatórios](review/integration83/README.md). Os seis probes ociosos0
não resolveram a causa: a tarefa permanece aberta e sem nova cobertura de jogos.

- [86 — Relações familiares](issues/86-relacoes-familiares.md)

A tarefa 85 tem percursos Linux integrados da eclusa, ciclo da água e três
níveis de energia. Fica resolvida no âmbito Linux finito após revisões e
recheck sem achados; [relatórios](review/integration85/). Três ligações mantêm
os critérios globais, Windows, hardware,
áudio e docente pendentes; os limites dos recibos históricos estão publicados.

- [87 — Grelhas lógicas](issues/87-grelhas-logicas.md)

A tarefa 86 tem provas Linux integradas de 36 níveis, 46 conclusões naturais
e 36 erros/reparações das relações familiares. Fica resolvida no âmbito Linux
finito após revisões sem achados; [relatórios](review/integration86/).
Duas ligações mantêm os critérios
globais pendentes; iconografia não demonstra género pela aparência.
Windows, hardware, áudio e revisão docente permanecem pendentes.

A tarefa 85 recebeu suplemento para o P2 de regresso ao menu, com três
percursos completos repetidos e Ctrl+W até ao menu estável. O recheck
independente fechou o P2; não aumenta cobertura única nem altera a matriz. Os
[relatórios iniciais](review/integration85/) ficam preservados como histórico.

- [88 — Pormenores e pinturas](issues/88-pormenores-e-pinturas.md)

A tarefa 84 tem provas Linux integradas de 14 mapas, 98 apresentações e
116 perguntas das quatro atividades de exploração. Fica resolvida no âmbito
Linux finito após rechecks sem achados; [relatórios](review/integration84/).
Quatro ligações mantêm os critérios
globais, Windows, hardware, áudio e revisão docente pendentes.

A tarefa 87 tem provas Linux integradas de 68 Sudoku fixos e 100 Calcudoku
gerados, com 18 níveis/nove conjuntos e 18 erros reparados. Está
`ready-for-review`, aguardando Standards e Spec independentes. Duas ligações
mantêm os critérios globais, Windows, hardware, áudio e revisão docente pendentes.
