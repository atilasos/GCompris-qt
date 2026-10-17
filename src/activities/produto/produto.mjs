// SPDX-License-Identifier: GPL-3.0-or-later
// Independently implemented from the published game rules; no CRJM source copied.
export function coordinates() {
    var cells = [];
    for (var q = -4; q <= 4; ++q)
        for (var r = -4; r <= 4; ++r)
            if (Math.abs(q + r) <= 4) cells.push({q:q, r:r});
    return cells;
}
export function emptyBoard() { return Array(61).fill(0); }
export function groups(board, color) {
    var coords = coordinates(), visited = {}, sizes = [];
    for (var i = 0; i < 61; ++i) {
        if (board[i] !== color || visited[i]) continue;
        var queue = [i], size = 0;
        visited[i] = true;
        while (queue.length) {
            var at = queue.pop(); ++size;
            for (var j = 0; j < 61; ++j) {
                var dq = coords[j].q - coords[at].q;
                var dr = coords[j].r - coords[at].r;
                if (!visited[j] && board[j] === color && Math.max(Math.abs(dq), Math.abs(dr), Math.abs(dq + dr)) === 1) {
                    visited[j] = true; queue.push(j);
                }
            }
        }
        sizes.push(size);
    }
    return sizes.sort(function(a,b) { return b-a; });
}
export function summary(board, color) {
    var sizes = groups(board, color);
    return {first:sizes[0] || 0, second:sizes[1] || 0, score:(sizes[0] || 0)*(sizes[1] || 0), count:board.filter(function(c) { return c === color; }).length};
}
export function result(board) {
    if (board.indexOf(0) >= 0) return 0;
    var a = summary(board,1), b = summary(board,2);
    if (a.score !== b.score) return a.score > b.score ? 1 : 2;
    if (a.count !== b.count) return a.count < b.count ? 1 : 2;
    return 3;
}
