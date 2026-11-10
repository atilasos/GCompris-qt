<!-- SPDX-FileCopyrightText: NONE -->
<!-- SPDX-License-Identifier: CC0-1.0 -->
# Correções após a revisão de código

Duas revisões cruzadas sobre `a28b10912`: GPT Sol reviu WP2a, WP2b, WP3 e WP5
(8/10, «pronto após correções»); Claude Opus reviu WP1 e WP4 (7/10, «pronto
após correções», sem bloqueadores).

## Corrigido

- **WP3** `algebra.js`: `balloon.activityRunning` passa a ser definido em cada
  arranque. Antes, quem ligasse o limite de tempo depois de um arranque sem
  limite ficava com o balão sem reagir ao redimensionamento.
  `timelimit-dialog.qml` verifica os dois estados.
- **WP1** `DownloadManager`: um ficheiro acabado de descarregar fica fora da
  cache durante o resto do processo e só é registado no arranque seguinte. Um
  corte de energia entre a descarga e a escrita em disco já não pode deixar um
  `.rcc` truncado marcado como verificado.
- **WP4** `Bonus.qml`: uma resposta certa dada durante a animação de uma errada
  passa a contar.
- **WP4** `Menu.qml`: o botão esconde-se quando o teclado virtual da pesquisa
  está visível; a altura acompanha `GCStyle.smallButtonHeight`; um clique com
  o rato já não tira as setas às grelhas (`focusPolicy: Qt.TabFocus`) e fechar
  a vista devolve o foco ao sítio de onde se veio; o rótulo deixa de mostrar
  «(Ctrl+T)» (o atalho mantém-se).

## Não alterado, com razão

- Persistência do limite de tempo depois de destruir e recriar a atividade: o
  caso prova-a reabrindo o diálogo, que lê a configuração gravada pela mesma
  função usada no arranque. Um caso alojado no menu fica por fazer.
- Uma escrita do ficheiro de cache por cada hash novo (até cinco no primeiro
  arranque): custo pequeno, não medido em HDD.
- Android: não foi verificado se os caminhos `assets:/` têm caminho canónico;
  se não tiverem, a cache não é usada nessa plataforma (sem erro).

## Verificação (binário sha256 `9f9983aca76d0ce4…`, snapshot de recursos novo, `--offline`)

| Caso | Resultado |
| --- | --- |
| `ctest` | 9/9 |
| `tests/work_log/session.qml` (normal e `--screen-size 2048x1152`) | 2 passes, 0 falhas |
| `tests/menu/particles.qml`, `tests/crjm/dominorio.qml` | 2 passes, 0 falhas |
| `algebra_by` e `algebra_minus`: `timelimit-dialog`, `timelimit-default`, `configurations` | 2 passes, 0 falhas cada |

Antes das correções, a árvore integrada `a28b10912` passou 15 casos nativos,
148 testes Python (2 ignorados) e 6 testes Node.
