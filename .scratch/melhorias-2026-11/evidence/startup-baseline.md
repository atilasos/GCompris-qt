<!-- SPDX-FileCopyrightText: NONE -->
<!-- SPDX-License-Identifier: CC0-1.0 -->
# WP2a — Linha de base do arranque (antes do WP1)

Medido em 2026-11-10 com a categoria `gcompris.startup` introduzida pelo WP2a.

## Binário e código

- Código: commit WP2a (pai `afd244b9a`). Em `src/` e `CMakeLists.txt` difere
  de `8108a5fe3` só pela instrumentação do WP2a e por dois `PROVENANCE.md` do
  WP5 (documentação, sem efeito no binário). É, portanto, o motor de
  `8108a5fe3`, antes do WP1.
- Binário: `build/pt-pt/bin/gcompris-qt` (Ninja, `BUILD_TESTING=ON`,
  `WITH_RCC=ON`, `WITH_DOWNLOAD=ON`), Qt 6.10.2.
- sha256 do binário:
  `92cca9e5062da16541813c5299242e8bd856a89e43acaf0586d86625284db2e2`

## Comando

```sh
python3 .scratch/melhorias-2026-11/evidence/measure-startup.py \
  --binary build/pt-pt/bin/gcompris-qt \
  --resources /home/proteu/Projetos/GCompris-qt/build/pt-pt/share/gcompris-qt/rcc/data3 \
  --warm 5 --cold 3
```

O script (`measure-startup.py`, nesta pasta) faz, por execução:

- perfil novo e isolado (`HOME`, `XDG_CONFIG_HOME`, `XDG_DATA_HOME`,
  `XDG_CACHE_HOME`, `XDG_RUNTIME_DIR` numa pasta temporária);
- `gcompris-qt.conf` com `[%General] enableAutomaticDownloads=false`
  (no INI do `QSettings` o grupo «General» escreve-se `[%General]`; com
  `[General]` a definição é ignorada e as descargas ficam ligadas),
  `[Internal] exeCount=10` (percurso normal de `main.qml`, não o da primeira
  execução) e `lastGCVersionRan=999999` (sem diálogo de novidades);
- ligações simbólicas de `words/`, `voices-ogg/` e `backgroundMusic/` da pasta
  `--resources` (só leitura) para `$XDG_DATA_HOME/gcompris-qt/data3/`, um dos
  caminhos de `DownloadManager::getSystemResourcePaths()`; o `full-*.rcc` e o
  `Contents` da raiz não são ligados;
- `QT_LOGGING_RULES="gcompris.startup.info=true" QT_QPA_PLATFORM=offscreen
  LC_ALL=C.UTF-8 gcompris-qt --window --locale pt_PT --renderer software --mute`;
- termina a aplicação (`SIGTERM`) assim que aparecem a linha de `initialize`
  e as 5 linhas de `updateResource`.

Primeiro corre um arranque de aquecimento, descartado; depois 5 «a quente» e
3 «a frio». Antes de cada arranque a frio, `posix_fadvise(POSIX_FADV_DONTNEED)`
expulsa da page cache os `.rcc` externos, os `.rcc` de `build/pt-pt/share/gcompris-qt/rcc`
e o binário, e `mincore(2)` confirma a residência: **0,000 em todos os
ficheiros expulsos, nas 3 execuções a frio**.

Ficheiros externos registados: `voices-pt-2026-10-16-00-00-00.rcc` (36 MB),
`words-webp-2022-04-10-21-14-15.rcc` (42 MB),
`backgroundMusic-ogg-2024-03-19-11-10-30.rcc` (16 MB).

## Resultados (ms; mediana e intervalo mín–máx)

«MD5» é o tempo gasto em `checksumMatches` dentro da chamada; «total» inclui
também `registerResourceAbsolute`.

