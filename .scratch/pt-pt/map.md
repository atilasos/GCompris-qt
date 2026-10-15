# Plano de trabalho PT-PT

## Notes

- Âmbito aprovado em `spec.md`.
- Tracker local em Markdown. O trabalho decorre no fork `atilasos/GCompris-qt`.
- Branch de trabalho: `work/pt-pt`. Nenhum commit ou push é necessário para registar
  a auditoria inicial.
- As tarefas estão em `issues/`. Dependências referem os números dos ficheiros.

## Decisions-so-far

- Cobrir todas as atividades, níveis e modos, incluindo correções de falhas gerais
  que impeçam jogar. Não desativar atividades para cumprir o objetivo.
- Linux para desenvolvimento. Instalador Windows 10 com recursos offline.
- Vozes PT-PT existentes e corretas primeiro; síntese apenas com amostras aprovadas.
- Revisão linguística e pedagógica pelo professor e validação nos PC da escola.

## Fog

- O inventário de vozes distribuídas em RCC ainda não foi inspecionado.
- A execução Linux tem verificações iniciais; faltam testes completos dos níveis
  e modos. Não existe evidência de execução Windows.
- A arquitetura dos PC da escola e o mecanismo disponível para compilar e testar
  Windows precisam de confirmação antes de produzir o instalador.

## Resultados iniciais

- Inventário gerado para as 203 atividades, com leitor PO testado.
  [Evidência da tarefa 01](issues/01-inventario.md#answer).
- Submódulo qml-box2d preparado na revisão fixada pelo projeto.
- Primeira ronda de 155 mensagens da interface corrigida. Catálogo com zero entradas
  vazias, fuzzy ou diferenças nos marcadores Qt. Revisão do professor e testes da
  tradução compilada continuam pendentes na tarefa 03.
- Texto anterior e novo em `interface-review.json`. Todas as revisões humanas estão
  pendentes. A referência anterior às alterações está em `baseline-audit.json`.
- Catálogo de introduções de voz ainda com 15 entradas vazias e 3 fuzzy; gravações
  não inspecionadas. O inventário inicial tinha sete ficheiros JSON ingleses sem
  correspondente PT. Após corrigir as duas atividades de gramática, restam cinco
  candidatos a inspeção, não cinco defeitos confirmados.
- Compilação Linux e recursos PT preparados. A aplicação lista todas as 203
  atividades. [Evidência da tarefa 02](issues/02-build-linux.md#answer).
- Corrigida incompatibilidade QML que impedia o arranque de atividades com o
  seletor de cores. [Evidência da tarefa 09](issues/09-seletor-cores.md#answer).
- Oito suites C++ passam com locale controlado. A falha da expectativa no locale
  `C` permanece registada na tarefa 10.
- Acrescentados conteúdos PT de gramática após o professor confirmar o fallback
  inglês. São 15 níveis e 172 exercícios, com oito testes de carregamento e respostas.
  Ver a [evidência da tarefa 11](issues/11-gramatica-portugues.md#answer).
  A revisão linguística final continua pendente.

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
