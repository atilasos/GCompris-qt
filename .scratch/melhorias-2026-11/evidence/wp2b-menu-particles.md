<!-- SPDX-FileCopyrightText: NONE -->
<!-- SPDX-License-Identifier: CC0-1.0 -->
# WP2b: um só sistema de partículas na grelha do menu

Verificação em 2026-11-10. Código WP2b no commit que introduz este ficheiro,
identificável com `git log -1 --format=%H -- .scratch/melhorias-2026-11/evidence/wp2b-menu-particles.md`.
Base: `cd486b726d7788dfa1a3b6d50e667a8521e75984` (WP1).

## Alteração

`src/activities/menu/Menu.qml`: o `ParticleSystemStarLoader` de cada delegate
de `activitiesGrid` foi substituído por um único loader
(`objectName: "activityParticles"`) dentro de um `Item` filho de
`activitiesGrid.contentItem` (`z: 2`, acima dos delegates). No clique em modo
«play», `activitiesGrid.burstParticles(activityCard)` mapeia o cartão para
coordenadas do `contentItem`, dá ao `Item` a posição e o tamanho do cartão e
faz o mesmo `burst(50)`.

- Sem reparent para delegates recicláveis; o `anchors.fill: parent` do loader
  enche o `Item` posicionado, por isso `ParticleSystemStarLoader.qml` não foi
  alterado.
- No `contentItem`, o sistema acompanha o scroll e fica sob o mesmo `clip` e a
  mesma máscara (`layer`) da grelha, como os loaders antigos.
- O `Emitter` usa `velocityFromMovement`, mas a sua posição local no sistema não
  muda quando o `Item` se desloca, portanto mover o sistema não acrescenta
  velocidade às partículas.
- O loader da secção de categorias (`backgroundSection`, `burst(10)`) não foi
  alterado.

## Binário e recursos

- Binário: `build/pt-pt/bin/gcompris-qt` (Qt 6.10.2, Ninja, `WITH_RCC=ON`),
  SHA256 `555e4d73f94de2fabf0371af0f88869c08ffb2fbb1a8e3a0924abdaaf3cd399d`.
  O WP2b só altera QML, por isso o binário é o mesmo do WP1.
- `nice cmake --build build/pt-pt --parallel 4` → nada a compilar para além de
  `menu.rcc`; `ninja -n` sem alvos pendentes antes dos testes.
- Snapshot de recursos criado depois da alteração a partir deste build:
  `python3 tools/native_qml_resources.py --binary build/pt-pt/bin/gcompris-qt --output <scratch>/snapshot`,
  `manifest.json` SHA256 `7a8b9dea9cf2a57821e4d5457377b1db0cede0e2454aecc5ce82caec3dee31c6`;
  `core.rcc` `1c6bd63599c79d70edf9dcadc1b17c18298531f36aab9066af87b1e13b36adbc`
  (igual ao do build). O runner recompila `menu.rcc` a partir do `Menu.qml`
  em teste e a atividade de `--extra-activity` a partir da fonte.
- Todas as execuções: `--offline` (Docker, rede `none`), perfil privado em
  `XDG_CONFIG_HOME`/`XDG_DATA_HOME`/`XDG_CACHE_HOME` dentro da implantação
  temporária; a configuração do utilizador não é usada. Sem `data3` (palavras e
  vozes), que estes casos não usam.
- `tools/run-native-qml-case.py` SHA256
  `a0fe504594cf7d94f0251870b9388bb372605d342b38955628e9387bcf86d100`.

## Caso novo: `tests/menu/particles.qml`

SHA256 `a8088e9b4de903660c802e01a8f7356da2d0db07ea92ed2cf5628732fa64cbf3`.
Abre a secção Estratégia (23 cartões), percorre a árvore de itens sob
`activitiesGrid` e conta os loaders pelo `source` carregado
(`…/src/core/ParticleSystemStar.qml`), os sistemas efetivamente carregados e os
delegates. Depois desloca a grelha (`contentY` 193,5), clica no cartão
Dominório, verifica que o loader partilhado ficou exatamente sobre o cartão
(desvio 0,0; 127,5 × 199 igual ao cartão) e que o sistema arrancou, que a
atividade abre e é jogável, e que no regresso ao menu continua a haver um só
sistema.

```sh
python3 tools/run-native-qml-case.py --resource-snapshot <scratch>/snapshot \
  --activity menu --from-menu --extra-activity dominorio \
  --qml-file src/activities/menu/Menu.qml --case tests/menu/particles.qml \
  --output <nova pasta> --offline --timeout 120
```

| Execução | `Menu.qml` (SHA256) | Loaders / sistemas / cartões | Resultado |
|---|---|---|---|
| antes (HEAD `cd486b726`) | `8a2d6531…` | 23 / 23 / 23 | vermelho: `failures 1`, «got 23 for 23 cards» |
| depois, 3 execuções | `c5a21374…` | 1 / 1 / 23 (menu e regresso) | verde: `failures 0, passes 2` ×3 |

Vermelho obtido com a versão final do caso, repondo temporariamente o
`Menu.qml` de `HEAD` e voltando depois à versão alterada.

Durante o desenvolvimento do caso, o clique em «início» logo após abrir a
atividade falhou de forma intermitente: o centro do botão estava em y≈800
numa janela de 800 px, com a página ainda a entrar. O caso espera agora que o
botão esteja inteiro dentro da janela antes de clicar. Não está relacionado
com as partículas: `dominorio.qml`, que clica no mesmo botão mais tarde, passou
com a alteração.

## Regressão de casos existentes (depois da alteração)

| Caso | `--extra-activity` | Resultado |
|---|---|---|
| `tests/crjm/dominorio.qml` (pesquisa, clique no cartão, jogo completo, regresso ao menu) | `dominorio` | verde, `failures 0, passes 2` |
| `tests/crjm/produto.qml` | `produto` | verde, `failures 0, passes 2` |
| `tests/crjm/faisca.qml` | `faisca` | verde, `failures 0, passes 2` |

Todos sem erros QML no `result.json` (`qml_errors: []`).

`LC_ALL=en_US.UTF-8 QT_QPA_PLATFORM=offscreen ctest --test-dir build/pt-pt --output-on-failure`
→ 8/8 passed, exit 0.

## Limitações

- O efeito visual do clique não foi avaliado por uma pessoa: as execuções usam
  renderização por software offscreen e a atividade abre logo a seguir ao
  clique. Verificou-se apenas a geometria e o arranque do sistema partilhado.
- O ganho de memória ou de tempo não foi medido. O pico de memória do cgroup
  (~101 MB no caso verde, ~92 MB no vermelho) não é comparável: o vermelho
  pára antes de abrir a atividade.
- Não foi testado com OpenGL, onde a grelha usa `layer`/`MultiEffect`. O
  sistema partilhado está dentro da mesma grelha que os loaders antigos.
- Não foi testado num dispositivo Android, onde `hasShader` é `false` e o loader
  fica inativo, tal como antes.
