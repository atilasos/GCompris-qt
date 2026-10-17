// SPDX-License-Identifier: GPL-3.0-or-later
// Independent native rules. Reference/provenance: ORIGIN.md.
export function emptyBoard() { return Array(81).fill(0); }
function neighbours(index) {
    const row = Math.floor(index / 9), col = index % 9, result = [];
    if (row > 0) result.push(index - 9);
    if (row < 8) result.push(index + 9);
    if (col > 0) result.push(index - 1);
    if (col < 8) result.push(index + 1);
    return result;
}
export function group(board, start) {
    if (!board[start]) return {stones: [], liberties: []};
    const stones = [], liberties = [], pending = [start];
    while (pending.length) {
        const point = pending.pop();
        if (stones.indexOf(point) >= 0) continue;
        stones.push(point);
        for (const next of neighbours(point)) {
            if (!board[next] && liberties.indexOf(next) < 0) liberties.push(next);
            else if (board[next] === board[start] && stones.indexOf(next) < 0) pending.push(next);
        }
    }
    return {stones: stones, liberties: liberties};
}
export function place(board, player, index) {
    if (index < 0 || index >= 81 || board[index]) return {error: "occupied"};
    const next = board.slice(); next[index] = player;
    const captured = [];
    for (const neighbour of neighbours(index)) {
        if (next[neighbour] === 3 - player) {
            const enemy = group(next, neighbour);
            if (!enemy.liberties.length) {
                for (const stone of enemy.stones) {
                    captured.push(stone); next[stone] = 0;
                }
            }
        }
    }
    if (!group(next, index).liberties.length) return {error: "suicide"};
    return {board: next, captured: captured};
}
