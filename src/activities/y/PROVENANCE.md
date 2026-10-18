# Y provenance

The native QML, rule algorithms and SVG icon were independently authored for
this fork under GPL-3.0-or-later. No CRJM source algorithms, UI, text or artwork
are incorporated.

`board.mjs` is an explicit factual transcription of the mathematical graph:
93 intersection positions, 252 undirected connections and three side memberships.
Its record format and serialisation are new. It records facts verified in the
CRJM board validation, not an import or relicensing of the TypeScript module.
No adjacency is inferred from visual distance. Coordinates retain the reference
drawing's 856 × 847 coordinate system so its irregular topology remains visible.

Primary drawing: `Tabuleiro_Y_regras-2.docx`, image `word/media/image1.png`.
SHA-256 of original DOCX:
`360be143cd44168cb10b7e071130c9e644b107e4cc1e24af5b1ad656f235c7fc`.
Original retained unchanged in the CRJM research collection. The factual graph
was checked against the independently documented transcription and validation:
https://github.com/atilasos/crjm/blob/b206a7b4948673be935a5cb6a5a84df92d3ba6c2/docs/design/y-board-validation.md

Reference platform and authorship: CRJM, atilasos,
https://github.com/atilasos/crjm . The platform's educational-use licence and the
original document's rights remain unchanged. No permission to relicense their
code or artwork is asserted. Exact drawing reuse is not included. Distribution
of the fork remains subject to the project-wide permission review in the spec,
including the provenance and rights of this factual transcription.

Acceptance move transcripts come from paths independently read from the drawing
and recorded in the CRJM rule tests. They are played through the native controls;
no test assigns a position or winner.

The new record format and serialisation in `board.mjs` are offered under
GPL-3.0-or-later, like the other newly authored activity files. This applies to
that original expression and does not assign rights in the mathematical facts,
the reference platform or its drawing. REUSE metadata uses `NONE` for the new
AI-authored material; it does not invent a human copyright holder.
