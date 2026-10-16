# Standards44 — recheck

Base: `45662f54da4b54b54dec1027decaf6d5d7eee02e`
Head: `a9365de35641a6bf3a21385b35233d134c879b7d`
Diff: `git diff 45662f54da4b54b54dec1027decaf6d5d7eee02e...a9365de35641a6bf3a21385b35233d134c879b7d`

**Hard violations: 0. Judgement findings: 0.**

Reviewed against `AGENTS.md`, `HACKING`, `README.md`, `docs/agents/` and the Fowler smell baseline, with the original Standards/Spec reports and the new `legacy-word-application-review/README.md` supplement. No repository edits, Qt execution, builds or test reruns were performed.

The previous P2 preparation defect is addressed: when substitutions exist, NOTICE is unconditionally included in the provenance staging map. A missing NOTICE therefore fails while copying into the temporary directory, before the publication loop. The copied provenance is hash-checked, its sizes/hashes are computed from staged files, and completion metadata is prepared and read back before the first destination replacement. The added regression sources cover missing NOTICE, partial copy failure, silently corrupt copy and metadata write failure, comparing the complete destination byte snapshot. These tests are materially different failure boundaries rather than duplicate implementation assertions.

`Contents` and `completion.json` use explicit UTF-8 byte writes; the encoder fixes LF explicitly. Four narrowly scoped `.gitattributes` entries preserve raw-byte-pinned inputs without a broad normalization policy. The Windows translation adapter and real Git checkout regression target the previously identified byte-determinism risks. No new actionable smell was identified in these changes.

Limits: staging before publication does **not** make the sequence of `Path.replace()` operations a multi-file transaction. An interruption or destination error during that loop can leave a partial update; publishing Contents last does not eliminate that possibility. The supplement confines its preservation claim to preparation failures, which matches the implementation and tested boundaries. This review does not certify Windows execution, installation, playback or human hearing, and does not reinterpret the existing audio approvals.
