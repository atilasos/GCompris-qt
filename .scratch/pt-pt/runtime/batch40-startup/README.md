# Arranque após as correções 34, 37, 38 e 40

Onze atividades arrancaram em pt_PT, seis segundos cada, com perfis novos e
Docker sem rede. Não houve erro QML detetado. `results.json`, `run.json` e os
logs conservam os resultados e os hashes de fonte/build/runner/configuração.

Antes do teste foram reconstruídos rcc_peg_solitaire, rcc_hangman,
rcc_letter-in-word, rcc_scalesboard e BuildTranslationsgcompris_qt. O binário
principal não estava em execução quando os recursos foram reconstruídos;
os restantes ensaios usavam cópias privadas.

Comando:

```sh
python3 tools/smoke-activity.py --binary build/pt-pt/bin/gcompris-qt \
  --output .scratch/pt-pt/runtime/batch40-startup --source-root . \
  --seconds 6 --offline peg_solitaire hangman letter-in-word scalesboard \
  scalesboard_weight scalesboard_weight_avoirdupois memory memory-tux \
  memory-sound memory-sound-tux memory-case-association-tux
```

Esta é uma verificação de arranque; não conclui níveis, revisão linguística ou
aceitação Windows. Corresponde às fontes de a9ee02c23, antes da correção do
contador do Hangman descoberta durante a campanha da tarefa38.
