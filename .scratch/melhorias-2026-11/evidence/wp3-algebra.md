<!-- SPDX-FileCopyrightText: NONE -->
<!-- SPDX-License-Identifier: CC0-1.0 -->
# WP3 — Cálculo sem cronómetro: evidência

Data: 2026-11-10. Worktree próprio, branch `t3/65916b83`.
Base: `edb22ee81`. Commit testado: `8bdc54c93` (código e testes; este
ficheiro vem no commit seguinte).

## Runtime testado

- Build: `cmake -S . -B build/pt-pt -G Ninja -DBUILD_TESTING=ON
  -DBUILD_SERVER=OFF -DCMAKE_BUILD_TYPE=RelWithDebInfo` e
  `nice cmake --build build/pt-pt --parallel 4` → exit 0 (330 passos).
  Depois das alterações, o mesmo comando recompilou só
  `rcc/algebra_{plus,div,minus,by}.rcc` (5 passos) → exit 0.
- Binário `build/pt-pt/bin/gcompris-qt` (sem alterações C++ no WP3):
  sha256 `241cd4ea99046c6d84256ad1bd9187c9a10ad0174af966285a4a63fe4e0736cc`.
- Snapshots (`tools/native_qml_resources.py --binary build/pt-pt/bin/gcompris-qt`):
  - linha de base (HEAD `edb22ee81`): manifest sha256 `a586ca41…d17c`;
  - WP3 (depois do rebuild): manifest sha256 `d2748ee4…6c3f`.
- O runner recompila só o recurso de `--qml-file` (`algebra_by`); o
  `ActivityConfig.qml` de `algebra_plus/minus/div` vem do snapshot. Os
  `result.json` registam esse `.rcc` e coincide com o build atual:
  plus `b84262018028…`, minus `88b89305e64d…`, div `661cf8d056d7…`
  (linha de base: `c440a615eb29…`, `371dbca9be82…`, `ff737237913c…`).
- `Algebra.qml` compilado no recurso privado: linha de base `a72f4840c495…`
  (= `git show HEAD:…`), WP3 `6b4438c776ef…` (= commit `8bdc54c93`).
- Isolamento: todos os casos com `--offline` (Docker `--network none`,
  imagem `alpine` `sha256:28bd5fe8…`) e perfil XDG privado criado pelo
  runner; a configuração real do utilizador (`~/.config/gcompris`) não foi
  usada nem alterada.

Comando por caso (atividade ∈ plus, minus, by, div; `--timeout` 90/120/240):

```bash
python3 tools/run-native-qml-case.py --source-root . \
  --resource-snapshot SNAPSHOT --activity algebra_X \
  --qml-file src/activities/algebra_by/Algebra.qml \
  --case tests/functional_algebra/CASO.qml --output NOVO \
  --timeout T --result-marker NATIVE_ALGEBRA_RESULT --offline
python3 tests/functional_algebra/run.py --activity algebra_X \
  --resource-snapshot SNAPSHOT --output NOVO     # gameplay
```

## Resultados

| Caso | Antes (`edb22ee81`) | Depois (`8bdc54c93`) |
| --- | --- | --- |
| `controls.qml` | 4/4 passed (0 falhas) | 4/4 passed |
| `keyboard.qml` | 4/4 passed | 4/4 passed |
| `configurations.qml` | 4/4 passed | 4/4 passed (liga `timeLimit = "on"` antes do ciclo; durações 100000…10000 e `timeout` mantidos) |
| `gameplay.qml` (`run.py`) | 4/4 passed | 4/4 passed |
| `timelimit-default.qml` (novo) | — | 4/4 passed |
| `timelimit-dialog.qml` (novo) | — | 4/4 passed |
| `timelimit-legacy.qml` (novo) | — | 4/4 passed |

Todos com `exit_code 0`, `qml_errors: []`, `failures: 0`.
`ctest` no `build/pt-pt` → 8/8 passed (1,73 s).

