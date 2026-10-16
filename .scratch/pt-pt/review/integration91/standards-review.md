# Standards91

Base: `e4444354e`
Head: `4626a8d860dfd584341f569d3bdb1130b2c2fae1`
Diff: `git diff e4444354e...4626a8d860dfd584341f569d3bdb1130b2c2fae1`

**Hard violations: 0. Judgement findings: 0.**

Read the fixed diff, `tools/windows/{assets-lock.json,verify-package.py}`, the new regression source, task91 and its evidence README against the applicable `AGENTS.md`, `HACKING`, `README.md`, `docs/agents/` rules and Fowler baseline. No Windows execution, Qt build, test rerun or repository modification was performed.

`approved_completion_files` isolates the new policy decision with an explicit name and narrow purpose. It matches every existing common invariant and provenance declaration, excluding only the historical single `files` pair from that comparison; it then requires exact equality with one complete externally pinned pair. It returns the selected pinned files and original pinned provenance for the existing physical size/hash checks. It does not approve individually known but mixed components or accept a completion-generated replacement hash.

The two literal variants in the lock are an appropriate representation of the two observed container identities. Repeating the historical Linux identity in this explicit allowlist is not actionable duplication: the original policy remains a historical invariant while the new list records the complete accepted alternatives. No speculative serializer or broad platform abstraction was added.

The regression source builds two real containers with identical resource inventories and distinct container bytes, then checks allowlisting, mixed pairs, physical corruption, coherent resealing and altered invariants. Its fixture markers are explicitly synthetic rather than voice recordings. Tests inspect the relevant corruption result without misrepresenting the deliberately incomplete fixture stage as a complete Windows runtime.

Material limit: this change alone does not independently inspect the actual Windows RCC bytes or complete task91's Windows CI, installer-hash and HTTPS acceptance. The README explicitly records that the Windows pair currently comes from the prior CI completion and that the next CI must physically verify it. A third observed container remains rejected until investigation and explicit policy update. These are candid pending validation boundaries, not a Standards defect.
