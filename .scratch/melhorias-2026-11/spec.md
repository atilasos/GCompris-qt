<!-- SPDX-FileCopyrightText: NONE -->
<!-- SPDX-License-Identifier: CC0-1.0 -->
# Melhorias pedagógicas e do motor — ciclo de novembro de 2026

Status: ready-for-agent
Progress: claimed
Base: `8108a5fe3` (master do fork, upstream integrado em 2026-11-10)

## Contexto

Fork pt-PT do GCompris (Qt 6/QML/C++), 211 atividades, usado no pré-escolar e
1.º ciclo de uma escola do Movimento da Escola Moderna, sobretudo em Tempo de
Estudo Autónomo (TEA), em PCs Windows 10 modestos. Um só utilizador de sistema
por computador, partilhado por vários alunos.

## Avaliação

### Pedagógica (critérios da wiki Sebenta)

Páginas usadas: Ensino da Matemática, Ensino da Leitura e da Escrita, Método
das 28 Palavras, Avaliação Formativa, Diferenciação Pedagógica, Educação
Inclusiva, Tempo de Estudo Autónomo, Plano Individual de Trabalho,
Aprendizagem Cooperativa, Pensamento Computacional, CRJM, PageCraft.

| Critério | Estado | Evidência |
| --- | --- | --- |
| A. Feedback formativo (erro analisável, pista, nova tentativa) | parcial | `src/core/Bonus.qml:142-170` é binário (certo/errado). Só os 8 jogos CRJM têm pistas em 3 níveis e revisão. |
| B. Matemática sem a rapidez como indicador principal | parcial | `algebra_by/algebra.js:203` arranca sempre o balão-cronómetro (`100000 / speedSetting`); o `ActivityConfig.qml` só tem «Velocidade» 1–10, sem opção sem tempo. Partilhado por `algebra_by/plus/minus/div`. `gnumch-*` e `planegame` também têm tempo obrigatório. |
| C. TEA/PIT: objetivo visível e registo do trabalho pelo aluno | ausente | `ApplicationSettings::saveActivityProgress` guarda um `int` por atividade e só `balancebox` o usa. Não há histórico de sessão visível. O `goal` existe mas só no diálogo de ajuda. |
| D. Inclusão/DUA | parcial | Botão de repetir (`Bar.qml`) só é tratado em 1–4 atividades; várias atividades de arrastar sem teclado (`ordering_numbers`, `guesscount`, `share`). CRJM têm teclado e testes. |
| E. Leitura/escrita, ciclo das 28 Palavras | ausente | Nenhuma atividade de segmentação/recombinação silábica em pt. Só 19 das 29 palavras (28 + variante gema/ovo) têm voz pt em `lang/resource/content-pt.json`. |
| F. Jogos de estratégia CRJM | consistente | `hint()` graduado, `review()` de 1 momento, 3 dificuldades, testes nativos em `tests/crjm/`. Falta `PROVENANCE.md` em `gatos_caes` e `quelhas`. |

### Motor de jogo (leitura de código; ganhos por medir em equipamento escolar)

1. **MD5 integral dos `.rcc` em cada arranque, na thread principal** —
   regressão do fork. `DownloadManager::updateResource`
   (`src/core/DownloadManager.cpp:238-258`) chama `checksumMatches` (l. 530+),
   invocado de `main.qml:202/220/233` para palavras (43 MB), vozes pt (37 MB) e
   música (16 MB). Medido nesta máquina com cache quente: 0,15 s; num HDD a
   frio estima-se 1–2 s (não medido).
2. **Um `ParticleSystem` por cartão do menu** — `Menu.qml:561-564`; só é
   usado no clique (`particles.burst(50)`, l. 623). `hasShader` é `true` em
   todo o desktop (`ApplicationInfo.h:277-283`), pelo que os loaders estão
   ativos também com renderização por software.
3. `ActivityInfoTree.menuTree[index]` por delegate (`Menu.qml:491`): o getter
   cria só um wrapper leve; sem ganho demonstrado, fica fora do plano.
