# Public level contract: static candidates

Scope: repository source only, no Qt execution, no production edits, no build/proof/CSV changes. This report is a hypothesis inventory, not a defect verdict. Paths and lines reflect the working tree at inspection time. Root agent supplied prior native reproductions for ballcatch and penalty; they are anchors, excluded from new-candidate counts.

## Shared contract and risk

`src/core/ActivityBase.qml:124` initializes public `numberOfLevel` to 0. `:241` uses it to decide whether a sequence advances to the next activity. `currentLevel` is zero based. An internal selector can navigate correctly using a JS private count while the public count remains zero. Merely seeing a bar value is insufficient: its `content` must include `level`.

A literal initialized QML property plus `onNumberOfLevelChanged` is suspicious because no later assignment forces a notification; native lifecycle testing is required. Strong static confidence below means the missing publication path is directly visible, not that runtime failure was reproduced.

## Priority A: private totals without initial public publication

| Activity / mode | Public declaration | Operational total and start | Selector | Static confidence |
| --- | --- | --- | --- | --- |
| leftright | `src/activities/leftright/Leftright.qml:38` is 0; handler :39 | `leftright.js:15` defines 6 entries; :63-66 starts with `levels.length`; :94/:100 navigate by that count; no assignment to items/public total found | `Leftright.qml:208` contains level | High |
| superbrain | `src/activities/superbrain/Superbrain.qml:61` is 0; handler :62 | `superbrain.js:15` sets maxLevel=8; :63-67 starts from it; :195/:202 navigate by it; no publication found | `Superbrain.qml:606` contains level | High |
| traffic | `src/activities/traffic/Traffic.qml:50` is 0; handler :51 | `traffic.js:172` sets maxLevel=13; :185-190 starts from it; :380/:387 navigate by it; no publication found | `Traffic.qml:190` contains level | High |
| polygons, tutorial only | No items/public total declaration or assignment found in wrapper/JS; inherits public 0 | `polygons.js:22` sets private total from `items.tutorialDataset.tutorialLevels.length`; :24 uses it; :66/:71 navigate by it | `Polygons.qml:415` includes level only if isTutorialMode; :45 defines tutorial mode | High for tutorial, excluded free mode |

## Priority B: literal total plus change handler, no explicit startup synchronization

Each wrapper below declares a positive `items.numberOfLevel`, has only its change handler copying into `activity.numberOfLevel`, and exposes a bar bound to `items.currentLevel + 1`. Its local JS does not assign `items.numberOfLevel` on startup or later. For melody/renewable_energy the initial-level logic is inside QML. All remain native-test candidates; none is declared defective by this inspection.

| Activity | Internal total | Declaration (handler immediately follows) | Bar level line | onStart lines | Confidence |
| --- | ---: | --- | ---: | --- | --- |
| submarine | 10 | `src/activities/submarine/Submarine.qml:115` | 1002 | 24,211 | Medium-high |
| melody | 10 | `src/activities/melody/Melody.qml:55` | 232 | 22,61 | Medium-high |
| left_right_click | 3 | `src/activities/left_right_click/Left_right_click.qml:46` | 214 | 18,61 | Medium-high |
| railroad | 10 | `src/activities/railroad/Railroad.qml:52` | 612 | 22,76 | Medium-high |
| renewable_energy | 3 | `src/activities/renewable_energy/RenewableEnergy.qml:56` | 724 | 21,73 | Medium-high |
| football | 8 | `src/activities/football/Football.qml:56` | 230 | 24,63 | Medium-high |
| checkers | 5 | `src/activities/checkers/Checkers.qml:52` | 504 | 26,78 | Medium-high |
| tic_tac_toe | 5 | `src/activities/tic_tac_toe/TicTacToe.qml:66` | 248 | 23,71 | Medium-high |
| mining | 3 | `src/activities/mining/Mining.qml:49` | 556 | 21,59 | Medium-high |
| fifteen | 14 | `src/activities/fifteen/Fifteen.qml:65` | 403 | 23,97 | Medium-high |
| braille_fun | 3 | `src/activities/braille_fun/BrailleFun.qml:58` | 240 | 23,69 | Medium-high |
| play_piano | 10 | `src/activities/play_piano/PlayPiano.qml:96` | 308 | 21,109 | Medium-high |
| followline | 8 | `src/activities/followline/Followline.qml:57` | 141 | 23,69 | Medium-high |
| piano_composition | 7 | `src/activities/piano_composition/Piano_composition.qml:101` | 476 | 26,113 | Medium-high |
| drawing_wheels | 2 | `src/activities/drawing_wheels/DrawingWheels.qml:55` | 1445 | 25,111 | Medium-high |
| bargame | 4 | `src/activities/bargame/Bargame.qml:53` | 405 | 22,69 | Medium-high |
| hexagon | 12 | `src/activities/hexagon/Hexagon.qml:48` | 131 | 23,57 | Medium-high |
| color_mix | 6 | `src/activities/color_mix/ColorMix.qml:56` | 289 | 24,71 | Medium-high |