| Medição | Quente (n=5) | Frio (n=3) |
|---|---|---|
| `ActivityInfoTree::initialize` (211 atividades) | 330,9 (306,9–445,5) | 374,6 (367,3–418,4) |
| `updateResource` VOICES (`voices-pt`) — total | 51,1 (48,5–58,7) | 66,5 (49,9–69,3) |
| `updateResource` VOICES (`voices-pt`) — MD5 | 50,8 (48,3–58,4) | 66,2 (49,7–69,1) |
| `updateResource` WORDSET, 1.ª chamada — total | 53,5 (53,5–54,1) | 57,6 (56,9–58,6) |
| `updateResource` WORDSET, 1.ª chamada — MD5 | 53,5 (53,4–54,0) | 57,5 (56,8–58,5) |
| `updateResource` WORDSET, 2.ª chamada — total | 53,8 (53,4–54,3) | 53,3 (53,2–53,8) |
| `updateResource` WORDSET, 2.ª chamada — MD5 | 53,7 (53,3–54,1) | 53,2 (53,1–53,6) |
| `updateResource` BACKGROUND_MUSIC, 1.ª chamada — total | 20,7 (20,5–21,0) | 22,6 (22,5–24,0) |
| `updateResource` BACKGROUND_MUSIC, 1.ª chamada — MD5 | 20,7 (20,5–20,9) | 22,6 (22,5–23,9) |
| `updateResource` BACKGROUND_MUSIC, 2.ª chamada — total | 20,7 (20,6–21,6) | 20,6 (20,4–20,7) |
| `updateResource` BACKGROUND_MUSIC, 2.ª chamada — MD5 | 20,6 (20,5–21,4) | 20,5 (20,3–20,5) |
| Soma dos 5 `updateResource` — total | 199,9 (199,2–207,1) | 219,5 (205,9–224,5) |
| Soma dos 5 `updateResource` — MD5 | 199,3 (198,5–206,6) | 218,9 (205,2–223,9) |

## Observações

- Com descargas desligadas, `main.qml` (percurso normal, l. 385-391) chama
  `updateResource` 5 vezes: vozes uma vez, palavras e música duas vezes cada
  (`checkWordset()`/`checkBackgroundMusic()` e a chamada explícita a seguir).
  A 2.ª chamada volta a ler e a fazer o MD5 do ficheiro inteiro e a anular e
  refazer o registo: ~74 ms dos ~200 ms são repetição.
- Quase todo o custo de `updateResource` é MD5 (limitado por CPU, ~0,8 GB/s);
  a frio o acréscimo é pequeno (+2 a +15 ms por ficheiro, na mediana) porque o NVMe lê
  depressa. Num disco lento a diferença a frio será maior (não medido).
- **Definição por omissão:** em desktop, `enableAutomaticDownloads` vale por
  omissão `!isMobile() && isDownloadAllowed()`, ou seja `true` neste build.
  Nesse caso `updateResource` não faz MD5 síncrono: vai a `downloadResource`,
  pede o `Contents` ao servidor (`cdn.kde.org`) e o MD5 do ficheiro local
  corre depois, em `finishDownload`, quando a resposta chega (verificado
  acidentalmente num ensaio com o INI mal escrito, ver acima). A linha de base
  acima mede o percurso com descargas desligadas; a definição dos PCs da
  escola é desconhecida.
- `parseContents` (em `initializeAssets`) só faz MD5 (`available()`) quando
  dois `Contents` locais divergem; nesta configuração (um só `Contents` por
  pasta) não o faz, e esse tempo não está instrumentado.
- Com a categoria desligada, a saída da aplicação é igual byte a byte à do
  binário anterior ao WP2a (comparado normalizando o caminho temporário e a
  porta UDP); com ela ligada só se acrescentam as linhas `gcompris.startup:`.

## Limitações

- Máquina de desenvolvimento (Intel i5-12600K, 16 threads, 46 GB RAM, NVMe,
  Linux 7.0), não o equipamento escolar (Windows 10, discos possivelmente
  lentos). Os valores servem para comparar antes/depois do WP1 nesta
  máquina, não para prever tempos na escola.
- «Frio» só cobre os ficheiros expulsos (RCC externos, RCC de atividades e
  binário); as bibliotecas Qt e do sistema, partilhadas e mapeadas por outros
  processos, ficam na cache. `initialize` a frio é por isso só parcialmente
  frio.
- Plataforma `offscreen` com renderizador por software e sem áudio.
- Não cobre descargas assíncronas nem o percurso com descargas ligadas.
- Amostras pequenas (5 + 3); máquina com outra carga de trabalho em paralelo.