4. **Arranque síncrono de 211 `ActivityInfo.qml` + um `QQmlComponent` por
   `Data.qml`** — `ActivityInfoTree.cpp:294-358`, `ActivityInfo.cpp:243-252`.
   Maior custo estrutural, mas correção de risco médio e sem medição.
5. Não existe qualquer medição de arranque (sem benchmarks nem registo de
   tempos).

## Plano (âmbito deste ciclo) — revisão 2, após a ronda 1 do conselho

Um branch `feat/game-improvement-plan`, um commit por pacote, um PR para
`master` do fork. Sem alterações a áudio, catálogos `poqm/` (sincronizados com
o SVN do upstream), instalador ou site publicado (o changelog em
`site/content.json` é atualizado; o deploy do site não é feito). Os textos
novos são escritos diretamente em pt-PT dentro de `qsTr()`, como nas
atividades CRJM do fork, para não dependerem do catálogo upstream.

Ordem de integração (um só checkout, sequencial, por partilharem ficheiros):
**WP2a → WP1 → WP2b → WP4**. Em paralelo, em worktree próprio: **WP3**.
**WP5** e **WP6** pelo orquestrador, no fim.

Regra de aceitação comum: os casos nativos correm com o binário e os recursos
core compilados desta revisão (`build/pt-pt` deste worktree: alvos
`gcompris-qt`, `rcc_core`, `rcc_menu` e o `.rcc` da atividade em causa,
porque o runner só recompila o recurso de `--qml-file`), e a evidência
regista o commit e o hash do binário. «`ctest` verde» significa todos os
testes registados a passar, incluindo os novos.

### WP2a — Medição de arranque (motor, C++) — Claude Opus 5.5

- Categoria de registo `gcompris.startup` (desligada por omissão) com os tempos
  de `ActivityInfoTree::initialize` e de cada `updateResource` síncrono.
- Medir sobre `8108a5fe3` (antes do WP1) e guardar a linha de base em
  `.scratch/melhorias-2026-11/evidence/`: arranque a frio e a quente, com
  descargas automáticas desligadas. Declarar que os tempos são desta máquina,
  não do equipamento escolar, e que não cobrem descargas assíncronas.
- Done when: com a categoria ativa os tempos aparecem no registo; com ela
  desligada não há saída nova; `ctest` verde.

### WP1 — Cache de verificação dos `.rcc` (motor, C++) — GPT Sol

- Só o percurso local de registo (`updateResource` sem descarga e
  `available()` em `parseContents`) passa a consultar uma cache persistente
  `(caminho absoluto, tamanho, mtime em ms) → md5`; só rehasha quando os
  metadados mudam. A validação de uma descarga concluída continua a ler os
  bytes e atualiza a entrada da cache. A verificação de ficheiro local em
  `finishDownload` (l. 808-809), usada com descargas automáticas ligadas,
  pode usar a cache. A evidência indica com que definição de descargas foi
  medida; a definição dos PCs da escola é desconhecida.
- **Compromisso explícito:** tamanho e mtime iguais não provam conteúdo igual.
  A verificação existe para escolher entre um `.rcc` empacotado e um em cache
  com o mesmo nome, não como defesa contra adulteração; aceita-se esse risco
  residual e documenta-se no código.
- Ficheiro próprio em `ApplicationSettings::cachePath()` (a pasta que os
  testes já isolam), não em `gcompris-qt.conf`; ausente ou corrompido →
  recalcula. Se algum percurso não correr na thread principal, protege-se o
  acesso.
- Done when: testes novos em `tests/core/DownloadManagerTest.cpp` provam (a)
  segunda verificação sem releitura, (b) invalidação por tamanho ou mtime,
  (c) cache corrompida → recalcula, (d) checksum esperado diferente → falha,
  (e) persistência entre duas instâncias/processos, (f) descarga concluída
  rehasha sempre; os testes existentes de colisão de nomes continuam a passar;
  tempos do WP2a antes/depois registados.

### WP2b — Um só sistema de partículas no menu (motor, QML) — Claude Opus 5.5

- Um `ParticleSystemStarLoader` partilhado pela grelha, posicionado no cartão
  clicado, em vez de um por delegate; sem reparent para delegates
  recicláveis (o componente tem `anchors.fill: parent` na raiz). O da secção
  de categorias (`Menu.qml:322`) não é alterado.
