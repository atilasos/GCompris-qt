# Scene pixels for task 90

Pure Pillow checks of existing PNG bytes and recorded public geometry. This
module does not run Qt, read level solutions, reorder vertices, inspect hidden
answer state, or change historical proofs. Parent evidence must bind module,
receipt and scene identities; coherent replacement of all those identities is
not prevented by a pixel metric alone.

```python
from pattern_scene_pixels import check_cells, check_snapshot, snapshot_report
counts = check_cells(observed_cells, sceneImage, background=backgroundImage)
check_snapshot(state, sceneImage)  # True, or raises PixelMismatch/UnsupportedScene
facts = snapshot_report(state, sceneImage)
```

Images are Pillow images. The cell list contains `frame` (centre x/y and
width/height, optionally visible/opacity) and the publicly recorded Qt `color`.
Only #rrggbb and #aarrggbb are accepted. Five samples in the upper-right interior
(x=centre+22%width, y=centre−24%height, offsets ±3.5% on each axis) avoid numbers,
centre cursor and borders. Every channel must differ by at most 2. Empty input,
clipped, hidden, partially opaque or too-small cells are refused.

For alpha, the returned `alpha_unverified` count is explicit unless an independent
same-size background image is supplied. That count is not a pixel approval.
With background, use round((alpha*foreground+(255-alpha)*background)/255) at EACH
sample. #33ffffff is 20% white over the background, never opaque white. Do not use
the scene itself as the independent background.

The actual background.svg was rendered outside Git with librsvg 2.61.3/cairo 1.18.4
into 800× 800, matching the recorded PreserveAspectCrop: SVG viewBox 1059.8× 748,
scale=max(800/1059.8,800/748), centred viewport
(-166.7379679144385,0,1133.475935828877,800).
The render is a separate input, not an assumption that librsvg equals Qt. All
6912 alpha cells passed against physical Qt scene PNGs at the original channel
tolerance 2. Source SVG SHA b7746cabc008789b8075e47905f1c7c56b67ad34e09dca559b15bf5e8845fed9;
rendered PNG SHA 9c87c64ae485e4750f87edd65419a54083fa59ace96b9ec4125752e845357820.
The parent archive should retain that PNG/render provenance if relying on alpha
checks; the Python checker does not require librsvg at audit time.

Polygon states contain a centre-based `grid` frame, recorded point `sceneCenter`
and point frame width/height, plus `label` or explicit boolean `closed`. An
explicit boolean takes precedence. With recorded point styles, three or more
blue #20a8dd/opacity 0.3 points establish closed traversal; a transparent
#00000000/opacity 0.5 last point with preceding blue points establishes open
traversal. Other style combinations are refused. Only when point styles are
absent, labels containing `closed`/`repaired` provide the fallback. The report
records closure_basis; absent points establish no painted segment. Otherwise
only consecutive points are joined. Cyclic shifts and reversal preserve a closed contour, but
arbitrary sorting is forbidden. One open point has zero segments, reported as
such. Empty states can prove absence of unexpected green ink, not a drawn shape.

Visible stroke RGB(16,114,29) was measured in preserved PNGs. The fixed classifier
allows 24/channel to tolerate rasterisation, searches a ±2-pixel square at samples
spaced at most 4 pixels, and excludes disks radius=max(point width,height)/2+3.
This separates blue point disks and grey grid from green strokes. Every segment
needs unobscured support; unsupported short segments are refused. Green ink
elsewhere in the grid must be at most 3 pixels from an expected segment. This
rejects missing edges, extra diagonals and coherently moved metadata. It proves
sampled raster support, not every subpixel or the abstract correctness of a shape.

```sh
python3 -m unittest discover -s tests/pattern_scene_pixels
python3 -O -m unittest discover -s tests/pattern_scene_pixels
python3 tests/pattern_scene_pixels/probe.py --proof-root PROOF_ROOT --background BACKGROUND.png
```

The probe reads only the five named completed receipts and PNGs offered by them;
missing scenes are listed explicitly, never replaced by generated pictures.
It reports input hashes and current source hashes. The real observation contains
177 Redraw/Sym scenes (6078 opaque cells,6912 alpha cells,64950 samples), plus 159
Polygons states (281 segments, 15988 support samples). Forty-two states contain zero
segments. No game completion or native return is inferred from these counts.
No tolerances were relaxed after observing failures. Eight tests include literal
opaque/alpha fixtures, blank/grid/blue-only negatives, removed/extra lines,
coherently moved point metadata, closure changes, cyclic/reversed contours and
one-point states, plus closure from public point styles after edits. Existing Qt scenes and receipts were never rewritten.

Closure is a recorded public-state interpretation, not a reconstruction of click
events. Overlapping collinear paths can have identical pixels whether closed or
open; geometric correctness and event evidence belong to the parent oracle.
