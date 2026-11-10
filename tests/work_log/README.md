<!-- SPDX-FileCopyrightText: NONE -->
<!-- SPDX-License-Identifier: CC0-1.0 -->
# Native session work log acceptance

`session.qml` exercises the real menu cards, Enumerate keyboard input, Bonus,
help/configuration dialogs and the session view. It counts rendered fruit images
and submits the answers; no game state or function is replaced. It checks the
round before the delayed Bonus win, a CRJM entry without rounds, reopening,
confirmation/cancellation, clearing, shortcuts and the menu Tab cycle with
visible/hidden sections. It also checks a fresh process starts empty.

Build the binary and **all** resources before making a new independent snapshot.
Adding a QML file requires CMake configuration again because its RCC glob is
resolved at configuration time:

```sh
cmake -S . -B build/pt-pt
nice cmake --build build/pt-pt --parallel 4
LC_ALL=en_US.UTF-8 QT_QPA_PLATFORM=offscreen ctest --test-dir build/pt-pt --output-on-failure
python3 tools/native_qml_resources.py --binary build/pt-pt/bin/gcompris-qt --output /tmp/work-log-snapshot
python3 tools/run-native-qml-case.py --resource-snapshot /tmp/work-log-snapshot \
  --activity menu --from-menu --qml-file src/activities/menu/Menu.qml \
  --case tests/work_log/session.qml --output /tmp/work-log-session --offline
python3 tools/run-native-qml-case.py --resource-snapshot /tmp/work-log-snapshot \
  --activity menu --from-menu --qml-file src/activities/menu/Menu.qml \
  --case tests/work_log/session.qml --output /tmp/work-log-scale --offline \
  --screen-size 2048x1152
```

Use new output/snapshot directories each time. No `--extra-activity` is needed:
Enumerate and Dominório come from the CMake RCCs in the snapshot. The large-screen
run checks `fontRatio=2.4`, maximum user text size, wrapping, button/list bounds
and keyboard scrolling at 2048×1100, 1280×800, 800×600, 600×900 and 600×480.
Screenshots are native Qt captures. Both runs use isolated XDG profiles and Docker
network `none`. See `tests/crjm/README.md` and the runner for prerequisites.

Run `tests/menu/particles.qml` and `tests/crjm/dominorio.qml` with the same command
and snapshot, changing `--case` and using new output directories. Evidence,
resource hashes and limitations are in
`.scratch/melhorias-2026-11/evidence/wp4-work-log.md`.
