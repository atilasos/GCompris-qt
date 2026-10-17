# Produto: native acceptance

Green command, executed from the ticket worktree:

```sh
python3 tools/run-native-qml-case.py --resource-snapshot /tmp/crjm-native-base --activity menu --from-menu --extra-activity dominorio --extra-activity gatos_caes --extra-activity faisca --extra-activity quelhas --extra-activity produto --qml-file src/activities/menu/Menu.qml --case tests/crjm/produto.qml --output /tmp/produto-green-12d --offline --timeout 100
```

Result: 2 passes, 0 failures, no QML errors. Native Qt 6.10 software renderer, isolated network namespace, immutable baseline snapshot. Full hashes, source/test/runtime hashes and environment are in result.json. The shared installed build was not changed.

Red: the same menu acceptance before the activity existed failed because Produto could not be discovered. red-result.json records that failure. Subsequent failures while building the test identified the host help overlay's exit transition: the acceptance waits for that transition before mouse controls, rather than bypassing it.

Assertions cover real menu discovery, white opening, partial and complete turns, cancellation and correction, occupied rejection, visible scores, merge reducing product to zero, help preserving selections, all button Tab/Space paths, keyboard board selection and Enter, touch, a full legal 61-placement transcript, terminal immutability, restart and return to menu. No game state or rules were replaced/injected.

Full transcript fills axial q-then-r order, first 30 black and remaining 31 white, within the official 45-piece-per-colour material. Each colour is one connected group, both products are zero, so participant 1 wins with fewer own pieces. Reference calculations were checked independently against CRJM before implementation. Smaller group examples use ordinary placements too.

Desktop and portrait screenshots were visually inspected. The board and controls stay within the page, with selectable cell widths at least 36px and 40px respectively. The native test starts muted and uses synthetic touch, so neither physical touchscreen interaction nor audio/pedagogical suitability with children is claimed. No CRJM TypeScript code, artwork or exercises were copied.
