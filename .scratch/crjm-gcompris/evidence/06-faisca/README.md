# Ticket 06 — native Faísca, two participants

Ancestry confirmed before changes: work/crjm-06 started at integration/crjm-games
b78753319. Test seam is the native Qt menu and original activity controls; no
state replacement, forced winner, mock engine or test-only game interface.

## Red

Before creating the activity, the acceptance case failed because the real menu
could not find Faísca. Evidence: red-result.json, passes 1, failures 1, no QML
errors. This run omitted --extra-activity faisca because that resource did not
exist yet; the menu was compiled from the unchanged activities list.

## Green

Run from the worktree root:

```
python3 tools/run-native-qml-case.py --resource-snapshot /tmp/crjm-native-base --activity menu --from-menu --extra-activity dominorio --extra-activity faisca --qml-file src/activities/menu/Menu.qml --case tests/crjm/faisca.qml --output /tmp/crjm-06-final --offline --timeout 100
```

Result: native Qt, Portuguese, software renderer, Docker network none; two
passes, zero failures, zero QML errors, exit zero. result.json records binary,
case, resources and runner hashes and Docker image ID. The last run follows
qmlformat on the final source. diff --check also passes.

Actions: menu search and real card click; invalid out-of-board endpoint;
editable distance/direction and preview; keyboard confirmation; wrong mandatory
cell; native help opened and closed preserving board and turn; occupied endpoint
rejected; real touchscreen press/release; fixed eleven-move reference game
through the controls; final three-house arrow jumps two occupied intermediate
cells and wins because participant 2 has exhausted distance 1 and cannot use
remaining 2/3; final reserves and visible result; restart; keyboard navigation,
distance/direction selection and confirmation; return to native menu.

Touch uses a single QtTest touch sequence object for press/release. Navigation
waits allow the real menu/help animations to finish before delivering inputs.
No fallback mouse event substitutes for the tested touch action.

Screenshots desktop.png (1100×700) and portrait.png (600×900) were opened and
visually inspected. Board and controls fit and remain legible; cells exceed
40 logical pixels. preview.png, help.png and result.png preserve other visible
checkpoints. These checks do not claim classroom validation with children.

Rules/transcript reference: CRJM Faísca, independently checked runtime transcript
recorded in /tmp/crjm-basic-transcripts.json during exploration. The native code
and help/icon are independently written; PROVENANCE.md records origin and rights.
No external publication or CRJM source relicensing occurred.
