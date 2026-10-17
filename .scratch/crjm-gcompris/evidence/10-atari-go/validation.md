# Ticket 10 — native Atari Go acceptance

Seam approved by the user: actual Qt menu → complete native activity, with
CRJM rules used only for reference positions. No state injection or mocked rules.

## Reproduce

Run from this checkout:

```sh
python3 tools/run-native-qml-case.py \
  --resource-snapshot /tmp/crjm-native-base \
  --activity menu --from-menu \
  --extra-activity dominorio --extra-activity gatos_caes \
  --extra-activity faisca --extra-activity quelhas --extra-activity atari_go \
  --qml-file src/activities/menu/Menu.qml \
  --case tests/crjm/atari-go.qml --output /tmp/atari-validation-new --offline
```

A verified independent resource snapshot (or `--binary` pointing to a native
GCompris build) and the runner's installed offline container are prerequisites.
The tracked JSON captures hashes and environment details.

## Results

- Red before activity implementation: search could not find Atari Go; one native
  assertion failed. See red-result.json (run deliberately omits nonexistent Atari resource).
- Final: passed=true, failures=0, passes=2, qml_errors=[], software rendering,
  Docker network=none. TestCase pass count is not the number of assertions.
- The real UI replays three independently CRJM-verified histories: first capture
  in three moves; rejected suicide preserving turn; capture allowed with no
  immediately empty neighbour. Extra literal histories cover two-stone capture
  and White winning. The L-shaped three-stone group has seven distinct liberties,
  including one empty point shared by two group members.
- Actual mouse, synthetic touch and keyboard events exercised. Occupied moves,
  post-result placement, restart, help preserving position, Tab and Space on both
  controls, and return to menu checked. Native help close animation is allowed
  to finish before further board actions.
- Desktop (1100×700), portrait (600×900), group overlay and capture screenshots
  inspected: intersection alignment, readable text, group outlines and liberty
  markers, controls and targets remain visible. Desktop targets exceed36px;
  portrait targets exceed40px.

No physical touchscreen or child usability assessment is claimed. Tux and
learning exercises are intentionally left for ticket11. No CRJM source/assets
were imported; ORIGIN.md records independent authorship and rules reference.