- Done when: caso nativo novo conta os sistemas de partículas sob
  `activitiesGrid` (1) e
  `tests/crjm/dominorio.qml` (percurso real: pesquisa, clique no cartão,
  regresso ao menu) continua a passar.

### WP3 — Cálculo sem cronómetro (pedagogia B) — Claude Opus 5.5, worktree próprio

- Opção «Sem limite de tempo» nos **quatro** `ActivityConfig.qml`
  (`algebra_by`, `algebra_plus`, `algebra_minus`, `algebra_div`; o diálogo
  carrega o ficheiro da pasta de cada atividade, `DialogChooseLevel.qml:256`).
- Sem limite, o balão não se move em nenhum percurso: `run()`
  (`algebra.js:203`), `checkAnswer()` (l. 210), redimensionamento
  (`Balloon.qml:60-68`), e o `onTimeout` nunca dispara.
- Persistência sem valores «falsy»: chave textual (p. ex. `timeLimit:
  "off"|"on"`), porque `Algebra.qml:96` testa por veracidade.
- Migração: sem configuração guardada → sem limite; configuração antiga com
  `speedSetting` e sem a chave nova → mantém o cronómetro que o professor
  escolheu.
- O texto de ajuda/configuração diz que a fluência se pode treinar reativando
  a velocidade.
- Done when: casos nativos em `tests/functional_algebra/` provam, para as
  quatro atividades: omissão sem limite (resposta aceite após espera superior
  aos 20 s antigos da velocidade 5, incluindo depois de um redimensionamento e
  de uma resposta anterior); alternância ligado/desligado; persistência após
  reabrir; configuração antiga conserva `100000/speed`. Os casos existentes
  (`controls.qml`, `gameplay.qml`, `keyboard.qml`) continuam a passar;
  `configurations.qml` passa a ligar explicitamente o limite de tempo antes
  do ciclo (o runner corre sem configuração guardada) e conserva as
  asserções de duração e de `timeout`.
- O `manual` existente em `algebra_*/ActivityInfo.qml` não é alterado (mudar
  o `msgid` faria perder a tradução pt); o texto novo vive em `qsTr` pt-PT no
  `ActivityConfig.qml`.
- Nota de migração: «Guardar» no diálogo grava sempre `speedSetting`
  (`DialogChooseLevel.qml:280-282`), pelo que a regra preserva o cronómetro
  de qualquer instalação onde alguém já guardou a configuração da atividade.

### WP4 — «O meu trabalho»: registo da sessão para o PIT (pedagogia C) — GPT Sol

- **Só a sessão atual, só em memória.** Nada é escrito em disco; o registo
  desaparece ao fechar a aplicação. A vista tem o botão «Começar de novo»
  (para o aluno seguinte), que apaga a sessão. Sem nomes, sem horas, sem
  retenção.
- Cada entrada: atividade (título), objetivo (`goal`) e «rondas concluídas».
  Sem duração: tempo no ecrã não é evidência de trabalho.
- «Rondas concluídas» conta os sinais de vitória do `Bonus` e usa esse rótulo
  neutro, porque a unidade varia por atividade. Atividades que nunca emitiram
  `Bonus` na sessão (p. ex. os jogos CRJM) mostram «—», nunca «0».
- Singleton C++ `WorkLog` com API mínima (`activityStarted`, `roundCompleted`,
  `clear`, modelo de leitura), registado em `GComprisPlugin::registerTypes`
  (com `WITH_RCC` o `QML_SINGLETON` não está ativo). Ganchos passivos: um
  único ponto comum a todas as entradas de atividade (cartão e sequência; no
  carregador do `Menu.qml`) e `Bonus.good()` (`Bonus.qml:142`; o `win()` só
  sai 2 s depois e pode ser cancelado). Não há gancho de saída: sem duração
  nem persistência, abrir a ajuda ou a configuração (que chamam `home()`) e
  fechar a janela não afetam o registo. Nenhuma atividade individual é
  alterada.
- `activityStarted` é idempotente (o `Loader` assíncrono pode chamar
  `loadActivity()` duas vezes, `Menu.qml:197` e `:633`).
