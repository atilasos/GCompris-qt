# SPDX-License-Identifier: GPL-3.0-or-later
"""Solve a visible cross-toggle board by elimination over GF(2)."""


def press(board, size, cell):
    result = list(board)
    row, col = divmod(cell, size)
    for r, c in [(row, col), (row-1, col), (row+1, col),
                 (row, col-1), (row, col+1)]:
        if 0 <= r < size and 0 <= c < size:
            result[r*size+c] ^= 1
    return result


def solve(board, size):
    if len(board) != size*size or any(value not in (0, 1) for value in board):
        raise ValueError('Expected a square binary board')
    count = len(board)
    columns = [press([0]*count, size, index) for index in range(count)]
    rows = [[columns[col][row] for col in range(count)]+[board[row]]
            for row in range(count)]
    pivots = []
    for col in range(count):
        pivot = next((row for row in range(len(pivots), count)
                      if rows[row][col]), None)
        if pivot is None:
            continue
        current = len(pivots)
        rows[current], rows[pivot] = rows[pivot], rows[current]
        for row in range(count):
            if row != current and rows[row][col]:
                rows[row] = [a ^ b for a, b in zip(rows[row], rows[current])]
        pivots.append(col)
    if any(not any(row[:count]) and row[-1] for row in rows):
        raise ValueError('Unsolvable board')
    return [col for row, col in enumerate(pivots) if rows[row][-1]]
