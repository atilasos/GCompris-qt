<!-- SPDX-FileCopyrightText: NONE -->
<!-- SPDX-License-Identifier: CC0-1.0 -->
# WP1: cache de verificação dos RCC

Medição em 2026-11-10. Código WP1 no commit que introduz este ficheiro,
identificável com `git log -1 --format=%H -- .scratch/melhorias-2026-11/evidence/wp1-rcc-cache.md`.
Pai/base medida pelo WP2a: `e46034a273646158a7e5d0e3bb72aa0db9738c97`.
O binário medido contém exatamente as alterações C++ deste commit.

- Binário: `build/pt-pt/bin/gcompris-qt`, Qt 6.10.2, Ninja,
  `BUILD_TESTING=ON`, `WITH_RCC=ON`, `WITH_DOWNLOAD=ON`.
- SHA256: `555e4d73f94de2fabf0371af0f88869c08ffb2fbb1a8e3a0924abdaaf3cd399d`.
- Compilação integral, incluindo `gcompris-qt`, `rcc_core` e `rcc_menu`:
  `nice cmake --build build/pt-pt --parallel 4`.
- Testes: `LC_ALL=en_US.UTF-8 QT_QPA_PLATFORM=offscreen ctest --test-dir build/pt-pt --output-on-failure`.
  Resultado final: 8/8, 1,03 s. HOME e todas as pastas XDG foram isolados
  numa pasta temporária também na execução do ctest.

## Comandos de medição

```sh
python3 .scratch/melhorias-2026-11/evidence/measure-startup.py \
  --binary build/pt-pt/bin/gcompris-qt \
  --resources /home/proteu/Projetos/GCompris-qt/build/pt-pt/share/gcompris-qt/rcc/data3 \
  --warm 5 --cold 3

python3 .scratch/melhorias-2026-11/evidence/measure-startup.py \
  --binary build/pt-pt/bin/gcompris-qt \
  --resources /home/proteu/Projetos/GCompris-qt/build/pt-pt/share/gcompris-qt/rcc/data3 \
  --warm 5 --cold 3 --reuse-cache
```

O primeiro comando mantém cache vazia no início de cada processo. O segundo
partilha apenas XDG_CACHE_HOME entre o aquecimento e os oito processos medidos.
Todos os perfis e a cache partilhada são temporários; os recursos externos são
somente lidos. Descargas automáticas **desligadas** em ambas as séries,
com `[%General] enableAutomaticDownloads=false`. Restantes definições,
terminação e recursos iguais à linha de base em `startup-baseline.md`.
O formato de registo do WP2a foi preservado.

## Antes e depois

Soma dos cinco `updateResource`, em ms, mediana e intervalo mín–máx.
«Frio» refere-se à page cache do SO; a cache persistente MD5 mantém-se na
última linha. Nas duas séries, mincore confirmou residência 0,000 para todos
os ficheiros expulsos antes de cada execução a frio.

| Revisão e estado inicial da cache MD5 | Quente (n=5) total | Frio (n=3) total | Quente: verificação | Frio: verificação |
|---|---|---|---|---|
| WP2a, sem cache de verificação | 199,9 (199,2–207,1) | 219,5 (205,9–224,5) | 199,3 (198,5–206,6) | 218,9 (205,2–223,9) |
| WP1, primeiro arranque com cache vazia | 133.4 (127.8–134.2) | 142.0 (138.6–143.6) | 132.8 (127.3–133.8) | 141.5 (138.0–143.0) |
| WP1, arranques seguintes com cache persistente | 0.3 (0.3–0.7) | 2.8 (1.4–3.2) | 0.1 (0.1–0.1) | 0.6 (0.1–0.7) |

O aquecimento da série partilhada, primeiro processo com cache vazia, gastou
122,5 ms no total e 122,0 ms na verificação. Já beneficia da reutilização
dentro do processo nas segundas chamadas de palavras e música.
«Verificação» é o campo `checksum` do registo; inclui consultas à cache e
escritas quando necessárias, não apenas MD5. O ganho referido é deste
percurso, não do tempo total até a interface estar pronta.

## Resultados por processo

