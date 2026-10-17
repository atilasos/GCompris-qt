# Ticket 03: native acceptance evidence

Date: 2026-10-17. Integration base: 0b480a0b6. The branch was checked with
`git merge-base --is-ancestor integration/crjm-games HEAD` before edits.

The confirmed seam is the native Qt application starting at the actual menu.
The CRJM rule reference is used by the unchanged two-person transcript test;
Tux acceptance supplies native input and observes pieces, labels and navigation.
No AI, rules, board state or winner is replaced by the test.

## Commands

Run from the worktree, using a new output path for each invocation:

```sh
python3 tools/run-native-qml-case.py \
  --binary /home/proteu/Projetos/GCompris-qt/build/pt-pt/bin/gcompris-qt \
  --resource-snapshot /tmp/crjm-native-base \
  --activity menu --from-menu --extra-activity dominorio \
  --qml-file src/activities/menu/Menu.qml \
  --case tests/crjm/dominorio-tux.qml \
  --output /tmp/dominorio03-verified0 --offline
```

Two-person regression: same command, with case `tests/crjm/dominorio.qml` and
output `/tmp/dominorio03-verified1`.

Red: same native runner against the integration checkout source root, before
this ticket's feature, using the corrected Tux test's initial mode assertion.
Output `/tmp/dominorio03-valid-red`. The card was found by its title, activity
opened, then `Tux mode selectable` failed. An earlier exploratory red clicked
the wrong search result; that run is explicitly not relied on as TDD evidence.
Fuller behavioral assertions were then added incrementally. Native runs caught
and corrected an unsupported WorkerScript `.import`, a test Timer scoping error,
and the need to wait for StackView's help-close transition before clicking again.

## Results

- `red`: one expected assertion failure, no QML errors.
- `tux`: 2 passes, 0 failures, no QML errors; real menu, every difficulty answers,
  explicit introduction and prepared exercise, three hint levels, full Hard match,
  legal complete horizontal responses, natural result, alternative decision review,
  no invented review victory, help, restart/exit invalidation and layout checks.
- `two-people`: 2 passes, 0 failures, no QML errors; original complete CRJM transcript,
  illegal moves, native help, keyboard, synthetic touch, menu and layout regression.
- Software rendering, no GPU or browser, Docker network `none`, Portuguese locale,
  immutable independent runtime snapshot; each result records resource hashes.

## Measured pilot budgets and limits

Host: Intel Core i5-12600K, 10 cores/16 threads, 46 GiB RAM, Linux x86_64,
Qt 6.10.2; offscreen software renderer in network-isolated Docker. This is a
powerful desktop, **not a modest device**. No physical modest/tablet device is
available in this environment. Physical touch and testing with children remain
unverified. No claim of a modest-device measurement is made.

Hard full-match samples excluding the first help-dialog interaction: 10 samples,
maximum 108ms, nearest-rank p95 108ms. These end-to-end observations include up to
50ms QtTest polling and are not pure engine time. First sample 595ms includes
opening/closing help and the StackView transition. Help opened in 3ms; a 10ms
heartbeat during the match had a largest observed gap of 23ms. Raw data is in
`timing.json` and `tux/native.log`.

Repeatable acceptance budgets for subsequent native game deliveries on this
host: a legal complete local opponent response within 2000ms, UI heartbeat gap
below 250ms during calculation, help opening within 1500ms, no stale response
after restart or leaving. These are pilot ceilings, not a hardware performance
guarantee. Before distribution, repeat on an available modest target and record
its actual hardware and results; do not equate CPU throttling with that device.

The worker evaluates at most 56 candidate moves and 56 replies each. Generation
identifiers invalidate returned results on restart, mode/difficulty changes,
lesson changes and stop; the bounded stale worker job can finish privately.
