# Ticket 07, Faísca against Tux and guided learning

The worktree started at integration/crjm-games commit 2cc696b97. The implementation
uses the approved acceptance boundary, the real native Qt application opened from
its menu. The integration tip eba039279 was merged before final verification.

## Red and green

The first native run failed because the Tux mode control did not exist. Its log
and result are in red/. A later teaching check found that the generic third hint
could suggest an arrival different from the exercise's requested one. hint-red/
records that failure. Exercise hints now guide the requested move, and review
hints suggest an alternative to the original decision.

Reproduce the final acceptance from the repository root with a verified resource
snapshot created by the existing native runner:

```
python3 tools/run-native-qml-case.py --resource-snapshot /tmp/crjm-native-base --activity menu --from-menu --extra-activity dominorio --extra-activity gatos_caes --extra-activity faisca --extra-activity quelhas --qml-file src/activities/menu/Menu.qml --case tests/crjm/faisca-tux.qml --output /tmp/crjm07-verified --offline --timeout 120
```

The two-person regression uses the same command with --case tests/crjm/faisca.qml
and --output /tmp/crjm07-final-regression. Logs and result manifests live in tux/
and two-people/. They record source/resource hashes and execution environment.

The acceptance selects all three real local policies, checks complete arrows at
the required arrival, completes the labelled exercise with touch and keyboard,
requests three graded hints, plays a full Hard match to a real blocked result,
and reviews an alternative first decision with a comparison of the opponent's
remaining legal choices. Neither the tests nor the exercise assign a winner.
It opens help during a response, checks preserved moves, restarts immediately
after confirmation, leaves during a response and reopens through the menu.
Tab and Space activate mode, difficulty, learning, hints, review, distance,
direction, confirmation and restart. No rules or opponent are substituted.

The two-person regression preserves the independently verified CRJM transcript,
including jumps over occupied intermediate houses and exhausted distance stocks.
All new teaching text and opponent code are independently written for this fork;
PROVENANCE.md records this distinction.

## Responsiveness and visual checks

The worker shares the exact match rules with the UI. It examines at most twelve
candidate arrows, with at most twelve human replies on Hard. Generation tokens
invalidate results on restart, exit and match completion. No search runs on the
UI thread.

The recorded timing JSON contains observed native response times, help latency
and maximum heartbeat gap. The limits inherited from Dominório are response
under 2000 ms, help under 1500 ms and heartbeat under 250 ms. The first response
in the full match intentionally includes help close and a 1000 ms animation wait;
other responses measure confirmation to the observed human turn directly.

Tests ran on Linux 7.0.0-38-generic, x86_64, Intel Core i5-12600K, Qt software
rendering and Docker network none. This is the available host, not a physical
modest device. No GPU, browser runtime, account or network service was needed.
Physical touchscreen operation and classroom validation are not claimed.

Desktop 1100x700 and portrait 600x900 screenshots were opened and inspected.
Board, reserves, directions and mode controls are legible, fit the viewport and
retain cell targets above 40 logical pixels. The review shows the actual first
position and comparison without displaying a match winner. qmlformat and
`git diff --check` pass.

Final results: Tux 2 passes, 0 failures; two-person regression 2 passes,
0 failures. Both have zero QML errors and exit zero. Observed response intervals
were 10 to 58 ms outside the deliberate help round trip, which took 1020 ms
including its 1000 ms wait. Help opened in 4 ms and the longest heartbeat gap
was 71 ms. The review compared 8 legal replies for the original arrow with 7
for the alternative.
