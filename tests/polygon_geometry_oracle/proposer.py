# SPDX-License-Identifier: GPL-3.0-or-later
"""Original example vertices for nine exact, publicly observed instructions."""


class UnknownInstruction(ValueError):
    """No candidate is proposed for an unrecognized public instruction."""


# These are original constructions, not imported from game data or solutions.
# All vertices lie strictly inside the public 0..10 grid, at coordinates 1..8.
_CANDIDATES = {
    'Desenha um polígono.': ((1, 2), (6, 1), (8, 4), (6, 7), (2, 8)),
    'Desenha um triângulo.': ((1, 1), (8, 2), (3, 8)),
    'Desenha um triângulo retângulo.': ((2, 2), (8, 2), (2, 7)),
    'Desenha um triângulo isósceles.': ((2, 2), (8, 2), (5, 7)),
    'Desenha um quadrilátero.': ((1, 2), (8, 2), (7, 7), (2, 7)),
    'Desenha um retângulo.': ((2, 2), (8, 2), (8, 6), (2, 6)),
    'Desenha um quadrado.': ((2, 2), (7, 2), (7, 7), (2, 7)),
    'Desenha um paralelogramo que não seja um retângulo.': ((1, 2), (5, 2), (7, 6), (3, 6)),
    'Desenha um losango que não seja um quadrado.': ((2, 4), (4, 1), (6, 4), (4, 7)),
}


def propose(instruction_pt):
    """Return one example boundary, not a unique or game-approved solution.

    The caller closes the contour by clicking the first point again. The returned
    list does not repeat that point. This function does not consult the classifier.
    """
    if not isinstance(instruction_pt, str) or instruction_pt not in _CANDIDATES:
        raise UnknownInstruction('Unknown public polygon instruction: '+repr(instruction_pt))
    return list(_CANDIDATES[instruction_pt])