Modes and shared wrappers:

- `src/activities/color_mix_light/ColorMixLight.qml:13` inherits ColorMix, so validate both color_mix and color_mix_light.
- `src/activities/bargame_2players/Bargame2players.qml:13` inherits Bargame and keeps its selector; validate both game modes.
- `checkers_2players` and `tic_tac_toe_2players` inherit counts, but their wrapper bar hides level selection (`Checkers.qml:505`, `TicTacToe.qml:249`). Excluded from the requested selector inventory; no claim about their broader sequencing contract.

## Eliminated false positives

- maze: `src/activities/maze/Maze.qml:78` explicitly copies `items.numberOfLevel` into the public activity in onStart; mazeinvisible and mazerelative inherit it.
- solar_system: starts with 0, but `src/activities/solar_system/SolarSystem.qml:401` assigns 1/2 during dialog onLoadData, invoking its synchronization handler. Not categorized as missing publication without lifecycle evidence.
- oware: `src/activities/oware/Oware.qml:444` binds a cosmetic bar level, but :445 contains help/home/reload only, so no selector.
- template: developer scaffold, not an enabled activity; excluded.
- Dynamic dataset wrappers that set `items.numberOfLevel` from a loaded dataset were not counted merely because they initialize to 0.
- ballcatch/penalty: prior reproduced anchors supplied by root, not new candidates here.

## Native reproduction protocol (future, no run performed here)

1. Use the existing native Qt activity harness/build without changing production. Start a fresh activity instance under the normal lifecycle; do not assign the total from the harness. Record wrapper name, mode/config, dataset, active level and startup completion.
2. Once settled, inspect `ActivityBase.numberOfLevel`, internal `items.numberOfLevel` if present, and the operational JS total/loaded dataset length. Capture `Bar.content` to establish selector visibility. A public zero alone is not evidence for activities that intentionally have no levels.
3. For Priority A, expect operational totals 6, 8, 13 and tutorial dataset length respectively. For Priority B, compare against the literal table value. Confirm the public total matches on first entry and after exit/reentry/config change.
4. Use real next/previous selector actions, including wrap at the final level, and record active currentLevel after each. Complete a first-level sequence event and check it stays in the activity while more levels remain. Distinguish direct selector handlers calling JS from ActivityBase sequence handlers.
5. For polygons select tutorial mode before asserting a finite total; free drawing is excluded. For shared wrappers repeat the inherited modes named above. Do not turn a static candidate into a tracked defect until the normal native lifecycle reproduces the mismatch and its effect.

Coverage: patterns selected by change-handler/literal-or-zero and bar-selector inspection, plus private-total wrappers. Not a formal exhaustive proof for all dynamic or inherited QML initialization mechanisms.