| Série | Processo | Page cache fria | initialize ms | Soma total ms | Soma verificação ms |
|---|---|---|---|---|---|
| vazia | warmup | False | 332.2 | 142.8 | 142.4 |
| vazia | warm | False | 304.4 | 127.8 | 127.3 |
| vazia | warm | False | 318.9 | 134.2 | 133.8 |
| vazia | warm | False | 322.5 | 133.8 | 133.3 |
| vazia | warm | False | 362.4 | 133.4 | 132.8 |
| vazia | warm | False | 320.0 | 129.8 | 129.3 |
| vazia | cold | True | 375.3 | 138.6 | 138.0 |
| vazia | cold | True | 352.8 | 143.6 | 143.0 |
| vazia | cold | True | 414.3 | 142.0 | 141.5 |
| partilhada | warmup | False | 383.5 | 122.5 | 122.0 |
| partilhada | warm | False | 227.9 | 0.3 | 0.1 |
| partilhada | warm | False | 223.4 | 0.3 | 0.1 |
| partilhada | warm | False | 280.4 | 0.3 | 0.1 |
| partilhada | warm | False | 256.7 | 0.7 | 0.1 |
| partilhada | warm | False | 228.5 | 0.4 | 0.1 |
| partilhada | cold | True | 264.4 | 3.2 | 0.7 |
| partilhada | cold | True | 324.1 | 2.8 | 0.6 |
| partilhada | cold | True | 309.0 | 1.4 | 0.1 |

Todas as 18 execuções produziram initialize e as cinco linhas esperadas.

## Desenho e testes

Cache JSON versionada em `ApplicationSettings::cachePath()/rcc-checksums-v1.json`,
com caminho canónico como chave e tamanho, mtime em ms e MD5 calculado como
valor. Tamanho e mtime são strings decimais para preservar os inteiros.
`QSaveFile` faz a substituição atómica, somente quando o conteúdo muda.
Cache ausente, JSON inválido, versão desconhecida ou entradas inválidas são
ignorados sem avisos. Falha de escrita não impede a verificação nem a
reutilização em memória. Não se alterou gcompris-qt.conf.

O checksum esperado é comparado em cada chamada, incluindo com cache quente.
A descarga concluída passa explicitamente forceHash=true; substituições,
remoções e abertura para escrita invalidam as entradas correspondentes.
Os percursos locais updateResource, available/parseContents e finishDownload
usam a cache. Metadados são verificados novamente após a leitura para evitar
persistir uma entrada se o ficheiro tiver mudado durante o hash.

Os chamadores QML e main.cpp usam a thread principal. Os replies da
QNetworkAccessManager ligam-se ao gestor com AutoConnection, na mesma thread;
não há moveToThread do gestor no código. Uma asserção documenta essa condição
no ponto de acesso à cache; não foi necessário acrescentar mutex.

- `test_checksumCache:reuse`: contador de hashes fica em 1; alterar os bytes
  preservando tamanho e mtime conserva o resultado em cache, explicitando o compromisso.
- `:size` e `:mtime`: cada alteração isolada obriga ao segundo hash integral.
- `:expected`: checksum errado falha antes e depois de preencher a cache;
  o MD5 guardado permite verificar o esperado correto sem reler.
- `:force`: duas verificações forçadas detetam bytes alterados apesar de
  metadados iguais e fazem dois hashes; a chamada local seguinte reutiliza o MD5 calculado.
- `:corrupt` e `:version`: nova instância recalcula e repara JSON inválido ou
  versão desconhecida; outra instância reutiliza o ficheiro reparado sem hash.
- `:unwritable`: cache sob um ficheiro normal, impossibilitando a escrita
  mesmo como root, não impede a verificação.
- `test_checksumCacheCanonicalPathAndWrites`: caminhos equivalentes partilham
  uma entrada; releitura forçada com MD5 igual não reescreve a cache; invalidar
  remove a entrada persistente e obriga a novo hash.
- `test_checksumCachePersistsAcrossProcesses`: dois processos reais, primeiro
  com 1 hash e segundo com 0, sobre a mesma pasta temporária.
- `test_onlineVoiceUpdatesAndRepair`, nas três linhas existentes, foi reforçado:
  cada transferência RCC concluída acrescenta um hash integral; a verificação
  local seguinte já o reutiliza. As asserções anteriores foram mantidas.
- As colisões `same-filename-different-checksum` e os restantes testes antigos
  passaram sem enfraquecer as suas asserções.

## Limitações

Máquina de desenvolvimento com NVMe; não mede PCs escolares Windows 10/HDD,
tablets ou utilização com crianças. O ganho com descargas ligadas não foi
medido; esse percurso foi exercitado pelos testes locais de rede.
A definição usada nas escolas é desconhecida.

Tamanho e mtime iguais não provam conteúdo igual. Aceita-se o compromisso
expresso no plano para escolher entre RCC empacotado e em cache com o mesmo
nome; não é uma defesa contra adulteração. A cache não coordena escritores
em processos concorrentes: a gravação atómica mantém o ficheiro válido, mas
podem perder-se entradas de desempenho entre processos. Uma falta de entrada
leva a novo hash. Os testes e medições usam processos sequenciais.
