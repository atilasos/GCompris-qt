# Opaque rectangular painting pieces

Pure pixel inference for a complete regular grid of two to eight unrotated,
fully opaque rectangular images. This module does not load level definitions,
answer IDs, authored coordinates, game verdicts, reference paintings or progress.

The public interface is:

```python
# Add the frozen source's tests directory to sys.path.
from painting_rectangular_solver import solve_observed
result = solve_observed(images_by_source, board, calibration,
                        max_permutations=40320)
```

`board` contains the public `level`, `frame`, `pages` of exposed source labels,
and `drawnCircles`. `calibration` contains the same level/frame and a neutral
`placed` record with source/width/height only. Its destination is unused.
`images_by_source` maps opaque labels to Pillow images. These labels are never
parsed, sorted for semantics, or treated as positions. The alternative
`solve(images_by_id, slots, canvas_size, max_permutations=40320)` accepts those
same observed centres already expressed in native image pixels. The mapping
returns indices in the supplied visible slot list, including when it is shuffled.

The geometry must form a complete regular grid, match the rectangular image
sizes (two-pixel size variation tolerated), and fit the public canvas. Images
must be at least 16 pixels in both dimensions and entirely opaque. Unsupported
inputs raise UnsupportedPuzzle. Above the caller's factorial arrangement budget,
SearchLimit refuses before search. The hard limit is eight pieces/40320
permutations, each evaluated at three strip widths.

For each visible horizontal/vertical adjacency, compare mean RGB values in
2-, 4- and 8-pixel edge strips. Enumerate every permutation and sum mean squared
seam differences. All three unique minima must agree; ties or disagreement
raise AmbiguousPuzzle. This is evidence under an explicit metric, not a general
proof of the intended painting. Dark frames can defeat a single-pixel seam;
the literal two-piece RGB fixture demonstrates that tie before the wider-strip
rule. A second literal fixture forces disagreement and must be refused.

## Portable Bazille observation

```sh
python3 tests/painting_rectangular_solver/probe.py
python3 -O tests/painting_rectangular_solver/probe.py
python3 -m unittest discover -s tests/painting_rectangular_solver -p 'test_*.py'
python3 -O -m unittest discover -s tests/painting_rectangular_solver -p 'test_*.py'
```

The fixture preserves six original WEBP byte streams and only public geometry
extracted from the task 88 inventory/calibration. Its immutable manifest
3982bdad81ae83e732746ed58159774c451f1d212ab323a38b19221766598414 binds
those bytes and records the parent receipt hashes. Source labels locate the
physical files; no frozen answer mapping is stored. The probe checks that
manifest and each file, recomputes the candidate, and reports current module
hashes/parameters. A copied directory can run without the original worktree;
resealed input or manifest tampering is rejected, including under Python -O.
Historical upstream-source and native proof identity remain the parent auditor's
responsibility: this module does not claim a future source file is unchanged
merely by printing its current hash.

The six-piece observation evaluates 720 permutations per strip across all seven
visible grid adjacencies. All three minima agree. Costs / runner-up costs:
2 pixels: 8665.7985 / 13027.8797; 4 pixels: 8199.1950 / 16137.8711;
8 pixels: 11724.3699 / 14482.3343. The output is a pixel candidate only.
No Qt run, native placement, successful game completion or Windows acceptance
is claimed here. Existing puzzle solvers and mappings remain untouched.
