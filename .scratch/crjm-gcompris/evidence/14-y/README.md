# Ticket 14 validation

Run from the ticket worktree. Confirmed base: integration/crjm-games commit
f3739f4cb. TDD native red first: activity absent, 1 failure and 1 pass, no QML
errors. Green through the same menu and real native controls: 0 failures,
2 passes, no QML errors, docker-none network and Qt software renderer.

```sh
python3 tools/run-native-qml-case.py \
  --binary /tmp/crjm-native-base/bin/gcompris-qt \
  --activity menu --from-menu \
  --extra-activity dominorio --extra-activity gatos_caes \
  --extra-activity faisca --extra-activity quelhas \
  --extra-activity atari_go --extra-activity produto --extra-activity y \
  --qml-file src/activities/menu/Menu.qml --case tests/crjm/y.qml \
  --output /tmp/crjm-14-keyboard --offline
```

The red invocation omitted `--extra-activity y`, before Y implementation. The
initial assertion checked native menu discovery. Follow-up failures exposed an
invalid QML separator and a help assertion aimed at the wrong page. Both fixed;
final run above covers the entire control path.

Native transcripts cover blue and red winners with and without swap, all played
from the empty board. The E2/E3 missing connection is checked through a full
legal sequence that only wins when D3 joins the groups. Disconnected boundary
groups do not win. No fixture or test-only state/winner setter is present.
Every node can be reached with arrows; Space places through production logic
and reveals the cursor in the scroll viewport. Touch and mouse activate native
nodes; Tab reaches swap, restart, zoom and help; swap, restart and help are activated with Space.
The test confirms restart resets the board by replaying transcripts from A1.

The final desktop capture at 1100×1050 was inspected: all 93 nodes and three
marked sides are visible, controls below the board, no overlaps. Portrait
600×900 captures were inspected at top and bottom; the graph scrolls rather
than shrinking touch targets below 44 px. Pointer drag is tested without any
accidental placement. These are synthetic events, not a physical tablet check.
No claim of pedagogical validation with children is made.

Primary DOCX SHA-256 verified locally:
360be143cd44168cb10b7e071130c9e644b107e4cc1e24af5b1ad656f235c7fc.
The extracted original image was inspected alongside native rendering. Factual
audit of board records found 93 nodes,252 edges,9 nodes per side and degree
counts3:3,4:21,5:3,6:66, matching the independent documented validation. Graph
records and provenance are separate from original GPL rule code.

`result.json` retains source, case, binary and resource hashes, timestamps,
network isolation, Qt output and screenshot digests. `red-result.json` and
`red-native.log` preserve the initial failing acceptance.

After merging integration tip e26db408e, menu discovery and every transcript
passed again. Final run also verifies restart via Tab/Space. The last integration
merge incorporates later tracker claims and Atari Go teaching changes. It leaves
the tested Y activity, menu and native runner sources unchanged.
