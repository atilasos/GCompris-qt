# Aplicação dos dois pares aprovados — tarefa44

A decisão do professor «podemos usar o que foi criado» autoriza os nomes
**cervato** e **carraça** e os dois WAV apresentados no pacote de comparação.
A aprovação exata está em
[human-approval.json](../legacy-word-review/human-approval.json), SHA-256
`7aaa494997f32a01661e5b6607d305dce353990bb7f4862166c60dc78ff4ad9c`.
A tarefa continua claimed para integração e revisão separadas.

## Alteração e identidades

`content-pt.json` altera apenas `fawn.ogg` e `tick.ogg`. Os dois WAV aprovados
foram codificados uma vez com GStreamer 1.28.2, `wavparse ! audioconvert !
vorbisenc quality=0.5 ! oggmux`. Não houve nova síntese. O manifesto
`resources/pt-pt-voices/replacements.json` contém o hash de cada WAV, o OGG
obtido, comandos reais, duração e hash do PCM descodificado. Os frames
22050 Hz/mono/S16LE coincidem com a duração dos WAV: 12544 e 13056.
A aprovação dos WAV não é apresentada como audição destes bytes OGG.
Os números de série Ogg podem variar numa nova codificação: distribuir os OGG
versionados; repetir a codificação serve para investigar o processo, não para
substituir automaticamente as identidades aprovadas para distribuição.

O RCC privado `voices-pt-2026-10-16-00-00-00.rcc` tem SHA-256
`766a4650c93cf0d012c768daca8f54a931e061e77e7e7b7ef35585bf05c2869b`.
O inventário real comprova 1610 recursos: 1576 originais intactos, as 32 adições
intactas e apenas 2 substituições. Ver [physical-preservation.json](physical-preservation.json)
e [physical-audit.json](physical-audit.json). O manifesto das 32 e os 32 OGG
foram comparados byte a byte com Git `b9c2a2ad9`.

O RCC upstream de 1578 recursos permanece presente com SHA-256
`522d05bcf421e3cee2fdebf7ba9469ff294a69b61d629464283855297e006b8f`.
Os oito elementos upstream do lock não mudaram. O novo campo
`pt_voice_completion` fixa o RCC, Contents, proveniência e as duas substituições;
o verificador CLI recusa ausência ou alteração dessa conclusão. O manifesto
novo declara `original_bytes_preserved:false`, `preserved_original_files: 1576`
e `replaced_files:2`. Os relatórios antigos continuam a descrever o pacote
anterior, sem serem reescritos.

O ZIP ouvido pelo professor conserva SHA-256
`fe3563da247ebe91a149b32b7c7849795534284dba06c91f79677f400c81c179`;
foi também copiado para `build/approved-review-original.zip`. Os WAV, amostras
originais, manifesto e documentos históricos em `legacy-word-review/` permanecem
intactos.

## Verificações executadas

- TDD: nomes antigos→nomes aprovados, falta da interface de substituições→duas
  aceites, falta de política fixa→política e bytes verificados. Logs `*-red.log`
  e `*-green.log` preservam as falhas e os verdes correspondentes.
- 30 testes distintos:10 de aprovação/substituições/política e RCC real,
  3 de conclusão das vozes,2 de CMake,10 do candidato Windows,4 do pacote de
  audição e1 da auditoria de áudio. Os 10 testes novos também passam com `-O`.
  Os 10 de Windows passaram com PowerShell 7.4.6 isolado no Linux, sem skips;
  os testes PowerShell usam fixtures, sem executar o instalador real.
- Negativos: terceira substituição, WAV/decisão/texto/original alterados,
  OGG ausente, uma das 32 alterada/ausente/removida, alteração coerente do seu
  hash e aprovação, RCC/política/proveniência adulterados e conclusão ausente.
  Os erros de conclusão preservam o RCC e Contents previamente publicados.
  O codificador recusa saída existente e symlink pendente antes de escrever.
- Todos 1610 OGG descodificados offline para `fakesink`, sem som: zero falhas.
  [audio-coverage.json](audio-coverage.json) contém hashes e inventário completo.
  A cobertura de referências diretas e do `words.json` exportado do `lang.rcc`
  tem zero faltas; ver [distributed-word-coverage.json](distributed-word-coverage.json).
- `lang.rcc` construído apenas em build próprio, exportado com Qt e comparado
  com o JSON fonte: só os dois rótulos mudaram. Ver [lang-resource.json](lang-resource.json).
- EXE histórico CI 38862699753 lido por 7-Zip 26 isolado e extraído em
  `build/windows-extracted`. Apenas nesta árvore privada foram aplicados o novo
  `lang.rcc` e os recursos de vozes. O verificador de layout passou para 203
  atividades; ver [windows-layout-final.json](windows-layout-final.json) e
  [windows-provenance.json](windows-provenance.json). O EXE conserva o hash
  original. Nenhum binário Windows nem instalador foi executado.

Os comandos terminaram antes da entrega. O retorno observado da codificação foi 0
(chunk `fdbf65`); da conclusão inicial 0 (`394d7f`); da conclusão final e extração 0
(`ad63e0`); do audit/decode e layout 0 (`194bbc`); dos testes finais 0
(chunk `283022`, logs finais). Não se atribui um retorno observado do shell a uma
execução Windows, que não ocorreu.

## Repetir num build privado

Com Qt6Core, `pkg-config`, compilador C++, rcc e GStreamer locais:

```sh
c++ -std=c++17 -fPIC tools/pt-pt-audio/rcc_inventory.cpp \
  $(pkg-config --cflags --libs Qt6Core) -o build/rcc-inventory
python3 tools/pt-pt-audio/complete_voices.py \
  --voices-dir build/legacy-assets/voices-ogg \
  --inventory-tool build/rcc-inventory --rcc-tool /usr/lib/qt6/libexec/rcc
python3 .scratch/pt-pt/legacy-word-application/verify.py \
  --voices-dir build/legacy-assets/voices-ogg \
  --inventory-tool build/rcc-inventory --lang-rcc build/lang-approved.rcc
python3 tools/windows/verify-package.py build/windows-extracted \
  --activities src/activities/activities.txt --output build/package-check.json
```

Preparar `voices-dir` com uma cópia do RCC upstream fixado e do índice Contents;
a conclusão muda só a entrada PT, preservando as demais. Nesta execução a cópia
inicial de Contents era a conclusão anterior de 15 de outubro, não o índice CDN
original. A substituição da linha PT converge para o mesmo índice final.
A compilação de `lang.rcc` usa os mesmos globs e prefixo do CMake de lang, apenas
em build privado. O pipeline Windows existente chama esta conclusão e verifica
a política nova antes e depois de instalar; essa execução real será posterior.

## Limites

A extração e a política física não certificam execução, instalação, som ou
hardware Windows. Não houve nova campanha de jogos nem nova audição docente dos
OGG derivados. As aprovações anteriores das 32 e dos dois WAV têm o âmbito exato
registado; não aprovam outras vozes, o jogo completo ou os dispositivos.
Nenhum build principal, instalador publicado, mapa, CSV global ou release mudou.
