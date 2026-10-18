// SPDX-License-Identifier: GPL-3.0-or-later
// Independent implementation of the CRJM Dominório rules. No CRJM source copied.

export function emptyBoard() {
    return Array(64).fill(0);
}
export function secondCell(first, player) {
    if (first < 0 || first >= 64)
        return -1;
    if (player === 1)
        return first < 56 ? first + 8 : -1;
    return first % 8 < 7 ? first + 1 : -1;
}
export function legal(board, first, player) {
    var second = secondCell(first, player);
    return second >= 0 && board[first] === 0 && board[second] === 0;
}
export function hasMove(board, player) {
    for (var i = 0; i < 64; ++i) {
        if (legal(board, i, player))
            return true;
    }
    return false;
}
export function place(board, first, player) {
    if (!legal(board, first, player))
        return board;
    var next = board.slice();
    next[first] = player;
    next[secondCell(first, player)] = player;
    return next;
}
