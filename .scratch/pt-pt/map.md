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
As 49 atividades com evidência funcional ligada na matriz não representam
a aceitação global dos 203 jogos.

- [40 — Contrato dos níveis do Solitário](issues/40-niveis-solitario.md)

- [41 — Primeiro processador de texto](issues/41-primeiro-processador-texto.md)

- [42 — Rejeitar seleções vazias no executor de memória](issues/42-retorno-vazio-memoria.md)
