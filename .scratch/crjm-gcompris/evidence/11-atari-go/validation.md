# Ticket 11 — Atari Go against Tux and guided learning

Approved seam: real Qt menu and activity controls; reference rules inform special
positions, without state injection or substituted AI.

## Reproduce

Run from this checkout with a verified native resource snapshot:

```sh
python3 tools/run-native-qml-case.py \
  --resource-snapshot /tmp/crjm-native-base \
  --activity menu --from-menu \
  --extra-activity dominorio --extra-activity gatos_caes \
  --extra-activity faisca --extra-activity quelhas --extra-activity atari_go \
  --qml-file src/activities/menu/Menu.qml \
  --case tests/crjm/atari-go-tux.qml --output /tmp/atari11-reproduce --offline
```

For the two-person regression, substitute `tests/crjm/atari-go.qml` and a fresh
output directory. The resource snapshot and offline container are prerequisites.

## Evidence

- Red: mode control absent; native assertion failed. `red-result.json` records
  this before the implementation.
- Green: Tux and two-person cases each passed=true, failures0/passes2,
  qml_errors=[], software renderer, Docker network=none. TestCase counts are
  not assertion counts. See the manifests and logs in each directory.
- The real Hard match ends through an actual first capture. Tests choose visible
  empty points, observe rejected suicide, and wait for the real worker. No test
  sets game state, selects an AI answer or declares a winner.
- The learner completes a prepared corner capture, inspects its single liberty,
  requests all three hints, and uses mouse, synthetic touch, arrow keys, Tab and
  Space. After the real match, review restores their actual first corner move;
  a center alternative displays four liberties versus the original two. Review
  has its own completed state and does not declare another match winner.
- Each remaining difficulty produces a legal real worker reply. Restart during
  a request leaves the whole board empty. Leaving during a request and reopening
  through the real menu leaves the board empty, with no late move.
- Help preserves the human placement. The test waits for native StackView close
  and menu transitions before further input. An earlier test attempted to click
  during the menu transition; the final test waits and reacquires its card.
- Measured maximum non-help Tux response74ms, help opening3ms, maximum25ms
  heartbeat gap237ms across the entire run, below pilot ceilings2000/1500/250ms.
  Host: Intel Core i5-12600K,16 logical CPUs. These figures do not validate a
  modest target device. Repeat there before distribution.
- Desktop1100×700 and portrait600×900 screenshots inspected: board, distinct
  stone marks, wrapped instructions, modes and controls remain visible;
  targets exceed36px/40px respectively. Review text is readable and distinct
  from a victory. No physical touch, sound or child usability study is claimed.

The opponent shares native match rules and runs off the UI thread. Hard checks
at most12 candidate actions and81 immediate replies per candidate; stale results
are discarded using generation identifiers. It is a teaching policy, not an
optimal Go solver. All new text/policies are independently authored, with origin
recorded in the activity. No CRJM implementation or artwork was copied.
