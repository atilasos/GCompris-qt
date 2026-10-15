# Validação do teste de vozes do sistema

A expectativa antiga foi reproduzida antes da correção:

| Locale do processo | Esperado pelo teste antigo | Resultado da aplicação |
| --- | --- | --- |
| C | C | en_US |
| pt_PT.UTF-8 | pt_PT | pt |

A seleção de vozes em produção não foi alterada. A tabela de teste independente
verifica C → en_US, pt_PT → pt, en_US → en_US, en_GB → en_GB, pt_BR → pt_BR e
fr_FR → fr. Cada fixture inicia um novo processo, confirma o nome do locale do
sistema e executa a seleção predefinida da aplicação. A alteração global de
QLocale foi removida.

## Construção isolada

A construção de testes foi preparada em `/tmp/gcompris-pt-locale-build`, com:

```bash
cmake -S . -B /tmp/gcompris-pt-locale-build \
  -DBUILD_TESTING=ON -DBUILD_SERVER=OFF \
  -DQML_BOX2D_MODULE=disabled -DPACKAGE_GCOMPRIS=OFF
cmake --build /tmp/gcompris-pt-locale-build --target \
  ActivityInfoTest ApplicationSettingsTest DatasetTest DirectoryTest FileTest \
  ApplicationInfoTest DownloadManagerTest GImageGrabberTest -j4
```

A opção Box2D aplica-se apenas a esta construção de testes. Os testes não precisam
do plugin dos jogos. Não foi alterada a configuração da aplicação partilhada.

DownloadManagerTest requer `money.rcc`, `penalty.rcc` e `mosaic.rcc`. A primeira
execução privada falhou por ausência destes recursos. Foram disponibilizados no
caminho privado `share/gcompris-qt/rcc/` através de ligações simbólicas para os
ficheiros existentes no build principal. Os testes apenas os leem e registam;
não foi reconstruído nem modificado qualquer RCC partilhado.

## Resultados

Executaram-se as oito suites C++ três vezes, com `LC_ALL` definido para `C`,
`pt_PT.UTF-8` e `en_US.UTF-8`, `QT_QPA_PLATFORM=offscreen`, cache e configuração
XDG em diretórios privados. Todas as execuções passaram, oito suites por locale.
Os logs completos do CTest estão nos três ficheiros `.log` com os nomes dos
locales. `application-info.log` mostra os 18 casos aprovados, sem falhas ou skips,
incluindo os seis fixtures de sistema.

O host não tem o locale libc pt_PT gerado. Qt emite um aviso relativo à codificação
e usa UTF-8; os próprios fixtures confirmam que `QLocale::system().name()` é
`pt_PT` e que o conjunto de vozes é `pt`. O resultado prova a normalização Qt da
aplicação, sem afirmar que o locale do sistema operativo foi instalado.

Os fixtures por variáveis POSIX são compilados apenas em Unix. Não afirmam que
`LC_ALL` altera a configuração regional do Windows. Os casos de locale explícito
pt_PT e pt_BR permanecem multiplataforma. A execução da aplicação e do instalador
Windows continua a exigir a validação prevista nas tarefas próprias.
