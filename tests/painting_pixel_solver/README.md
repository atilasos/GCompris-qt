# Place painting pieces using pixels

This helper proposes placements from RGBA piece images and the centers of the
orange slots actually painted on screen. It never reads `board*.qml`, artwork
answer positions, correct indexes, or a solution function. Piece IDs are opaque
labels; their spelling never contributes to position or score.

`solve(images_by_id, visible_slots_in_canvas_pixels, canvas_size, **options)`
returns a dictionary with `mapping` and `diagnostics`. Each mapping value is an
index into the **supplied visible slot list**, not an internal answer index.

`solve_observed(images_by_source, board, calibration, **options)` adapts the
existing public native observations. It computes scale from a neutral placed
piece's displayed width and raw image width, confirms that scale using height,
and converts visible widget centers to canvas pixels. The destination of the
neutral placement never supplies an answer. All sidebar pages must be present.

The model uses alpha>=128, bounds, all-different slots and pairwise alpha
collision constraints. Among compatible arrangements, it minimizes squared RGB
discontinuity across overlapping/touching edges. It samples at most 128 contact
pixels per shift. It searches for the optimum and runner-up; it does not return
an early best guess when the node budget expires.

The optional `flat_border_constraints=True` classifies edges with more than 60%
opaque boundary pixels and places them outside the extrema of the public slot
centers. This assumes a rectangular jigsaw with interlocking interior cuts.
It is off by default. Fully opaque rectangles do not get this restriction.
It can reject valid arrangements with straight interior cuts; do not enable it
without checking that model assumption against the actual pieces.

The default alpha overlap fraction is 0.015. It is an explicit model parameter,
not an automatic loop that increases tolerance until an answer appears. Existing
small native inventories require margins exceeding that default: the proposed
level 1 arrangement has about 5.06% pair overlap, while levels 2/3 have 1.44%/1.77%.
The initial probes explicitly use 0.08 and report the measured maximum overlap.
That loose margin needs native validation; it does not certify the photograph's
true placement. RGB cost and the runner-up are diagnostic model evidence.

The helper raises `NoSolution`, `AmbiguousPuzzle`, or `SearchLimit` instead of
silently filling gaps or sorting ambiguous pieces by ID. An optimum unique in
this pixel model is still a candidate for native validation. No game completion,
Bonus or successful drag is proved by these pure computations.

Run the literal public-interface fixtures:

```sh
python3 -m unittest discover -s tests/painting_pixel_solver -v
python3 -O -m unittest discover -s tests/painting_pixel_solver -v
```

The fixtures cover complementary silhouettes, repeated shapes resolved by RGB,
public scale calibration, indistinguishable images, an exhausted search budget,
an image that cannot fit and a scale probe with inconsistent height. They use
literal pixels and expected placements, not answers computed by the solver.

`probe.py` reads existing native inventory/calibration JSON and physical images.
It runs no Qt and records input/image/helper hashes. Its `--output` must be new.
Use `--overlap-fraction`, `--flat-borders` and `--max-nodes` explicitly for a new
experiment. Preserve the physical input images before calling its output a
portable proof. Pillow 12.1.1 and Python standard library are sufficient; NumPy,
Git and network are not required at runtime.