Detalhe dos casos novos (valores de `case_result`):

- **Omissão sem limite** (`timelimit-default`): sem configuração guardada,
  `activity.timeLimit == "off"`, balão escondido. Quatro esperas de 22,5 s
  (> 21 s = 20 s da velocidade 5 + 1 s de subida), amostradas a cada 0,5 s
  com o balão em repouso (`y == -height`, `rotation == 0`), sem `timeout`,
  sem `Bonus`: 1.ª pergunta; depois de uma resposta certa; com
  redimensionamento da janela durante a pergunta (altura 720 → 576; houve
  outro no ecrã «Estou pronto», 800 → 720); depois de uma resposta errada.
  A resposta certa seguinte foi sempre aceite (pontuação final 4, 0
  timeouts) nas quatro atividades.
- **Alternância pelo diálogo real** (`timelimit-dialog`): por omissão a
  caixa está marcada e o slider desativado/esbatido; clicar na caixa ativa o
  slider (máximo 10 em `algebra_by`, 5 nos outros); «Gravar» grava
  `timeLimit "on"`. Com limite: `balloon.duration` 10000 (by) / 20000
  (outros) e `timeout` aos ~11,0 s / ~21,0 s, dentro da janela de 14 s /
  24 s. Reaberto, mostra o limite ligado; desligado e gravado
  (`timeLimit "off"`, `speedSetting` mantido), a mesma janela (14,5 s /
  24,5 s) passa sem `timeout` nem movimento e a resposta é aceite.
  Reaberto outra vez, mostra «Sem limite» marcado; «Cancelar» mantém-no.
- **Persistência**: cada reabertura do diálogo relê
  `ApplicationSettings.loadActivityConfiguration` através de
  `getInitialConfiguration()`, a mesma função que carrega a configuração
  quando a atividade é criada.
- **Configuração antiga** (`timelimit-legacy`): grava só
  `{speedSetting: 3}` num perfil limpo e recarrega pelo `initializePanel()`
  do diálogo. Resultado: `timeLimit "on"`, `balloon.duration == 33333 ==
  floor(100000/3)`, balão visível e a cair; o diálogo mostra o limite
  ligado com velocidade 3; depois de «Gravar», `{timeLimit: "on",
  speedSetting: 3}` e a mesma duração.

Verificação negativa: `timelimit-default.qml` contra o código de
`edb22ee81` (`git archive` para a pasta temporária, snapshot de base,
`algebra_plus`) → exit 1. Primeira falha: não existe `timeLimit`; numa
cópia temporária sem essa asserção nem as de visibilidade, falhou na
1.ª amostra com «first question: balloon must not fall» (`y -414,9999`,
`height 415`): no código antigo o balão começa logo a cair.

## Capturas (PNG reais do runner)

- `wp3-algebra/config-no-limit-algebra_plus.png` — diálogo por omissão
  (sha256 `e28ecb3a…a7`).
- `wp3-algebra/config-time-limit-algebra_by.png` — limite ligado, velocidade
  10 (sha256 `b4965b28…b1`).
- `wp3-algebra/config-legacy-algebra_div.png` — configuração antiga migrada
  (sha256 `e2a5ad87…76`).
- `wp3-algebra/game-no-limit-algebra_minus.png` — jogo sem balão depois das
  esperas (sha256 `ab4f2fc9…74`).

## Limites

- Não testa gestos no slider: o caso atribui `speedSlider.value` como um
  arrasto faria.
- «Reabrir» é reabrir o diálogo, não sair para o menu e voltar a abrir a
  atividade: o `TestCase` vive dentro da página da atividade e seria
  destruído. O runner também não permite semear a configuração antes do
  arranque.
- Sem validação em Windows 10 escolar, tablets ou com crianças.
- Os textos novos (`qsTr`) estão em pt-PT no QML; noutras línguas aparecem
  em pt-PT até haver tradução.
