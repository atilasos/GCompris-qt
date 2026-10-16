# Exact geometry oracle for the nine public polygon instructions

This pure module has two independent boundaries. Neither reads GCompris level
definitions, TutorialDataset, JavaScript validation, authored coordinates,
answer IDs, progress, or Qt objects.

```python
# Add the frozen source's tests directory to sys.path.
from polygon_geometry_oracle import propose, classify, satisfies
vertices = propose(instruction_pt)
facts = classify(observed_grid_vertices)
accepted_property = satisfies(observed_grid_vertices, 'rectangle')
```

`propose` recognizes exactly these nine observed PT instructions:

| Public instruction | Geometric property name |
|---|---|
| Desenha um polígono. | polygon |
| Desenha um triângulo. | triangle |
| Desenha um triângulo retângulo. | right_triangle |
| Desenha um triângulo isósceles. | isosceles_triangle |
| Desenha um quadrilátero. | quadrilateral |
| Desenha um retângulo. | rectangle |
| Desenha um quadrado. | square |
| Desenha um paralelogramo que não seja um retângulo. | nonrectangular_parallelogram |
| Desenha um losango que não seja um quadrado. | nonsquare_rhombus |

These texts were observed in task90's public inventory receipt
`pt-patterns/.scratch/pt-pt/functional-patterns/inventory-polygons/result.json`.
No tutorial data/model files were read to construct the example vertices.
The examples are original integer constructions inside coordinates 1..8 of the
public 0..10 grid. There are many correct shapes. No uniqueness, native game
approval or functional completion is claimed. The proposed isosceles triangle
has exactly two equal sides, avoiding unnecessary school terminology ambiguity.

`classify` receives an ordered contour of exact integer/Fraction vertex pairs.
The first vertex is not repeated at the end: the last edge closes implicitly.
The caller must recover observed grid points from the visible grid and record
its projection error before classification. Raw screen floats are refused;
there is no hidden angular tolerance or coordinate snapping in this module.

Classification depends only on the supplied points. It rejects repeated
vertices, fewer than three vertices, collinear consecutive edges, zero area,
and nonadjacent crossing/touching segments. Concave simple polygons are allowed.
It computes signed and absolute doubled shoelace area, squared side lengths,
adjacent dot products and parallelism of opposite sides (cross products).
For valid polygons it returns those facts plus a list of geometric properties.
Rational inputs retain exact Fraction results; callers serializing such facts
must preserve them as ratios rather than round them silently.

Conventions: a square is also a rectangle, rhombus and parallelogram; a rectangle
is a parallelogram; a rhombus is a parallelogram. Isosceles means at least two
equal side lengths. `nonrectangular_parallelogram` excludes rectangles (including
squares); `nonsquare_rhombus` excludes squares. These exclusions are geometric
predicates, not inferred by substring matching an instruction. Unknown property
names and unknown instructions raise ValueError subtypes. Malformed/degenerate
polygons raise InvalidPolygon instead of being treated as a negative game answer.

Cyclic shifts and reversal describe the same boundary. Arbitrary vertex
permutations can introduce crossings and are checked in their supplied order;
the classifier never sorts vertices into a more convenient shape. Positive or
negative nonzero rational scale and translation preserve the classifications.

```sh
python3 -m unittest discover -s tests/polygon_geometry_oracle -p 'test_*.py'
python3 -O -m unittest discover -s tests/polygon_geometry_oracle -p 'test_*.py'
```

The eight tests include independent literal valid/wrong-shape fixtures for all
properties, rotated rectangle invariants, crossing/touching/collinear examples,
24 square vertex permutations (eight valid, 16 crossing), rational transforms,
strict instruction recognition, and protection against mutable candidate state.
No assert statement supplies a runtime guard. The initial rectangle and public
proposer tests were observed red before implementation. Qt projection/clicks,
wrong-answer/repair flows and native returns belong to the parent task90.
