// SPDX-License-Identifier: GPL-3.0-or-later
// Independent implementation of the CRJM Dominório rules. No CRJM source copied.
.pragma library

function emptyBoard() {
    return Array(64).fill(0);
}
function secondCell(first, player) {
    if (first < 0 || first >= 64)
        return -1;
    if (player === 1)
        return first < 56 ? first + 8 : -1;
    return first % 8 < 7 ? first + 1 : -1;
}
function legal(board, first, player) {
    var second = secondCell(first, player);
    return second >= 0 && board[first] === 0 && board[second] === 0;
}
function hasMove(board, player) {
    for (var i = 0; i < 64; ++i) {
        if (legal(board, i, player))
            return true;
    }
    return false;
}
function place(board, first, player) {
    if (!legal(board, first, player))
        return board;
    var next = board.slice();
    next[first] = player;
    next[secondCell(first, player)] = player;
    return next;
}
