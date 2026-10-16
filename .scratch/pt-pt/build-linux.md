# Compilação Linux

Compilação concluída no Ubuntu 26.04 com Qt 6.10.2, GCC 15.2 e OpenSSL 3.5.5.
O utilizador instalou as dependências que exigiam sudo.

## Comandos

Executar na raiz do repositório:

```bash
cmake -S . -B build/pt-pt -DBUILD_TESTING=ON -DBUILD_SERVER=OFF -DDOWNLOAD_ASSETS=words,full,music,pt
cmake --build build/pt-pt --parallel 4
cmake --build build/pt-pt --target getAssets
LC_ALL=en_US.UTF-8 QT_QPA_PLATFORM=offscreen ctest --test-dir build/pt-pt --output-on-failure
```

`BUILD_SERVER=OFF` desativa apenas a aplicação separada `gcompris-teachers`, que
exige Qt Charts mesmo com Qt 6.10. Todas as 203 atividades permanecem incluídas.
O submódulo qml-box2d está na revisão fixada pelo projeto:
`e3674e0fe030c406a1d915e47eab760624fffa55`.

`DOWNLOAD_ASSETS` seleciona os recursos. O alvo `getAssets` é necessário para os
descarregar; não é executado pela compilação padrão. Foram descarregados os pacotes
de imagens de palavras, recursos completos OGG, música e vozes `pt`.
O registo da aplicação confirmou a seleção `pt_PT.UTF-8` → `pt` e o carregamento do
pacote `voices-pt-2026-09-23-18-56-49.rcc`.

## Resultados

- Configuração e compilação concluídas com código 0.
- A aplicação compilada listou as 203 atividades, sem ausências face a
  `src/activities/activities.txt`.
- `msgfmt --check --check-format` aceitou o catálogo da interface PT.
- Quatro testes Python do inventário passaram.
- As oito suites C++ passaram com `LC_ALL=en_US.UTF-8`.
- No locale original `C`, sete suites passaram e `CoreApplicationInfoTest` falhou.
  A linha `default` espera `C`, mas a aplicação normaliza este locale para `en_US`.
  Os casos explícitos `pt_PT` e `pt_BR` passaram. Ver a tarefa 10.
- `compass`, `sketch` e `drawing_wheels` passaram o teste de arranque após corrigir
  a incompatibilidade do seletor de cores. Ver a tarefa 09.
- O compasso foi aberto numa janela X11 real e o painel da caneta foi aberto com
  a tecla P. A captura mostra os controlos em português.

Os avisos sobre Wayland são opcionais nesta compilação. A verificação visual foi
feita em X11. Os testes de arranque não comprovam a conclusão de todos os níveis,
a qualidade de todas as gravações ou a instalação offline em Windows.

## Executar a aplicação

```bash
build/pt-pt/bin/gcompris-qt --window --locale pt_PT
```

## Evidências locais

- Configuração: `build/pt-pt/configure.log`.
- Compilação: `build/pt-pt/build.log` e `build/pt-pt/rebuild.log`.
- Recursos: `build/pt-pt/assets.log`.
- Testes: `build/pt-pt/ctest.log` e `build/pt-pt/ctest-en-us.log`.
- Lista real de atividades: `build/pt-pt/list-activities.log`.
- Arranque antes da correção: `build/pt-pt/smoke-before/`.
- Arranque após a correção: `build/pt-pt/smoke-after/`.
- Capturas antes e depois: `build/pt-pt/compass-before.png` e
  `build/pt-pt/compass-pt-pt.png`.

As evidências em `build/` são ficheiros locais ignorados pelo Git.
