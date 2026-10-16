# Reprodução nativa do primeiro rato/peixes

Requer o binário Qt original, rcc Qt6, Node, Pillow e GStreamer disponíveis
localmente. Não usa a build principal como diretório de saída.

Criar primeiro uma cópia transitiva independente:

```sh
python3 tools/native_qml_resources.py --binary /CAMINHO/bin/gcompris-qt \
  --output build/mouse-fish-staging
python3 tests/functional_mouse_fish/prepare.py \
  --base build/mouse-fish-staging --output build/mouse-fish-snapshot
```

`--base` é uma cópia privada de preparação: os seus quatro RCC são
recompilados a partir da fonte antes de criar o snapshot de saída selado.
Não passar um diretório de build partilhado nem um snapshot em uso.

```sh
python3 tools/run-native-qml-case.py --source-root . \
  --resource-snapshot build/mouse-fish-snapshot --activity clickgame \
  --qml-file src/activities/clickgame/Clickgame.qml \
  --case tests/functional_mouse_fish/fish_gameplay.qml \
  --output /NOVO/resultado --offline --timeout 180 \
  --result-marker NATIVE_MOUSE_FISH_RESULT
```

Os outros casos são fish_levels.qml (30s), duck_free.qml (40s),
duck_boundaries.qml (45s) e controls.qml (35s). Nos casos do pato,
selecionar `--activity baby_mouse` e
`--qml-file src/activities/baby_mouse/Baby_mouse.qml`.
Para a saída por Escape, o mesmo caso controls aceita useEscape=true;
as duas cópias exatas executadas estão preservadas na pasta de evidência.

```sh
python3 tests/functional_mouse_fish/audit.py \
  --evidence .scratch/pt-pt/functional-mouse-fish
```

Os casos usam eventos reais, não preparam vitórias nem imobilizam alvos.
O auditor lê os dados completos independentemente das regras de pontuação,
confere os recursos copiados pelo Qt e não confunde descodificação com
reprodução SoundEffect. O limite sonoro e os resultados completos estão em
`.scratch/pt-pt/functional-mouse-fish/README.md`.
