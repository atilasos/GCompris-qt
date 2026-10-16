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

The optional `flat_border_constraints=True` classifies edges with a contiguous opaque run spanning more than 60%
of the side and places them outside the extrema of the public slot
centers. This assumes a rectangular jigsaw with interlocking interior cuts.
It is off by default. Fully opaque rectangles do not get this restriction.
It can reject valid arrangements with straight interior cuts; do not enable it
without checking that model assumption against the actual pieces.

A concave internal edge can have two separated opaque runs covering most of a
side. Their combined fraction is not an external-border signal: the classifier
uses the **longest contiguous run**, not their sum. This fixes the observed
piano cuts with about 63% total occupancy but only 32% in either run.

`canvas_padding=0` keeps the original strict background bounds. Set a positive
integer only when the public image geometry permits pieces to extend beyond the
background image. The computational mask canvas gets that many pixels on each
side; slot indexes and placement centers stay unchanged. This padding does not
alter the alpha overlap budget or crop the source images. It is a separate,
explicit assumption about the background frame, which may not be a clipping
boundary. It never increases automatically after a failed search.

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
an image that cannot fit, a scale probe with inconsistent height, a concave
internal edge and an explicitly allowed foreground bleed. They use
literal pixels and expected placements, not answers computed by the solver.

`probe.py` reads existing native inventory/calibration JSON and physical images.
It runs no Qt and records input/image/helper hashes. Its `--output` must be new.
Use `--overlap-fraction`, `--flat-borders` and `--max-nodes` explicitly for a new
experiment. Preserve the physical input images before calling its output a
portable proof. Pillow 12.1.1 and Python standard library are sufficient; NumPy,
Git and network are not required at runtime.
