# Reproduzir os quatro jogos de desenho

Requer o binário Qt original, Qt rcc, Node e GStreamer locais. Criar uma cópia
privada e recompilar os cinco RCC antes de iniciar qualquer caso:

```sh
python3 tools/native_qml_resources.py --binary /CAMINHO/bin/gcompris-qt \
  --output build/drawing-staging
python3 tests/functional_drawing/prepare.py --base build/drawing-staging \
  --output build/drawing-snapshot
python3 tests/functional_drawing/run.py --snapshot build/drawing-snapshot \
  --output /NOVO/complete --jobs 4
```

O preparador modifica só a cópia `--base`, que não pode estar em uso, e cria
outro snapshot selado. Nunca passar o build principal como preparação.
O runner executa os dez casos de níveis/configurações e espera por todos os
processos; `.process.json` regista PID, início, fim e saída. `--activity` e
`--mode` permitem filtrar; `--levels`/`--start-level` são pilotos explicitamente
parciais e não certificam o jogo completo.

Os oito casos adicionais de controlos estão preservados como entradas exatas
em `.scratch/pt-pt/functional-drawing/controls/<jogo>-<home|escape>.qml`:

```sh
python3 tools/run-native-qml-case.py --source-root . \
  --resource-snapshot build/drawing-snapshot --activity drawnumbers \
  --qml-file src/activities/number_sequence/NumberSequence.qml \
  --case .scratch/pt-pt/functional-drawing/controls/drawnumbers-home.qml \
  --output /NOVO/controlos --offline --timeout 45 \
  --result-marker NATIVE_DRAWING_RESULT
```

```sh
node tests/functional_drawing/data.mjs --strict-strokes
python3 -m unittest discover -s tests/functional_drawing -p test_cli.py
python3 tests/functional_drawing/audit.py \
  --evidence .scratch/pt-pt/functional-drawing
```

O auditor dos recibos exige todos os níveis/modos, pontos, rejeições, pausas,
Bonus, imagens finais e reprodução das 36 rotas de voz. Com o utilitário Qt
existente `tools/pt-pt-audio/rcc_inventory.cpp`, podem acrescentar-se
`--snapshot /SNAPSHOT --rcc-inventory /UTILITARIO` para conferir os cinco RCC
contra a fonte. A evidência arquivada tem também esse resultado.
O relatório e os limites estão em `.scratch/pt-pt/functional-drawing/README.md`.
