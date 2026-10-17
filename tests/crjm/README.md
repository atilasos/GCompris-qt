# Native CRJM activity acceptance

Run from the checkout containing the new activity:

```sh
python3 tools/run-native-qml-case.py \
  --binary /home/proteu/Projetos/GCompris-qt/build/pt-pt/bin/gcompris-qt \
  --activity menu --from-menu --extra-activity dominorio \
  --qml-file src/activities/menu/Menu.qml \
  --case tests/crjm/dominorio.qml \
  --output /tmp/dominorio-native-acceptance --offline
```

Use a fresh output directory. The runner compiles source resources into a
private runtime, leaving the installed build untouched. `--from-menu` omits
`--launch`; `--extra-activity` compiles additional activity resources and the
menu catalogue. Native QtTest is injected into the menu, so the test can search
and click the actual activity card before using the activity controls.

The acceptance boundary is the running Qt application. Dominório covers actual
menu search, selection preview, legal placement and turn changes, occupied and
out-of-bounds rejection, help without loss of position, a complete CRJM legal
transcript ending in player 2's victory, restart, keyboard navigation, synthetic
touch input, portrait/desktop layouts and return to menu. Assertions read visible
labels and control states. No rule functions or board state are replaced.

`result.json` records hashes, renderer, network isolation, Qt errors and outcomes;
PNG files provide visual evidence. Software rendering needs no GPU. Synthetic
QtTest touch is not a physical touchscreen check. Muted tests do not validate
sound or pedagogical suitability with children.
