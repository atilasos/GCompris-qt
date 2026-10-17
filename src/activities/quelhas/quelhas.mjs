// SPDX-License-Identifier: GPL-3.0-or-later
// Independently authored from the rules, not translated from CRJM code.
export function emptyBoard() { return Array(100).fill(0); }
export function segment(first, last, vertical) {
    if (first < 0 || last < 0 || first > 99 || last > 99 || first === last) return [];
    if (vertical ? first % 10 !== last % 10 : Math.floor(first / 10) !== Math.floor(last / 10)) return [];
    var result = [], step = vertical ? 10 : 1;
    for (var i = Math.min(first, last); i <= Math.max(first, last); i += step) result.push(i);
    return result;
}
export function legal(board, selected) {
    return selected.length >= 2 && selected.every(index => !board[index]);
}
export function place(board, selected) {
    var next = board.slice();
    selected.forEach(index => { next[index] = 1; });
    return next;
}
export function hasMove(board, vertical) {
    for (var i = 0; i < 100; ++i) {
        var other = i + (vertical ? 10 : 1);
        if (other < 100 && (vertical || i % 10 < 9) && !board[i] && !board[other]) return true;
    }
    return false;
}
export function options(board, vertical) {
    var result = [], step = vertical ? 10 : 1;
    for (var first = 0; first < 100; ++first) {
        if (board[first]) continue;
        for (var last = first + step; last < 100 && (vertical || Math.floor(first / 10) === Math.floor(last / 10)); last += step) {
            if (board[last]) break;
            result.push(segment(first, last, vertical));
        }
    }
    return result;
}
export function pairs(board, vertical) {
    var count = 0;
    for (var i = 0; i < 100; ++i) {
        var other = i + (vertical ? 10 : 1);
        if (other < 100 && (vertical || i % 10 < 9) && !board[i] && !board[other]) ++count;
    }
    return count;
}
