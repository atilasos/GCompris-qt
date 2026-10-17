// SPDX-License-Identifier: GPL-3.0-or-later
// Independent implementation of the abstract Gatos & Cães rules.
export function emptyBoard() { return Array(64).fill(0); }
export function central(index) { return index === 27 || index === 28 || index === 35 || index === 36; }
export function legal(board, index, player) {
    if (index < 0 || index >= 64 || board[index]) return false;
    var first = board.indexOf(player) === -1;
    if (first && (player === 1 ? !central(index) : central(index))) return false;
    var row = Math.floor(index / 8), col = index % 8;
    var neighbors = [];
    if (row > 0) neighbors.push(index - 8);
    if (row < 7) neighbors.push(index + 8);
    if (col > 0) neighbors.push(index - 1);
    if (col < 7) neighbors.push(index + 1);
    return neighbors.every(function(i) { return board[i] !== 3 - player; });
}
export function place(board, index, player) {
    var next = board.slice(); next[index] = player; return next;
}
export function hasMove(board, player) {
    for (var i = 0; i < 64; ++i) if (legal(board, i, player)) return true;
    return false;
}