- A entrada no menu para a vista tem atalho de teclado próprio e respeita o
  ciclo de foco de `Keys.onTabPressed` (`Menu.qml:258-276`).
- A vista não substitui a autoavaliação do aluno no PIT; o texto da vista
  di-lo («Copia para o teu plano o que fizeste e escreve como correu»).
- Done when: `tests/core/WorkLogTest.cpp` (ordem, agregação por atividade,
  «—» vs. contagem, limpar, nada em disco); caso nativo que entra numa
  atividade por cartão, conclui uma ronda real, volta ao menu, abre a vista
  por teclado e lê a entrada; segunda atividade sem `Bonus` mostra «—»;
  «Começar de novo» esvazia a vista; `ctest` verde.

### WP5 — Proveniência CRJM (manutenção) — orquestrador

- `PROVENANCE.md` em `gatos_caes` e `quelhas` no formato dos outros seis, com
  a referência conferida no repositório `atilasos/crjm`; teste que exige o
  ficheiro (`PROVENANCE.md` ou `ORIGIN.md`) com referência nas 8 pastas.

### WP6 — Entrega — orquestrador

- Changelog em `site/content.json` (estado «aguarda compilação»), capturas
  reais da vista nova e da opção de álgebra com proveniência, revisão
  independente do diff (`codex-review`), PR com a secção «Council review»,
  merge em `master` (pedido expressamente pelo utilizador). O push em `master`
  dispara o workflow do candidato Windows, que cria uma prerelease; não se
  fixa o instalador na página nem se publica o site.

## Fora do âmbito (com razão)

- **Carregamento diferido dos `Data.qml` / `.rcc` por atividade** (item 4):
  risco médio; decide-se depois de haver tempos reais do WP2a.
- **Atividade de sílabas das 28 Palavras**: faltam vozes pt de 10 palavras e a
  audição pelo professor (ticket pt-pt 05) está pendente; sem voz a atividade
  degradaria o método para associação visual. Proposta para o ciclo seguinte,
  dependente das gravações.
- **Contagem de rondas nos jogos CRJM no «O meu trabalho»**: exigiria tocar
  nas 8 atividades; a API `roundCompleted` fica disponível para esse passo.
- **Revisão pós-jogo com 3 momentos nos CRJM**, **modo sem tempo em
  `gnumch-*`/`planegame`**, **teclado nas atividades de arrastar**, **máscara
  `layer.enabled` do menu**, **`modelData` no delegate**: cada um é um pacote
  com risco de regressão ou sem ganho demonstrado.
- Feedback formativo transversal no `Bonus`: exigiria mudar ~200 atividades.

## Riscos

- WP4 toca em `Bonus.qml` e `Menu.qml`, usados por todas as atividades: os
  ganchos são passivos e não alteram o fluxo.
- WP3 muda o comportamento por omissão de quatro atividades.
- WP1 troca uma verificação de bytes em cada arranque por confiança em
  metadados (ver compromisso).
- Nada disto é validado em Windows 10 escolar, com tablets ou com crianças
  neste ciclo; a CI Windows Server não substitui essa validação.

## Council review

Ronda 1: Claude Opus 6/10, GPT Sol 6/10, Gemini 4 Argon 7/10 — todos
«aprovar com alterações».
Bloqueadores incorporados nesta revisão: quatro configurações de álgebra e
todos os percursos do balão; migração e chave não «falsy»; sessão única sem
persistência e rótulo neutro com «—»; compromisso de integridade do WP1;
artefactos reconstruídos na aceitação nativa; ordem sequencial dos pacotes;
gancho em `Bonus.good()` e registo do singleton com `WITH_RCC`; cache em
`cachePath()`; textos novos em pt-PT no QML em vez do catálogo `poqm/`.

Ronda 2 (revisão 2): GPT Sol 8/10 «aprovar»; Claude Opus 8/10 «aprovar com
alterações» (um bloqueador: `configurations.qml` não podia passar sem ligar
o limite de tempo — corrigido acima, com as restantes recomendações);
Gemini 4 Argon 9/10 «aprovar».
