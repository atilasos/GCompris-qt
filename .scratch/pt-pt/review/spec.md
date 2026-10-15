# Spec review — fixed base to 396113909

Reviewed `git diff 1d49ed1b397caca8243bd2b6bbc427a112219bda...396113909` and its commit list, `.scratch/pt-pt/spec.md`, map, issues, validation matrix and supporting implementation/tests. Read-only; no repository or shared-build edits. Ran the grammar, letters and offline-dataset Node suites: 17/17 passed.

## Missing or partial requirements

**[P1] Complete functional validation remains agent-executable work, independently of human approvals.** Spec lines 31–33: “Os dados de todos os níveis têm verificação automática. Cada atividade e modo têm testes interativos. Níveis com comportamentos distintos têm testes próprios.” All 203 Linux and offline matrix entries remain `pending`; 200 rows have no evidence document. The three documents cover partial compass controls and one correct/incorrect grammar response each, with no level completion. The 203 successful offline starts are valuable, but muted six-second starts cannot establish completion, keyboard behavior or all data/mode correctness. Concrete new coverage gaps: `tests/letters_pt_pt.test.mjs` replaces `gletters.initSubLevel` while checking the 13-level list, so it never types a falling accented letter; `tests/offline_datasets.test.mjs:81–100` checks chronology image lists but never submits a correct/incorrect arrangement or completes a level. Add per-mode interaction/completion checks and validate the remaining QML/shared level data, recording actual results. This is an explicitly open requirement, not an accusation that the existing reports falsely claim completion.

**[P2] Windows package verification never enters an activity.** Spec lines 17–18: “O instalador inclui todos os recursos para jogar sem Internet, incluindo num computador que nunca descarregou esses recursos.” Both native invocations in `tools/windows/build-candidate.ps1:71,94` use only `--list-activities`; `verify-package.py:16–23` verifies file presence and external hashes. Even a successful candidate job therefore cannot detect per-activity QML import/image/decoder failures in the deployed tree. Add offline activity startup and representative playable/audio resource checks to the installed-tree probe. This is a fixable verification gap distinct from the legitimate requirement to test on the teacher’s Windows 10 PC. No installer currently exists; the in-flight older candidate is not evidence for the new audio/icons.

## Scope creep

No material scope creep found. Removing foreign words from icons supports the language criterion. Enabling existing offline datasets restores otherwise unavailable activities. Extra Portuguese-character levels address the explicit character/input criterion.

## Implemented behavior appearing wrong

No confidently demonstrated incorrect gameplay or PT-PT selection was found in the inspected changes. One build-maintenance weakness: `.github/workflows/windows-pt-pt-candidate.yml:7–14` omits `resources/pt-pt-voices/**` and `tools/pt-pt-audio/**` from push path filters even though the candidate consumes both. A future audio-only change can leave the candidate stale unless dispatched manually; include these paths. This is not evidence that the currently acknowledged older candidate contains final assets.

## Expected human-gated pending work

Teacher final linguistic/pedagogical and pronunciation approval, actual Windows 10 execution, and school-machine acceptance remain valid pending gates (spec lines 34–43,52–53). Existing audio preservation and actual 1610-file decode evidence are accepted; approved synthesis and explicit accent names are not reopened here. Overall acceptance is still open, accurately reflected in the tracker.
