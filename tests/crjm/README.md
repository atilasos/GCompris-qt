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

The same runner accepts `tests/crjm/dominorio-tux.qml` for offline Tux acceptance.
It covers all three real local difficulty policies, the didactic exercise, graded
hints, a full Hard match and alternative first-decision review, stale-result
invalidation, responsiveness budgets and both layouts. Evidence and timing
limitations are recorded under `.scratch/crjm-gcompris/evidence/03-dominorio`.

`tests/crjm/dominorio-keyboard.qml` separately checks Tab traversal and Space
activation of every Dominório control, including the post-match review.

## Complete local build and acceptance

Build all activity resources **and the menu** (the menu is excluded from
`all_activities`), using a separate build directory:

```sh
cmake -S . -B build/crjm -G Ninja -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_TESTING=OFF -DBUILD_SERVER=OFF -DSKIP_TRANSLATIONS=ON \
  -DDOWNLOAD_ASSETS=OFF
cmake --build build/crjm --target gcompris-qt all_activities rcc_menu \
  rcc_core rcc_activities rcc_activities_light -j4
```

The new activities contain all their own resources. To retain the rest of the
suite's offline content, copy `share/gcompris-qt/rcc/data3`,
`share/gcompris-qt/translations` and `lib/qml` from an independently verified
existing offline snapshot into the new build prefix. Do not replace the freshly
built RCC files. This integration used `/tmp/crjm-native-base`; its manifest and
the complete resulting manifest are recorded in ticket 18's evidence. The local
Qt libraries remain system dependencies; this is not a portable Linux installer.

Create an independent snapshot with `tools/native_qml_resources.py --binary
build/crjm/bin/gcompris-qt --output /absolute/new/snapshot`. Then run the complete
matrix serially:

```sh
python3 tools/run-crjm-acceptance.py \
  --resource-snapshot /absolute/new/snapshot \
  --output /tmp/crjm-complete-acceptance \
  --offline-cpus 1 --offline-memory-mib 512
```

This runs both native cases for all eight games, the Dominório keyboard case
and an existing Quatro-em-linha regression. Only the menu and PT catalogue are
instrumented. **No `--extra-activity` is used:** rules, ES workers, icons and
activity catalogue come from the real CMake RCC files. Every case has its own
profile and Docker network `none`. The optional limits are enforced by Docker;
`result.json` records both the requested values and the actual cgroup v2
`cpu.max` / `memory.max`, peak memory and OOM event values. Omitting both options preserves the runner's
previous unlimited behavior. A CPU quota is a virtual stress profile, not a
measurement on a physical school computer or tablet.

The complete local artifact from this delivery is
`/home/proteu/Projetos/GCompris-qt/build/crjm-complete`. Open it on this Linux
machine with:

```sh
/home/proteu/Projetos/GCompris-qt/build/crjm-complete/run-crjm.sh
```

Its launcher chooses PT-PT, a window and software rendering. It uses the bundled
resources and system Qt 6. This private build has not been published.

The complete-match stress case exposed temporary allocation growth in the
Gatos & Cães opponent: the original neighbor predicate allocated an array and
closure for each candidate, and Qt's worker heap exceeded even a 1 GiB limit.
The equivalent four-neighbor predicate now avoids these allocations. The same
full native case then passed at 512 MiB with a 193 MiB memory peak and no OOM
events. The failed runs and the isolated red/green evidence remain in ticket 18.
A virtual quota is not a minimum RAM specification for physical school devices.
