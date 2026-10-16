# SPDX-License-Identifier: GPL-3.0-or-later
from pathlib import Path
import sys
import unittest
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from polygon_geometry_oracle import propose, classify, satisfies, UnknownInstruction

# Literal public instructions observed in task90, not game models.
INSTRUCTIONS = [
    ('Desenha um polígono.', 'polygon'),
    ('Desenha um triângulo.', 'triangle'),
    ('Desenha um triângulo retângulo.', 'right_triangle'),
    ('Desenha um triângulo isósceles.', 'isosceles_triangle'),
    ('Desenha um quadrilátero.', 'quadrilateral'),
    ('Desenha um retângulo.', 'rectangle'),
    ('Desenha um quadrado.', 'square'),
    ('Desenha um paralelogramo que não seja um retângulo.', 'nonrectangular_parallelogram'),
    ('Desenha um losango que não seja um quadrado.', 'nonsquare_rhombus'),
]


class ProposedVertices(unittest.TestCase):
    def test_every_explicit_instruction_has_a_valid_interior_candidate(self):
        for instruction, property_name in INSTRUCTIONS:
            with self.subTest(instruction=instruction):
                vertices = propose(instruction)
                self.assertTrue(all(type(v) is int and 1 <= v <= 8 for p in vertices for v in p))
                self.assertTrue(satisfies(vertices, property_name))
        iso = classify(propose('Desenha um triângulo isósceles.'))
        self.assertEqual(len(set(iso['side_lengths_squared'])), 2)

    def test_unrecognized_text_or_type_is_not_guessed(self):
        for instruction in ['Desenha um círculo.', 'triângulo', 'Desenha um retangulo.',
                            'Desenha um losango.', 'Desenha um quadrado. ', None, 7]:
            with self.subTest(instruction=instruction), self.assertRaises(UnknownInstruction):
                propose(instruction)

    def test_callers_cannot_mutate_future_candidates(self):
        first = propose('Desenha um quadrado.')
        first[0] = (999, 999)
        self.assertNotIn((999, 999), propose('Desenha um quadrado.'))


if __name__ == '__main__':
    unittest.main()
