# Observed polygon geometry

Pure Python, with `tests` on `PYTHONPATH`. The only dependency is the independent
`polygon_geometry_oracle` package in the same directory. No Qt, Git, authored
activity dataset, game validation logic or image library is loaded.

`validate_tutorial(case_result, screenshots=None)` requires nine complete native
case-result routes. It projects scene centers onto the actual visible ten by ten
grid, checks creation steps and boundary order up to cyclic shift/reversal,
classifies the resulting integer geometry from the public Portuguese instruction,
and checks rejection, clearing, repair, natural Bonus and continuation. Correct
alternative candidates are permitted, including inclusive geometric classes.
Collinear or self-intersecting rejected candidates are not treated as polygons.

`validate_controls(case_result, screenshots=None)` requires the complete finite
controls/free case: nine geometric examples, navigation and reload, help, offered
mode change, editing by mouse and keyboard, keyboard creation and stable menu.
All free states must have zero public levels, no tutorial OK and no Bonus.
It does not claim to exhaust the infinitely many free drawings.

Both functions return a summary or raise `ValueError` for failed checks. Missing
JSON fields retain `KeyError`, marking a malformed receipt. They do not open the
capsule or certify runtime process identity; the physical evidence reader does so.
The optional `screenshots` argument is a pure `check_snapshot(state) -> True`
callback supplied by that reader. It is called for every checked drawing state.
Without that callback, the result explicitly reports that screenshot pixels were
not checked. Scene metadata geometry is not represented as a pixel proof.

`observed_vertices` and `validate_drawing` expose the projection/trace seam for
small diagnostics. A partial pilot is never accepted as nine tutorial routes.
The fixed projection tolerance is 0.001 lattice unit; all geometric calculations
thereafter use exact integers. Vertex order is never replaced by sorted IDs.

Run `PYTHONPATH=tests python3 -m unittest discover -s tests/polygon_observation_audit`
and the same command with `python3 -O`. Checks do not depend on Python assertions.
`proof/` retains five red/green slices and final tests. The extra callback test's
initial expectation of more than 90 observations was corrected to the worked
fixture total of 88; this was a test expectation error, not a native/product defect.
The synthetic fixtures test the validator and do not represent actual gameplay.
